class TextUI extends UIElement {
    private String text;
    private float textSize = 18;
    private int alignment;

    TextUI(float x, float y, float w, float h, color colour, String text, int alignment) {
        super(x, y, w, h, colour);
        this.text = text;
        this.alignment = alignment;
    }

    public void setTextSize(float newTextSize) {
        textSize = newTextSize;
    }

    @Override
    void display() {
        super.display();

        textAlign(alignment);
        textFont(uiFont, textSize);
        textSize(textSize);
        text(text, position.x, position.y, size.x, size.y);

        finishDrawing();
    }
}