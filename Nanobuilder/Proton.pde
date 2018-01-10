class Proton extends Atom {
    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z) {
        super(x, y, z, random(0.84, 0.87) * 100);
        charge = 1.6 * pow(10, -2);
        mass = 1.6726219 * pow(10, -10);

        baseColor = color(255, 0, 0);
        revertToBaseColor();
    }

    @Override
    void display() {
        super.display();

        evaluateElectricalField();
    }
}