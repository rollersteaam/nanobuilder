class Neutron extends Particle {
    Neutron(float x, float y, float z, Atom parent) {
        // super(x, y, z, random(0.84, 0.87) * 100);
        super(x, y, z, 87);
        charge = 0;
        mass = 1.6726219 * pow(10, -10);

        this.parent = parent;
        parent.addChild(this);

        baseColor = color(255);
        revertToBaseColor();
    }

    @Override
    void display() {
        super.display();

        // TODO: Implement gravitational force (probably)
    }
}