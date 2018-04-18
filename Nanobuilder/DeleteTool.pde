class DeleteTool extends Tool {
    boolean press() {
        return selectionManager.mousePressed();
    }

    boolean click() {
        selectionManager.mouseReleased();

        if (!selectionManager.hasActiveSelection())
            return false;

        Particle object = selectionManager.getObjectFromSelection();
        
        if (object != null) {
            object.delete();
            selectionManager.cancel();
            return true;
        }

        ArrayList<Particle> objects = selectionManager.getObjectsFromSelection();

        for (Particle particle : objects) {
            particle.delete();
        }

        selectionManager.cancel();

        return true;
    }
}