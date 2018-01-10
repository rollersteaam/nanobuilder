class RectangleUI extends UIElement {
    RectangleUI(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);
    }

    @Override
    void display() {
        super.display();
        // stroke(255, 160);
        rect(position.x, position.y, size.x, size.y);

        finishDrawing();
    }
}