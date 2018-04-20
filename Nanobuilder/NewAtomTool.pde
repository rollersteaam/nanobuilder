class NewAtomTool extends Tool {
    boolean press() {
        return true;
    }

    boolean click() {
        return (worldManager.createAtom() == null) ? false : true;
    }
}