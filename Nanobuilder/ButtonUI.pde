class ButtonUI extends UIElement {
    Runnable function;
    
    ButtonUI(float x, float y, float w, float h, color colour, Runnable function) {
        super(x, y, w, h, colour);
        this.function = function;
    }

    @Override
    void display() {
        super.display();

        pushStyle();
        // stroke(colour);
        stroke(160, 160, 255, 230);
        strokeWeight(2);
        rect(position.x, position.y, size.x, size.y);
        popStyle();

        finishDrawing();
    }

    public void hover() {
        colour = color(200, 200, 255);
    }

    public void unhover() {
        colour = color(200);
    }

    public void click() {
        if (!active) return;
        
        function.run();
    }
}