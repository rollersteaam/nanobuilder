class Proton extends Particle {
    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z) {
        super(x, y, z, random(0.84, 0.87) * 100);
        charge = 1.6 * pow(10, -19);
        mass = 1.6726219 * pow(10, -27);

        baseColor = color(255, 0, 0);
        revertToBaseColor();
    }

    Proton() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000)
        );
    }

    @Override
    void evaluatePhysics() {
        evaluateElectricalField();
        super.evaluatePhysics();
    }

    @Override
    void display() {
        if (PVector.dist(cam.position, pos) > 1000) return;
        super.display();
    }
}