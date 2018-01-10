class Electron extends Atom {
    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z) {
        super(x, y, z, random(0.84, 0.87) / 10 * 1000 / 2);
        charge = -1.6 * pow(10, -19);
        mass = 9.10938356 * pow(10, -31);
        velocity = new PVector(0.710884794*sqrt(1000), 0, 0);


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

    Deque<TrailElement> trail = new ArrayDeque<TrailElement>();

    @Override
    void display() {
        evaluateElectricalField();
        //println(velocity);
        super.display();

        trail.push(new TrailElement());

        pointLight(120, 120, 255, pos.x, pos.y, pos.z);

        for (TrailElement element : trail) {
            pushMatrix();
            pushStyle();
            fill(0);
            translate(element.position.x, element.position.y, element.position.z);
            // sphere(10);
            shape(element.shape);
            popMatrix();
            popStyle();
        }

        if (trail.size() > 100)
            trail.removeLast();

        
    }
}