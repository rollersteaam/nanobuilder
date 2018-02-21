class WorldManager {
    ArrayList<Particle> particleList = new ArrayList<Particle>();
    ArrayList<AtomBond> bondList = new ArrayList<AtomBond>();
    ArrayList<Atom> atomList = new ArrayList<Atom>();

    void registerParticle(Particle particle) {
        particleList.add(particle);
    }

    void unregisterParticle(Particle particle) {
        particleList.remove(particle);
    }

    void registerBond(AtomBond bond) {
        bondList.add(bond);
    }

    void unregisterBond(AtomBond bond) {
        bondList.remove(bond);
    }

    public Atom createAtom(PVector position) {
        return new Atom(position.x, position.y, position.z, 1, 1, 0);
    }

    public Atom createAtom() {
        PVector fwd = cam.getForward();
        return new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 1, 1, 0);
    }

    public Electron createElectron(PVector position) {
        return new Electron(position.x, position.y, position.z, null);
    }

    public Electron createElectron() {
        PVector fwd = cam.getForward();
        return new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
    }

    // public void delete(Particle particle) {
    //     particle.delete();
    // }

    // Delete from selection.
    // public void delete() {
    //     particle.delete();
    // }

    // public void paint(Particle particle, color colour) {
    //     particle.setColour(colour);
    // }

    // Colour selection.
    // public void paint(color colour)

    // public void push(Particle particle, PVector position) {
    //     particle.applyForce(position, particle.mass);
    // }

    // // Push from camera.
    // public void push(Particle particle) {
    //     particle.applyForce(cam.position, particle.mass);
    // }

    // Push selection from camera.
    // public void push()

    public void createLattice(Particle particle, PVector position, int radius) {
        for (int y = 0; y < 5; y++) {
            for (int z = 0; z < 5; z++) {
                for (int x = 0; x < 5; x++) {
                    new Particle(200 * x, 200 * y, 200 * z, 100); 
                }
            }
        }
    }

    public void createBoundingBox(PVector position, float radius) {

    }

    public void edit(Particle particle) {

    }

    public void moveByMouse(Particle particle) {
        
    }

    public void stopMoveByMouse(Particle particle) {

    }

    void update() {
        drawOriginGrid();

        drawBonds();
        drawParticles();

        drawOriginArrows();
    }

    private void drawBonds() {
        for (int i = 0; i < bondList.size(); i++) {
            AtomBond bond = bondList.get(i);
            bond.display();
        }
    }

    private void drawParticles() {
        float biggestDistance = 0;

        for (int i = 0; i < particleList.size(); i++) {
            Particle particle = particleList.get(i);
            if (particle instanceof Atom) continue;
            particle.evaluatePhysics();
            particle.display();

            float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

            if ((dist > biggestDistance) || (biggestDistance == 0)) {
                biggestDistance = dist;
            }
        }

        for (int i = 0; i < atomList.size(); i++) {
            Atom atom = atomList.get(i);
            atom.evaluatePhysics();
            atom.display();
        }
    }

    private void drawOriginGrid() {
        pushStyle();
        fill(color(0, 0, 255));
        box(20, 20, 300);
        
        fill(color(0, 255, 0));
        box(20, 300, 20);

        fill(color(255, 0, 0));
        box(300, 20, 20);
        popStyle();
    }

    private void drawOriginArrows() {
        // Region boxes
        // pushStyle();
        // pushMatrix();

        // fill(255, 0, 0, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(PI/2);
        // fill(0, 0, 255, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(PI);
        // fill(255, 0, 0, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(3*PI/2);
        // fill(0, 0, 255, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();

        for (int y = 0; y < 5; y ++) {
            for (int x = 0; x < 5; x ++) {
                pushStyle();
                pushMatrix();
                rotateX(PI/2);
                stroke(255, 180);
                noFill();
                rect(100 * x, 100 * y, 100, 100);
                popMatrix();
                popStyle();
            }
        }

        for (int y = -5; y < 0; y ++) {
            for (int x = 0; x < 5; x ++) {
                pushStyle();
                pushMatrix();
                rotateX(PI/2);
                stroke(255, 180);
                noFill();
                rect(100 * x, 100 * y, 100, 100);
                popMatrix();
                popStyle();
            }
        }

        for (int y = 0; y < 5; y ++) {
            for (int x = -5; x < 0; x ++) {
                pushStyle();
                pushMatrix();
                rotateX(PI/2);
                stroke(255, 180);
                noFill();
                rect(100 * x, 100 * y, 100, 100);
                popMatrix();
                popStyle();
            }
        }

        for (int y = -5; y < 0; y ++) {
            for (int x = -5; x < 0; x ++) {
                pushStyle();
                pushMatrix();
                rotateX(PI/2);
                stroke(255, 180);
                noFill();
                rect(100 * x, 100 * y, 100, 100);
                popMatrix();
                popStyle();
            }
        }
    }

    // public static final int FIRST_QUADRANT = 1;
    // public static final int SECOND_QUADRANT = 2;
    // public static final int THIRD_QUADRANT = 3;
    // public static final int FOURTH_QUADRANT = 4;

    // public int getQuadrant(float radAng) {
    //     radAng = abs(radAng);
    //     if (radAng >= 0 && radAng < 90 || radAng == 360) {
    //         return FIRST_QUADRANT;
    //     } else if (radAng >= 90 && radAng < 180) {
    //         return SECOND_QUADRANT;
    //     } else if (radAng >= 180 && radAng < 270) {
    //         return THIRD_QUADRANT;
    //     } else if (radAng >= 270 && radAng < 360) {
    //         return FOURTH_QUADRANT;
    //     } else throw new IllegalArgumentException("Attempted to find quadrant with illegal angle argument.");
    // }
}