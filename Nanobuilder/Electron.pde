class Electron extends Particle {
    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Proton proton) {
        // super(x, y, z, random(0.84, 0.87) * 100 / 1000);
        super(x, y, z, random(0.84, 0.87) * 100 / 3);

        charge = -1.6 * pow(10, -19);
        mass = 9.10938356 * pow(10, -31);

        baseColor = color(0, 0, 255);
        revertToBaseColor();

        // If no initial proton then spawn with random velocity.
        if (proton == null) {
            velocity = PVector.random3D().setMag(3);
            return;
        }

        parent = proton.parent;

        setInitialCircularVelocityFromForce(proton, proton.calculateCoulombsLawForceOn(this));
        // velocity = calculateCircularMotionInitialVelocity(proton, proton.calculateCoulombsLawForceOn(this));

        // velocity = cross.setMag(
        //     sqrt(
        //         // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
        //         abs(
        //             proton.calculateCoulombsLawForceOn(this) * 100 * PVector.dist(proton.pos, this.pos) / (float) mass
        //         )
        //     )
        // );
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
        // if (PVector.dist(cam.position, pos) > (r + 1000)) {
        //     for (Point point : trail) {
        //         trail.remove(point);
        //     }
        //     return;
        // }

        if (!parent.shouldParticlesDraw()) {
            trail.clear();
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

        /*
        Scales trail size based off of distance from it's 'parent' (what it's orbiting)

        It should be noted that this CAN be expensive, but by limiting the draw distance for
        seeing particles, it isn't necessarily a problem.
        */
        float dist = PVector.sub(pos, parent.pos).mag();
        float trailSize = 60 + (60 * ( (dist/200) - 1 ));

        Point lastPoint = null;
        int counter = 0;
        for (Point element : trail) {
            counter++;
            pushMatrix();
            pushStyle();
                fill(0);
                // stroke(0, map(counter, 0, (trailSize - 1), 255, 0));
                stroke(
                    lerpColor(color(187, 0, 255), color(0, 187, 255), (counter * 1.5)/trail.size()),
                    map(counter, 0, (trailSize - 1), 255, 0)
                );
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