/*
SelectionManager handles the interaction of selecting
particles in space. It also updates the movement of all
particles in its possession.
*/

class SelectionManager {
    /*
    Selection shouldn't be used outside of the selection agent, as it pertains
    to no other context.

    Class was required to be created as the Vector from the camera to the particle position
    needed to be saved for multiple particles, so a single field to save that vector was not enough.
    */
    private class Selection {
        private final Particle particle;
        /*
        Defined a getter and declared private so read-only, if this gets changed accidently
        the reason for the field existing becomes redundant.
        */
        private final PVector fromCameraVector;

        private Selection(Particle particle) {
            this.particle = particle;
            fromCameraVector = PVector.sub(particle.pos, cam.position);
        }

        PVector getFromCameraVector() {
            return fromCameraVector.copy();
        }

        Particle getParticle() {
            return particle;
        }
    }

    ArrayList<Selection> selectedParticles = new ArrayList<Selection>();
    float hoveringDistanceMult = 1;

    public boolean hasActiveSelection() {
        if (selectedParticles.size() == 0)
            return false;
        else
            return true;
    }

    public void push() {
        for (Selection selection : selectedParticles) {
            Particle object = selection.getParticle();
            object.applyForce(cam.position, object.mass);
        }
    }

    public Particle getObjectFromSelection() {
        int selSize = selectedParticles.size();
        if (selSize == 0 || selSize > 1) return null;

        Selection selection = selectedParticles.get(0);
        
        if (selection.getParticle().deleted) return null;

        return selection.getParticle();
    }

    public ArrayList<Particle> getObjectsFromSelection() {
        if (selectedParticles.size() == 0) return null;

        ArrayList<Particle> list = new ArrayList<Particle>();

        for (Selection selection : selectedParticles) {
            if (selection.getParticle().deleted) {
                continue;
            }
            list.add(selection.getParticle());
        }

        return list;
    }

    public boolean select(Particle particle) {
        if (particle == null) {
            println("URGENT: SelectionManager was requested to select a null reference.");
            Thread.dumpStack();
            return false;
        }

        if (particle.select()) {
            selectedParticles.add(new Selection(particle));

            uiManager.openInspector();

            return true;
        }

        return false;
    }

