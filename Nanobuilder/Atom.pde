protected static class AtomHelper {
    protected static int calculateNumberOfShells(int electrons) {
        if (electrons == 0)
            throw new IllegalStateException("An atom can't have 0 electrons.");
        
        return ceil((electrons - 2) / 8) + 1;
    }
}

class Atom extends Particle {
    Proton core;
    ArrayList<Proton> listProtons = new ArrayList<Proton>();
    ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();

    Atom(float x, float y, float z, int electrons) {
        super(x, y, z, AtomHelper.calculateNumberOfShells(electrons) * 200);
        core = new Proton(x, y, z, this);
        listProtons.add(core);

        // An atom always has one shell, or it's not an atom.
        shells.add(new ElectronShell(2));
        
        for (int i = 0; i < (AtomHelper.calculateNumberOfShells(electrons) - 1); i++) {
            shells.add(new ElectronShell(8));
        }

        int remainingElectrons = electrons;
        // For every shell the atom has...
        for (int i = 0; i < shells.size(); i++) {
            // Begin to add all electrons needed to each shell.
            while (remainingElectrons > 0) {
                /*
                For every shell, add an electron, passing in i, the shell iterator.
                This shows the size of the list, and so the position if we + 1.

                Passing in the index + 1 just means the electron is projected at the
                correct distance based on the shell's 'radius'.
                */
                if (!shells.get(i).addElectron(i + 1))
                    break;
                else
                    remainingElectrons--;
            }
        }
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
    
    @Override
    void display() {
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
        // TODO: Find a way to declare this statically?
        /*
        An array of standardised vectors that can be added onto
        the atom's 'core' position and used to project electrons in a circle
        around the atom.
        */
        private final PVector[] projectionVertices = new PVector[] {
            new PVector(-100, 100, 0).normalize(),
            new PVector(0, 100, 0).normalize(),
            new PVector(100, 100, 0).normalize(),
            new PVector(100, 0, 0).normalize(),
            new PVector(100, -100, 0).normalize(),
            new PVector(0, -100, 0).normalize(),
            new PVector(-100, -100, 0).normalize(),
            new PVector(-100, 0, 0).normalize()
        };

        ElectronShell(int max) {
            this.max = max;
        }

        int getSize() {
            return contents.size();
        }

        // TODO: Store the shell number as an individual field for shells?
        boolean addElectron(int shellNumber) {
            // This shouldn't happen, but for safety...
            if (contents.size() == max) return false;

            // Initial position is not important, it will be changed immediately.
            contents.add(new Electron(0, 0, 0, core));

            int availablePosition = 0;
            for (Electron electron : contents) {
                PVector newPosition;

                if (max == 2) {
                    if (availablePosition == 0)
                        newPosition = projectionVertices[0].copy().setMag(200);
                    else
                        newPosition = projectionVertices[4].copy().setMag(200);
                } else {
                    newPosition = projectionVertices[availablePosition].copy().setMag(200 * shellNumber);
                }

                availablePosition++;

                electron.pos = PVector.add(pos, newPosition);
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

        if (!lastShell.addElectron(numberOfShells)) {
            ElectronShell newShell = new ElectronShell(8);
            shells.add(newShell);
            newShell.addElectron(numberOfShells + 1);
        }
    }

    public void removeElectron() {
        if (shells.size() == 0)
            throw new IllegalStateException("An atom has no electron shells.");
            
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
        if (PVector.dist(cam.position, pos) > (r * 2)) {
            shouldParticlesDraw = false;
        } else {
            shouldParticlesDraw = true;
        }
    }

    // And of course, we don't want write access to this field and so it does not win, good day sir.
    boolean shouldParticlesDraw() {
        return shouldParticlesDraw;
    }
}