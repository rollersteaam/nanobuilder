class TextUI extends UIElement {
    private String text;

    TextUI(float x, float y, float w, float h, color colour, String text) {
        super(x, y, w, h, colour);
        this.text = text;
    }

    @Override
    void display() {
        super.display();

        textSize(18);
        text(text, position.x, position.y, size.x, size.y);

        finishDrawing();
    }
}