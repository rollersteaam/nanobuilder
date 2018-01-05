/*
SelectionAgent handles the interaction of selecting
Atoms in space. It also updates the movement of all
Atoms in its possession.
*/

class SelectionAgent {
    ArrayList<Atom> selectedAtoms = new ArrayList<Atom>();
    PVector selectionIncidentVector;
    float hoveringDistanceMult = 1;

    public boolean hasActiveSelection() {
        if (selectedAtoms.size() == 0)
            return false;
        else
            return true;
    }

    public void select(Atom atom) {
        atom.select();
        selectedAtoms.add(atom);
    }

    public void cancel() {
        if (!hasActiveSelection()) return;

        for (Atom atom : selectedAtoms) {
            atom.deselect();
        }

        selectedAtoms.clear();
        selectionIncidentVector = null;
        hoveringDistanceMult = 1;
    }

    PVector selectingStartPos;
    boolean selecting;

    void startSelecting() {
        selecting = true;
        selectingStartPos = new PVector(mouseX, mouseY);
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
        }

        selecting = false;
        selectingStartPos = null;
    }

    boolean mousePressed() {
        // Case 1: Cancel selection.
        if (hasActiveSelection()) {
            cancel();
            return true;
        }

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

        // No cases passed, return and continue on the main calling routine.
        return false;
    }

    boolean mouseReleased() {
        stopSelecting();

        return false;
    }

    boolean mouseWheel(float e) {
        if (!hasActiveSelection()) return false;

        if (e > 0) // On Scroll Down
            // hoveringDistanceMult -= 0.5 * PVector.dist(cam.position, selectedAtom.pos) / 5000;
            hoveringDistanceMult -= 0.5;
        else // On Scroll Up
            // hoveringDistanceMult += 0.5 / PVector.dist(cam.position, selectedAtom.pos) * 500;
            hoveringDistanceMult += 0.5;

        return true;
    }

    /*
    While functions such as updateSelectionMovement() also use nanobuilder's draw method and
    could otherwise be routed through here, this would create a messy network of references
    that I want to avoid for now. This may change.
    */
    void draw() {
        if (selecting)
            drawRect(selectingStartPos.x, selectingStartPos.y, mouseX - selectingStartPos.x, mouseY - selectingStartPos.y, color(30, 30, 90, 80));
    }

    void updateSelectionMovement() {
        if (!hasActiveSelection()) return;
 
        PVector forward = cam.getForward();

        for (Atom atom : selectedAtoms) {
            atom.setPosition( PVector.add(cam.position, new PVector(
                // Fine tune mode
                (600 * hoveringDistanceMult) * forward.x,
                (600 * hoveringDistanceMult) * forward.y,
                (600 * hoveringDistanceMult) * forward.z )) );
                
                // Large movement mode
                // (atomIncidentVector.x) * forward.x * hoveringDistanceMult,
                // (atomIncidentVector.y) * forward.y * hoveringDistanceMult,
                // (atomIncidentVector.x) * forward.z * hoveringDistanceMult ));
            
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