    public void cancel() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().deselect();
        }

        uiManager.closeInspector();
        selectedParticles.clear();
        hoveringDistanceMult = 1;
    }

    public void delete() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().delete();
        }

        cancel();
    }

    public void paint() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().setColour(color(255, 0, 0));
        }

        cancel();
    }

    PVector selectingStartPos;
    RectangleUI groupSelection;

    void startSelecting() {
        cancel();
        selectingStartPos = new PVector(mouseX, mouseY);
        groupSelection = uiFactory.createRectOutlined(selectingStartPos.x, selectingStartPos.y, 1, 1, color(30, 30, 90, 80), color(10, 10, 40, 80), 4);
    }

    boolean stopSelecting() {
        if (selectingStartPos == null) return false;

        PVector lowerBoundary = new PVector(selectingStartPos.x, selectingStartPos.y);
        PVector higherBoundary = new PVector(mouseX, mouseY);
        boolean particleFound = false;

        /*
        Iterate through all existing particles and compare their screen coordinates
        to the selected screen area for all 4 cases, selecting all particles that
        intersect with the area.
        */
        for (Particle particle : worldManager.particleList) {
            float screenPosX = screenX(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosXNegativeLimit = screenX(particle.pos.x - particle.r, particle.pos.y, particle.pos.z);
            float screenPosXPositiveLimit = screenX(particle.pos.x + particle.r, particle.pos.y, particle.pos.z);
            
            float screenPosY = screenY(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosYNegativeLimit = screenY(particle.pos.x, particle.pos.y - particle.r, particle.pos.z);
            float screenPosYPositiveLimit = screenY(particle.pos.x, particle.pos.y + particle.r, particle.pos.z);
            
            float screenPosZ = screenZ(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosZNegativeLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z - particle.r);
            float screenPosZPositiveLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z + particle.r);

            // From top left to bottom right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }
            
            // From bottom left to top right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // From bottom right to top left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // From top right to bottom left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // TODO: Investigate if Z values are accounted for in group selection.
        }

        selectingStartPos = null;
        uiManager.removeElement(groupSelection);
        groupSelection = null;

        return particleFound;
    }

    Particle checkPointAgainstParticleIntersection(PVector v1) {
        for (Particle particle : worldManager.particleList) {
            float screenPosX = screenX(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosXNegativeLimit = screenX(particle.pos.x - particle.r, particle.pos.y, particle.pos.z);
            float screenPosXPositiveLimit = screenX(particle.pos.x + particle.r, particle.pos.y, particle.pos.z);
            
            float screenPosY = screenY(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosYNegativeLimit = screenY(particle.pos.x, particle.pos.y - particle.r, particle.pos.z);
            float screenPosYPositiveLimit = screenY(particle.pos.x, particle.pos.y + particle.r, particle.pos.z);
            
            float screenPosZ = screenZ(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosZNegativeLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z - particle.r);
            float screenPosZPositiveLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z + particle.r);

            if (v1.x >= screenPosXNegativeLimit && v1.x <= screenPosXPositiveLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (v1.x >= screenPosXPositiveLimit && v1.x <= screenPosXNegativeLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            if (v1.x >= screenPosZNegativeLimit && v1.x <= screenPosZPositiveLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (v1.x >= screenPosZPositiveLimit && v1.x <= screenPosZNegativeLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }
        }

        return null;
    }

    boolean mousePressed() {
        // Pass 1
        Particle attemptedSelection = checkPointAgainstParticleIntersection(new PVector(mouseX, mouseY));
        if (attemptedSelection != null) {
            cancel();
            select(attemptedSelection);
        } else {
            startSelecting();
        }

        // No interrupts passed, return and continue on the main calling routine.
        return false;
    }

    boolean mouseReleased() {
        // Pass 1
        /*
        If a click selection was processed before, then we don't want to cancel the
        selection this frame, regardless of if a group selection had returned no particles.
        */
        stopSelecting();

        // If active selection, cancel, but only if mouseX is not over an existing particle.
        // if (!selectionWasAttempted) cancel();

        return false;
    }

    boolean mouseWheel(float e) {
        if (!hasActiveSelection()) return false;

        if (e > 0) // On Scroll Down
            // hoveringDistanceMult -= 0.5 * PVector.dist(cam.position, selectedparticle.pos) / 5000;
            hoveringDistanceMult -= 0.25;
        else // On Scroll Up
            // hoveringDistanceMult += 0.5 / PVector.dist(cam.position, selectedparticle.pos) * 500;
            hoveringDistanceMult += 0.25;

        return true;
    }

    void updateGroupSelectionDrawing() {
        if (groupSelection == null) return;

        groupSelection.setSize(new PVector(mouseX - selectingStartPos.x, mouseY - selectingStartPos.y));
    }

    void updateSelectionMovement() {
        if (!hasActiveSelection()) return;
 
        PVector forward = cam.getForward();

        // float dist = PVector.dist(cam.position, fromCameraVector);

        for (Selection selection : selectedParticles) {
            Particle particle = selection.getParticle();
            // fromCameraVector = PVector.sub(particle.pos, cam.position);
            // Normalize a copy, don't want to change the original reference otherwise that would occur every frame.
            // PVector fromCameraVectorNormalized = fromCameraVector.copy().normalize();

            // float yDistMul = PVector.dist(cam.position, particle.pos) / 900;
            // float xDistMul = PVector.dist(cam.position, particle.pos) / 500;

            // PVector cross = cam.position.copy().cross(particle.pos).normalize();

            // PVector normalizationConstant = new PVector(
            //     // map(mouseX, 0, width, -1, 1),
            //     0,
            //     map(mouseY, 0, width, -1, 1),
            //     map(mouseX, 0, width, -1, 1)
            // );

            // particle.addPosition( PVector.add(cam.position, new PVector(
            //     // Fine tune mode
            //     (600 * hoveringDistanceMult) * forward.x,
            //     (600 * hoveringDistanceMult) * forward.y,
            //     (600 * hoveringDistanceMult) * forward.z )) );
                // (hoveringDistanceMult) * selection.getFromCameraVector().x,
                // (hoveringDistanceMult) * selection.getFromCameraVector().y,
                // (hoveringDistanceMult) * selection.getFromCameraVector().z )) );
            
            // The changes given by the mouse need to be added to the constant difference
            // fromCameraVector.add(new PVector(
                // (mouseX - pmouseX) * xDistMul * fromCameraVectorNormalized.x,
                // (mouseY - pmouseY) * yDistMul,
                // (mouseX - pmouseX) * xDistMul
                // ));

            // Selection Guide //
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    pushStyle();
                    
                    translate(particle.pos.x - particle.r, particle.pos.y, particle.pos.z - particle.r);
                    rotateX(PI/2);
                    stroke(0, 255, 255, 180);
                    noFill();
                    
                    rect((particle.r * 2 * x)/5, (particle.r * 2 * y)/5, (particle.r * 2)/5, (particle.r * 2)/5);
                    popStyle();
                    popMatrix();
                }
            }
            
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    pushStyle();
                    
                    translate(particle.pos.x, particle.pos.y - particle.r, particle.pos.z + particle.r);
                    rotateY(PI/2);
                    stroke(0, 255, 255, 180);
                    noFill();
                    
                    rect((particle.r * 2 * x)/5, (particle.r * 2 * y)/5, (particle.r * 2)/5, (particle.r * 2)/5);
                    popStyle();
                    popMatrix();
                }
            }
        }
    }
}