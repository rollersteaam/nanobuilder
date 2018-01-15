/*
SelectionManager handles the interaction of selecting
Atoms in space. It also updates the movement of all
Atoms in its possession.
*/

class SelectionManager {
    /*
    Selection shouldn't be used outside of the selection agent, as it pertains
    to no other context.

    Class was required to be created as the Vector from the camera to the atom position
    needed to be saved for multiple atoms, so a single field to save that vector was not enough.
    */
    private class Selection {
        private final Atom atom;
        /*
        Defined a getter and declared private so read-only, if this gets changed accidently
        the reason for the field existing becomes redundant.
        */
        private final PVector fromCameraVector;

        private Selection(Atom atom) {
            this.atom = atom;
            fromCameraVector = PVector.sub(atom.pos, cam.position);
        }

        PVector getFromCameraVector() {
            return fromCameraVector.copy();
        }

        Atom getAtom() {
            return atom;
        }
    }

    ArrayList<Selection> selectedAtoms = new ArrayList<Selection>();
    float hoveringDistanceMult = 1;

    public boolean hasActiveSelection() {
        if (selectedAtoms.size() == 0)
            return false;
        else
            return true;
    }

    public void select(Atom atom) {
        if (atom == null) {
            println("URGENT: SelectionManager was requested to select a null reference.");
            Thread.dumpStack();
            return;
        }

        atom.select();
        selectedAtoms.add(new Selection(atom));
    }

