class SelectionTool extends Tool {
    boolean press() {
        return selectionManager.mousePressed();
    }

    boolean click() {
        return selectionManager.mouseReleased();
    }
}