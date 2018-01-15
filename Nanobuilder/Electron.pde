class Electron extends Atom {
    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Atom orbiting) {
        super(x, y, z, random(0.84, 0.87) / 10 * 1000 / 2);

        charge = -1.6 * pow(10, -19);
        mass = 9.10938356 * pow(10, -31);
        /*
        F = mv^2/r
        Fr
        - = v^2
        m
        F = Qq
            -
            4PIE0R^2

        */
        PVector diff = PVector.sub(pos, orbiting.pos).normalize();
        // PVector cross = diff.cross(PVector.add(pos, new PVector(0, 1, 0)));
        // PVector cross = new PVector(0, 0, 1).cross(diff);
        // PVector cross = diff.cross(PVector.add(pos, new PVector(50, 50, 50)));
        PVector to_cross = new PVector(0.0f, 1.0f, 0.0f).normalize();
        println(diff);
        println(to_cross);
        println("---");
        // Make sure that the normal and cross vector are not the same, if they are change the cross vector
        if (
            to_cross.x == diff.x &&
            to_cross.y == diff.y &&
            to_cross.z == diff.z
            ) {
            to_cross = new PVector(0.0f, 0.0f, 1.0f);
            println("I SELL HAMBURGERS.");
        }
        // Get the cross product
        PVector cross = diff.cross(to_cross);
        println(pos);
        println(diff);
        println(cross);
        // velocity = cross.setMag(8);
        // velocity = cross.setMag(sqrt(orbiting.calculateCoulombsLawForceOn(this) * 100 * PVector.dist(orbiting.pos, this.pos) / (float) mass));
        velocity = cross.setMag(0.710884794 * sqrt(100));
        // velocity = new PVector(0.710884794*sqrt(10000), 0, 0);

        baseColor = color(0, 0, 255);
        revertToBaseColor();
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
        // evaluateElectricalField();
        super.display();

        pushMatrix();
        pushStyle();
            fill(0);
            stroke(0);
            strokeWeight(4);
            // translate(pos.x, pos.y, pos.z);
            line(pos.x, pos.y, pos.z, pos.x + velocity.x, pos.y + velocity.y, pos.z + velocity.z);
        popMatrix();
        popStyle();

        Point point = new Point();
        trail.push(point);

        int trailSize = 600;

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