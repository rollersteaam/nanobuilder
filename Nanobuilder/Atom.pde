class Atom extends Particle {
    Proton core;
    ArrayList<Proton> listProtons = new ArrayList<Proton>();
    ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();

    Atom(float x, float y, float z, float radius) {
        super(x, y, z, radius);
        core = new Proton(x, y, z);
        listProtons.add(core);
        listElectrons.add(new Electron(x + 100, y + 100, z + 100, core));
        listElectrons.add(new Electron(x - 100, y - 100, z - 100, core));
    }
    
    Atom() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            round(random(200, 600))
        );
    }

    @Override
    void display() {
        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // lerp(0, 255, PVector.dist(cam.position, pos) / (r + 1000))
            255
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }
}