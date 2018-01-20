protected static class AtomHelper {
    protected static int calculateNumberOfShells(int electrons) {
        if (electrons == 0)
            throw new IllegalStateException("An atom can't have 0 electrons.");
        
        return ceil((electrons - 2) / 8) + 1;
        // if (electrons - 2 <= 0) {
            // return 1;
        // } else {
        // }
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
        core = new Proton(x, y, z);
        listProtons.add(core);

        shells.add(new ElectronShell(2));

        for (int i = 0; i < (AtomHelper.calculateNumberOfShells(electrons) - 1); i++) {
            shells.add(new ElectronShell(8));
        }

        for (int i = 0; i < electrons; i++) {
            addElectron();
        }

        velocity = velocity.random3D().mult(10);
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
        this(
            random(-2000, 2000),
            random(-2000, 2000),
            random(-2000, 2000),
            // round(random(200, 600))
            1
        );
    }
    
    @Override
    void display() {
        if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            255
            // lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / (r + 4000))
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

        boolean addElectron() {
            // This shouldn't happen, but for safety...
            if (contents.size() == max)
                return false;

            // Initial position is not important, it will be changed immediately.
            contents.add(new Electron(0, 0, 0, core));

            int availablePosition = 0;
            for (Electron electron : contents) {
                PVector newPosition;

                // TODO: Make projections use a formula to support > 10 e shells.
                if (max == 2) {
                    if (availablePosition == 0)
                        newPosition = projectionVertices[0].copy().setMag(200);
                    else
                        newPosition = projectionVertices[4].copy().setMag(200);
                } else {
                    newPosition = projectionVertices[availablePosition].copy().setMag(400);
                }

                availablePosition++;

                electron.pos = PVector.add(pos, newPosition);
                // println(core);
                // println(core.calculateCoulombsLawForceOn(electron));
                // println(calculateCircularMotionInitialVelocity(core, core.calculateCoulombsLawForceOn(electron)));                
                // electron.velocity = calculateCircularMotionInitialVelocity(core, core.calculateCoulombsLawForceOn(electron));                
                electron.setInitialCircularVelocityFromForce(core, core.calculateCoulombsLawForceOn(electron));
                // println(electron.velocity);
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
        for (ElectronShell shell : shells) {
            if (shell.addElectron()) return;
        }
    }

    public void removeElectron() {
        // If atom has no shells for some reason...
        if (shells.size() == 0) return;
        shells.get(shells.size() - 1).removeElectron();
    }
}