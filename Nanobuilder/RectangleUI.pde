class RectangleUI extends UIElement {
    RectangleUI(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);
    }

    RectangleUI(float x, float y, float w, float h, color colour, color strokeColour, float strokeWeight) {
        super(x, y, w, h, colour, strokeColour, strokeWeight);
    }

    @Override
    void display() {
        super.display();

        rect(position.x, position.y, size.x, size.y, 0, 0, 0, 0);

        finishDrawing();
    }
}