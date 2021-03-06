class Proton extends Particle {
    public static final float MASS = 1.6726219e-27;
    public static final float CHARGE = 1.60217662e-19;
    private Atom coreOf = null;

    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z, Atom parent) {
        super(x, y, z, 87);
        charge = CHARGE;
        mass = MASS;

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

    void setCoreOf(Atom newAtom) {
        if (coreOf != null) return;

        coreOf = newAtom;
    }

    Atom getCoreOf() {
        return coreOf;
    }

    void evaluateElectricalField() {
        if (coreOf == null) return;

        for (Particle particle : worldManager.particleList) {
            if (particle == this) continue;
            // if (particle.parent != parent) continue;
            // if (particle instanceof Electron && this instanceof Electron) continue;
            if (particle instanceof Proton) continue;
            if (particle.parent != parent) continue;

            applyForce(particle, calculateCoulombsLawForceOn(particle));
        }
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