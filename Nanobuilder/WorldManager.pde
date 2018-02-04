class WorldManager {
    ArrayList<Particle> particleList = new ArrayList<Particle>();

    public void registerParticle(Particle particle) {
        particleList.add(particle);
    }

    public void unregisterParticle(Particle particle) {
        particleList.remove(particle);
    }

    public Atom createAtom(PVector position) {
        return new Atom(position.x, position.y, position.z, 1);
    }

    public Atom createAtom() {
        PVector fwd = cam.getForward();
        return new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 1);
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
        drawOriginArrows();

        drawParticles();
    }

    private void drawParticles() {
        float biggestDistance = 0;

        for (int i = 0; i < particleList.size(); i++) {
            Particle particle = particleList.get(i);
            particle.evaluatePhysics();
            particle.display();

            float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

            if ((dist > biggestDistance) || (biggestDistance == 0)) {
                biggestDistance = dist;
            }
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
}