class ButtonUI extends UIElement {
    Runnable function;
    color hoverColour = color(150, 150, 255);

    ButtonUI(float x, float y, float w, float h, color colour, Runnable function) {
        super(x, y, w, h, colour);
        this.function = function;
    }

    ButtonUI(float x, float y, float w, float h, color colour, Runnable function, color strokeColour, float strokeWeight) {
        super(x, y, w, h, colour, strokeColour, strokeWeight);
        this.function = function;
    }

    @Override
    void display() {
        super.display();

        // pushStyle();
        // stroke(colour);
        // stroke(160, 160, 255, 230);
        // strokeWeight(2);
        rect(position.x, position.y, size.x, size.y);
        // popStyle();

        finishDrawing();
    }

    public void setHoverColour(color _colour) {
        hoverColour = _colour;
    }

    public void hover() {
        colour = hoverColour;
    }

    public void unhover() {
        colour = baseColour;
    }

    public void click() {
        if (!active) return;
        
        function.run();
    }
}