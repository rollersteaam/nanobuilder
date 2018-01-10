class Neutron extends Atom {
    Neutron(float x, float y, float z) {
        super(x, y, z, random(0.84, 0.87) * 100);
        charge = 0;
        mass = 1.6726219 * pow(10, -10);

        baseColor = color(255);
        revertToBaseColor();
    }

    @Override
    void display() {
        super.display();

        // TODO: Implement gravitational force (probably)
    }
}