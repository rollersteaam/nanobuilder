class Proton extends Particle {
    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z, Atom parent) {
        super(x, y, z, 87);
        charge = 1.6 * pow(10, -19);
        mass = 1.6726219 * pow(10, -27);

        this.parent = parent;
        parent.addChild(this);

        baseColor = color(255, 0, 0);
        revertToBaseColor();
    }

    Proton() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            null
        );
    }

    @Override
    void evaluatePhysics() {
        evaluateElectricalField();
        super.evaluatePhysics();
    }

    @Override
    void display() {
        // if (PVector.dist(cam.position, pos) > (r + 1000))
        //     return;

        if (shape == null) return;

        if (parent != null) {
            if (!parent.shouldParticlesDraw()) {
                return;
            }
        }

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            255
            // lerp(255, 0, PVector.dist(cam.position, pos) / ((r + 1000) * 2))
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }
}