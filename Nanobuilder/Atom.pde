class Atom extends Particle {
    Proton core;
    // ArrayList<Proton> listProtons = new ArrayList<Proton>();
    // ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();
    ArrayList<Particle> nucleus = new ArrayList<Particle>();

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();
    float orbitDistance = 10;

    public void addNeutron() {
        nucleus.add(new Neutron(500, 500, 500, this));
        distributeNucleus();
    }

    public void addProton() {
        nucleus.add(new Proton(500, 500, 500, this));
        distributeNucleus();
    }

    /*
    Using the equation for a sphere, I make a pass every 156 units in the Z axis to determine the magnitude limit
    for the circular project of the nucleus' contents. As the list is run in normal order, the core proton should
    always be the first one projected.
    */
    private void distributeNucleus() {
        int nucleusNum = nucleus.size();
        println("Number in nucleus: " + nucleusNum);
        /*
        (2 * nucleon radius)^3 results in a volume for a cube occupying the same space. <-- subject to change
        sphereRadius = cubed root of [3*number of nucleons*(2 * nucleon radius)^3 / 4 * PI]
        */
        float minNucleusRadius = pow( (3*nucleusNum*pow(156, 3)) / (4*PI) , 1f/3f);
        // for (int z = 0; z * 156 < minNucleusRadius; z++) {
        float z = -minNucleusRadius;
        println("Minimum radius of nucleus: " + minNucleusRadius);
        while (z < minNucleusRadius) {
            // squared root of [sphere radius squared - the difference in X/Z sphere traversal squared] is equal to dY.
            // This difference in Y becomes the limit that our projection method uses for all given passes.
            float planeLimit = sqrt( pow(minNucleusRadius, 2) - pow(pos.z - (pos.z + z), 2) );
            println("2D plane limit: " + planeLimit);

            int projectionLevel = 0;
            int projectionLevelLimit = 1;
            int projectionLevelCounter = 0;
            float projectionLevelMagnitude = 0;
            float projectionLevelAngSep = 0;

            // for (nucleusNum > 0; nucleusNum--) {
            int i = 0;
            while (nucleusNum > 0) {
                Particle nucleon = nucleus.get(i);
                
                nucleon.pos = PVector.add(pos, new PVector(
                        sin(projectionLevelAngSep * projectionLevelCounter) * projectionLevelMagnitude,
                        cos(projectionLevelAngSep * projectionLevelCounter) * projectionLevelMagnitude,
                        z
                    )
                );

                projectionLevelCounter++;
                nucleusNum--;
                i++;

                if (projectionLevelCounter == projectionLevelLimit) {
                    projectionLevel++;
                    projectionLevelMagnitude = projectionLevel * 156;

                    if (projectionLevelMagnitude > planeLimit) {
                        break;
                    }

                    projectionLevelLimit = ceil((2*PI*projectionLevelMagnitude)/156);
                    projectionLevelAngSep = 2*PI/projectionLevelLimit;
                    projectionLevelCounter = 0;
                }
            }

            z += 156;
        }
    }


    Atom(float x, float y, float z, int electrons) {
        super(x, y, z, 200);
        
        core = new Proton(x, y, z, this);
        nucleus.add(core);

        worldManager.atomList.add(this);

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
        shape.scale(1 / (r / 200));
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

        // if (shouldParticlesDraw) return;
        // if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // 255
            // lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / (r + 4000))
            // lerp(0, 255, (PVector.dist(cam.position, pos) / ((r*2) + 100)) )
            lerp(0, 255, (PVector.dist(cam.position, pos) - r*2) / (r*6) )
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
            recalculateRadius();
        }
    }

    public void removeElectron() {
        if (shells.size() == 0)
            println("Warning: Tried to remove an electron when there are no electron shells.");
            // throw new IllegalStateException("An atom has no electron shells.");
            
        ElectronShell lastShell = shells.get(shells.size() - 1);
        lastShell.removeElectron();

        if (lastShell.getSize() == 0) {
            shells.remove(shells.size() - 1);
            recalculateRadius();
        }
    }

    private boolean shouldParticlesDraw = false;

    /*
    This approach is used because it a) unifies the conditions all into one
    function allowing easy changes later if necessary, and b) limits the need
    to call PVector.dist 1,000 times just because every particle of an Atom wants
    to know
    */
    private void calculateShouldParticlesDraw() {
        if ((PVector.dist(cam.position, pos) - r*2) / (r*6) > 1) {
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