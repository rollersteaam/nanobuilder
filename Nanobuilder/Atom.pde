class Atom extends Particle {
    Proton core;
    ArrayList<Proton> listProtons = new ArrayList<Proton>();
    ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();
    float orbitDistance;

    Atom(float x, float y, float z, int electrons) {
        super(x, y, z, 200);
        core = new Proton(x, y, z, this);
        listProtons.add(core);
        children.add(core);

        // An atom always has one shell, or it's not an atom and should throw an exception before this anyway.
        shells.add(new ElectronShell(2, 1, orbitDistance));

        for (int remainingElectrons = electrons; remainingElectrons > 0; remainingElectrons--) {
            addElectron();
        }

        recalculateRadius();
    }
    
    Atom(float x, float y, float z) {
        this(
            x,
            y,
            z,
            (int) random(1, 20)
        );
    }
    
    Atom(int electrons) {
        this(
            random(-2000, 2000),
            random(-2000, 2000),
            random(-2000, 2000),
            electrons
        );
    }

    Atom() {
        this(round(random(1, 50)));
    }

    void recalculateRadius() {
        r = shells.size() * 200;
        shape.scale(shells.size());
    }
    
    @Override
    public boolean select() {
        if (!shouldParticlesDraw) return true;
        
        return false;
    }

    @Override
    void display() {
        if (shape == null) return;

        calculateShouldParticlesDraw();

        if (shouldParticlesDraw) return;
        // if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // 255
            // lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / (r + 4000))
            lerp(0, 255, (PVector.dist(cam.position, pos) / ((r*2) + 100)) )
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }

    private class ElectronShell {
        private ArrayList<Electron> contents = new ArrayList<Electron>();
        private int max;
        private int shellNumber;
        // Orbit distance is passed in from a property in atoms during shell construction
        private float orbitDistance;

        ElectronShell(int max, int shellNumber, float orbitDistance) {
            this.max = max;
            this.shellNumber = shellNumber;
            this.orbitDistance = orbitDistance;
        }

        int getSize() {
            return contents.size();
        }

        boolean addElectron() {
            // This will probably only occur when a new shell needs creating, but SRP means it's implemented here.
            if (contents.size() == max) return false;

            // Initial position is not important, it will be changed immediately.
            Electron newElectron = new Electron(0, 0, 0, core);
            children.add(newElectron);
            contents.add(newElectron);

            int totalElectrons = contents.size();
            float angularSeperation = (2 * PI) / totalElectrons;

            for (int i = 0; i < totalElectrons; i++) {
                Electron electron = contents.get(i);

                float angle = angularSeperation * i;

                if (shellNumber % 2 == 1)
                    electron.pos = PVector.add(pos, new PVector(sin(angle), cos(angle), 0).setMag(orbitDistance + 200 * shellNumber) );
                else
                    electron.pos = PVector.add(pos, new PVector(sin(angle), 0, cos(angle)).setMag(orbitDistance + 200 * shellNumber) );
                    
                electron.setInitialCircularVelocityFromForce(core, core.calculateCoulombsLawForceOn(electron));
            }

            return true;
        }

        boolean removeElectron() {
            if (contents.size() == 0) return false;
            
            // Remove the last appended electron in the shell.
            int index = contents.size() - 1;
            Electron target = contents.get(index);
            target.delete();
            contents.remove(index);
            
            return true;
        }
    }

    public void addElectron() {
        if (shells.size() == 0)
            throw new IllegalStateException("An atom has no electron shells.");

        int numberOfShells = shells.size();
        ElectronShell lastShell = shells.get(numberOfShells - 1);

        if (!lastShell.addElectron()) {
            ElectronShell newShell = new ElectronShell((int) (2 * pow(numberOfShells + 1, 2)), numberOfShells + 1, orbitDistance);
            shells.add(newShell);
            newShell.addElectron();
        }
    }

    public void removeElectron() {
        if (shells.size() == 0)
            println("Warning: Tried to remove an electron when there are no electron shells.");
            // throw new IllegalStateException("An atom has no electron shells.");
            
        ElectronShell lastShell = shells.get(shells.size() - 1);
        lastShell.removeElectron();

        if (lastShell.getSize() == 0)
            shells.remove(shells.size() - 1);
    }

    private boolean shouldParticlesDraw = false;

    /*
    This approach is used because it a) unifies the conditions all into one
    function allowing easy changes later if necessary, and b) limits the need
    to call PVector.dist 1,000 times just because every particle of an Atom wants
    to know
    */
    private void calculateShouldParticlesDraw() {
        if (PVector.dist(cam.position, pos) > (r * 2) + 1000) {
            shouldParticlesDraw = false;
        } else {
            shouldParticlesDraw = true;
        }
    }

    // And of course, we don't want write access to this field and so it does not win, good day sir.
    boolean shouldParticlesDraw() {
        return true;
    }
}