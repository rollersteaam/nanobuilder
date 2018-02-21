class ElectronShell {
    private Atom containingAtom;
    private ArrayList<Electron> contents = new ArrayList<Electron>();
    private int max;
    private int shellNumber;

    ElectronShell(Atom containingAtom, int max, int shellNumber) {
        this.containingAtom = containingAtom;
        this.max = max;
        this.shellNumber = shellNumber;            
    }

    void delete() {
        for (Electron electron : contents) {
            electron.delete();
        }

        contents.clear();
        containingAtom = null;
    }

    int getSize() {
        return contents.size();
    }

    public float getMass() {
        float mass = 0;

        for (Electron electron : contents) {
            mass += electron.mass;
        }

        return mass;
    }

    Electron addElectron() {
        // This will probably only occur when a new shell needs creating, but SRP means it's implemented here.
        if (contents.size() == max) return null;

        // Initial position is not important, it will be changed immediately.
        Electron newElectron = new Electron(0, 0, 0, containingAtom.core);
        contents.add(newElectron);
        redistribute();

        return newElectron;
    }

    boolean removeElectron(Electron electron) {
        for (Electron _electron : contents) {
            if (_electron == electron) {
                contents.remove(_electron);

                if (contents.size() == 0)
                    containingAtom.remove(this);

                return true;
            }
        }

        return false;
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

    void redistribute() {
        int totalElectrons = contents.size();
        float angularSeperation = (2 * PI) / totalElectrons;

        for (int i = 0; i < totalElectrons; i++) {
            Electron electron = contents.get(i);

            float angle = angularSeperation * i;

            if (shellNumber % 2 == 1)
                electron.pos = PVector.add(containingAtom.pos, new PVector(sin(angle), cos(angle), 0).setMag(containingAtom.orbitOffset + containingAtom.nucleusRadius + 200 * shellNumber) );
            else
                electron.pos = PVector.add(containingAtom.pos, new PVector(sin(angle), 0, cos(angle)).setMag(containingAtom.orbitOffset + containingAtom.nucleusRadius + 200 * shellNumber) );
                
            electron.setInitialCircularVelocityFromForce(containingAtom.core, containingAtom.core.calculateCoulombsLawForceOn(electron));
        }
    }
}