    public void cancel() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedAtoms) {
            selection.getAtom().deselect();
        }

        selectedAtoms.clear();
        hoveringDistanceMult = 1;
    }

    public void deleteItemsInSelection() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedAtoms) {
            selection.getAtom().delete();
        }

        cancel();
    }

    public void paintAtoms() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedAtoms) {
            selection.getAtom().setColour(color(255, 0, 0));
        }

        cancel();
    }

    PVector selectingStartPos;
    RectangleUI groupSelection;

    void startSelecting() {
        selectingStartPos = new PVector(mouseX, mouseY);
        groupSelection = uiFactory.createRect(selectingStartPos.x, selectingStartPos.y, 1, 1, color(30, 30, 90, 80));
    }

    void stopSelecting() {
        if (selectingStartPos == null) return;

        PVector lowerBoundary = new PVector(selectingStartPos.x, selectingStartPos.y);
        PVector higherBoundary = new PVector(mouseX, mouseY);

        /*
        Iterate through all existing atoms and compare their screen coordinates
        to the selected screen area for all 4 cases, selecting all atoms that
        intersect with the area.
        */
        for (Atom atom : atomList) {
            float screenPosX = screenX(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosXNegativeLimit = screenX(atom.pos.x - atom.r, atom.pos.y, atom.pos.z);
            float screenPosXPositiveLimit = screenX(atom.pos.x + atom.r, atom.pos.y, atom.pos.z);
            
            float screenPosY = screenY(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosYNegativeLimit = screenY(atom.pos.x, atom.pos.y - atom.r, atom.pos.z);
            float screenPosYPositiveLimit = screenY(atom.pos.x, atom.pos.y + atom.r, atom.pos.z);
            
            float screenPosZ = screenZ(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosZNegativeLimit = screenZ(atom.pos.x, atom.pos.y, atom.pos.z - atom.r);
            float screenPosZPositiveLimit = screenZ(atom.pos.x, atom.pos.y, atom.pos.z + atom.r);

            // From top left to bottom right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit)
                select(atom);
            
            // From bottom left to top right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit)
                select(atom);

            // From bottom right to top left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit)
                select(atom);

            // From top right to bottom left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit)
                select(atom);

            // TODO: Investigate if Z values are accounted for in group selection.
        }

        selectingStartPos = null;
        uiManager.removeElement(groupSelection);
        groupSelection = null;
    }

    boolean mousePressed() {
        // Case 2: Find a single Atom at clicking location.
        for (Atom atom : atomList) {
            float screenPosX = screenX(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosXNegativeLimit = screenX(atom.pos.x - atom.r, atom.pos.y, atom.pos.z);
            float screenPosXPositiveLimit = screenX(atom.pos.x + atom.r, atom.pos.y, atom.pos.z);
            
            float screenPosY = screenY(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosYNegativeLimit = screenY(atom.pos.x, atom.pos.y - atom.r, atom.pos.z);
            float screenPosYPositiveLimit = screenY(atom.pos.x, atom.pos.y + atom.r, atom.pos.z);
            
            float screenPosZ = screenZ(atom.pos.x, atom.pos.y, atom.pos.z);
            float screenPosZNegativeLimit = screenZ(atom.pos.x, atom.pos.y, atom.pos.z - atom.r);
            float screenPosZPositiveLimit = screenZ(atom.pos.x, atom.pos.y, atom.pos.z + atom.r);

            if (mouseX >= screenPosXNegativeLimit && mouseX <= screenPosXPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(atom);
                return true;
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (mouseX >= screenPosXPositiveLimit && mouseX <= screenPosXNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(atom);
                return true;
            }

            if (mouseX >= screenPosZNegativeLimit && mouseX <= screenPosZPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(atom);
                return true;
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (mouseX >= screenPosZPositiveLimit && mouseX <= screenPosZNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(atom);
                return true;
            }
        }



        // Case 3: Begin an area selection.
        startSelecting();

        // No interrupts passed, return and continue on the main calling routine.
        return false;
    }

    boolean mouseReleased() {
        // // Case 1: Cancel selection.
        // if (hasActiveSelection()) {
        //     cancel();
        //     // return true;
        // }

        if (hasActiveSelection()) {
            cancel();
            // return true;
        }

        stopSelecting();

        return false;
    }

    boolean mouseWheel(float e) {
        if (!hasActiveSelection()) return false;

        if (e > 0) // On Scroll Down
            // hoveringDistanceMult -= 0.5 * PVector.dist(cam.position, selectedAtom.pos) / 5000;
            hoveringDistanceMult -= 0.25;
        else // On Scroll Up
            // hoveringDistanceMult += 0.5 / PVector.dist(cam.position, selectedAtom.pos) * 500;
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

        for (Selection selection : selectedAtoms) {
            Atom atom = selection.getAtom();
            // fromCameraVector = PVector.sub(atom.pos, cam.position);
            // Normalize a copy, don't want to change the original reference otherwise that would occur every frame.
            // PVector fromCameraVectorNormalized = fromCameraVector.copy().normalize();

            // float yDistMul = PVector.dist(cam.position, atom.pos) / 900;
            // float xDistMul = PVector.dist(cam.position, atom.pos) / 500;

            // PVector cross = cam.position.copy().cross(atom.pos).normalize();

            // PVector normalizationConstant = new PVector(
            //     // map(mouseX, 0, width, -1, 1),
            //     0,
            //     map(mouseY, 0, width, -1, 1),
            //     map(mouseX, 0, width, -1, 1)
            // );

            // atom.setPosition( PVector.add(cam.position, new PVector(
                // Fine tune mode
                // (600 * hoveringDistanceMult) * forward.x,
                // (600 * hoveringDistanceMult) * forward.y,
                // (600 * hoveringDistanceMult) * forward.z )) );
                // (hoveringDistanceMult) * selection.getFromCameraVector().x,
                // (hoveringDistanceMult) * selection.getFromCameraVector().y,
                // (hoveringDistanceMult) * selection.getFromCameraVector().z )) );
            
            // The changes given by the mouse need to be added to the constant difference
            // fromCameraVector.add(new PVector(
                // (mouseX - pmouseX) * xDistMul * fromCameraVectorNormalized.x,
                // (mouseY - pmouseY) * yDistMul,
                // (mouseX - pmouseX) * xDistMul
                // ));

            // Picking guide //
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    
                    translate(atom.pos.x - 250, atom.pos.y, atom.pos.z - 250);
                    rotateX(PI/2);
                    stroke(255, 180);
                    noFill();
                    
                    rect(100 * x, 100 * y, 100, 100);
                    popMatrix();
                }
            }
            
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    
                    translate(atom.pos.x, atom.pos.y - 250, atom.pos.z + 250);
                    rotateY(PI/2);
                    stroke(255, 180);
                    noFill();
                    
                    rect(100 * x, 100 * y, 100, 100);
                    popMatrix();
                }
            }
        }
    }
}