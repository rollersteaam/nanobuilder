class NewAtomTool extends Tool {
    boolean press() {
        return false;
    }

    boolean click() {
        return (worldManager.createAtom() == null) ? false : true;
    }
}