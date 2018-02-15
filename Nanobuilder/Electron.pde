class Electron extends Particle {
    // static final float MASS = 9.10938356 * pow(10, -31);
    public static final float MASS = 9.10938356e-31;
    public static final float CHARGE = -1.60217662e-19;

    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Proton proton) {
        // super(x, y, z, random(0.84, 0.87) * 100 / 1000);
        // super(x, y, z, random(0.84, 0.87) * 100 / 3);
        super(x, y, z, 87 / 3);

        charge = CHARGE;
        mass = MASS;

        baseColor = color(0, 0, 255);
        revertToBaseColor();

        // If no initial proton then spawn with random passive velocity.
        if (proton == null) {
            velocity = PVector.random3D().setMag(2);
            return;
        }

        parent = proton.parent;

        setInitialCircularVelocityFromForce(proton, proton.calculateCoulombsLawForceOn(this));
    }

    Electron() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            null
        );
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

        if (shape == null) return;

        /*
        Scales trail size based off of distance from it's 'parent' (what it's orbiting)

        It should be noted that this CAN be expensive, but by limiting the draw distance for
        seeing particles, it isn't necessarily a problem.
        */
        // Handles null pointer in case electron loses parent or has none.
        float dist;
        if (parent != null) {
            dist = min(PVector.sub(pos, parent.pos).mag(), 1000);
            
            if (!parent.shouldParticlesDraw()) {
                trail.clear();
                return;
            }
        } else {
            dist = 1000;
        }

        // float trailSize = 60 + (60 * ( (500/dist) - 1 ));
        float trailSize = 60 + (2 * ( (5000/dist) - 1 ));

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
                    // 255
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

        if (shape == null) return;

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
    }
}