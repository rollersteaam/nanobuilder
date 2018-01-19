class Electron extends Particle {
    final int X_DOMINANT = 0;
    final int Y_DOMINANT = 1;
    final int Z_DOMINANT = 2;

    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Particle proton) {
        super(x, y, z, random(0.84, 0.87) * 100 / 3);

        charge = -1.6 * pow(10, -19);
        mass = 9.10938356 * pow(10, -31);

        baseColor = color(0, 0, 255);
        revertToBaseColor();

        // If no initial proton then spawn with random velocity.
        if (proton == null) {
            velocity = PVector.random3D().setMag(30);
            return;
        }

        parent = proton;

        PVector diff = PVector.sub(pos, proton.pos).normalize();
        PVector diffMag = new PVector(
            abs(diff.x),
            abs(diff.y),
            abs(diff.z)
        );
        int magRecordCoordinate = -1;
        float magRecord = 0;
        if (diffMag.x < magRecord || magRecord == 0) {
            magRecord = diffMag.x;
            magRecordCoordinate = X_DOMINANT;
        }

        if (diffMag.y < magRecord) {
            magRecord = diffMag.y;
            magRecordCoordinate = Y_DOMINANT;
        }

        if (diffMag.z < magRecord) {
            magRecord = diffMag.z;
            magRecordCoordinate = Z_DOMINANT;
        }

        PVector toCross = new PVector();
        if (magRecordCoordinate == X_DOMINANT) {
            toCross = new PVector(1, 0, 0);
        } else if (magRecordCoordinate == Y_DOMINANT) {
            toCross = new PVector(0, 1, 0);
        } else if (magRecordCoordinate == Z_DOMINANT) {
            toCross = new PVector(0, 0, 1);
        }

        PVector cross = diff.cross(toCross);

        /*
        Substituting circular motion and couloumb's law...
        F = mv^2/r
        Fr
        - = v^2
        m
        where F = Qq
                  -
                  4(PI)(E0)R^2

        This value returns what the magnitude of the perpendicular
        vector to the proton must be for circular motion to take place.

        This is used because we are trying to model the physics, so some
        assumptions (like the initial state of an atom) need to be initially
        assumed. Any changes after are then just part of the simulated space,
        so should be dynamic.
        */
        velocity = cross.setMag(
            sqrt(
                // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
                abs(
                    proton.calculateCoulombsLawForceOn(this) * 100 * PVector.dist(proton.pos, this.pos) / (float) mass
                )
            )
        );
    }

    Electron() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            null
        );
    }

    class TrailElement {
        PVector position;
        PShape shape;

        TrailElement() {
            position = pos.copy();

            pushStyle();
            fill(0);
            shape = createShape(SPHERE, 10);
            shape.setFill(color(0));
            popStyle();
        }
    }

    private class Point {
        float x;
        float y;
        float z;

        Point() {
            x = pos.x;
            y = pos.y;
            z = pos.z;
        }
    }

    Deque<Point> trail = new ArrayDeque<Point>();

    @Override
    void display() {
        if (PVector.dist(cam.position, pos) > (r + 1000)) {
            for (Point point : trail) {
                trail.remove(point);
            }
            return;
        }

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // lerp(255, 0, PVector.dist(cam.position, pos) / ((r + 1000) * 2))
            255
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();

        // pushMatrix();
        // pushStyle();
        //     fill(0);
        //     stroke(0);
        //     strokeWeight(4);
        //     line(pos.x, pos.y, pos.z, pos.x + velocity.x, pos.y + velocity.y, pos.z + velocity.z);
        // popMatrix();
        // popStyle();

        Point point = new Point();
        trail.push(point);

        int trailSize = 60;

        Point lastPoint = null;
        int counter = 0;
        for (Point element : trail) {
            counter++;
            pushMatrix();
            pushStyle();
                fill(0);
                stroke(0, map(counter, 0, (trailSize - 1), 255, 0));
                strokeWeight(4);

                if (lastPoint != null)
                    line(lastPoint.x, lastPoint.y, lastPoint.z, element.x, element.y, element.z);

                lastPoint = element;
            popMatrix();
            popStyle();
        }

        if (trail.size() > trailSize)
            trail.removeLast();
    }
}