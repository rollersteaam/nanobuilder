class ButtonUI extends UIElement {
    protected Runnable function;
    protected color hoverColour = color(150, 150, 255);
    protected boolean hovered = false;
    protected boolean pressed = false;

    protected boolean toggleable = false;
    protected boolean toggled = false;

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

    public void setToggleable(boolean isToggleable) {
        toggleable = isToggleable;
    }

    public void press() {
        if (pressed) return;
        pressed = true;

        colour = color(
            red(baseColour) - 80,
            green(baseColour) - 80,
            blue(baseColour) - 80
        );
    }

    public void unpress() {
        if (!pressed || (toggled && toggleable)) return;
        pressed = false;

        colour = baseColour;
    }

    public void hover() {
        if (hovered || pressed || (toggled && toggleable)) return;

        hovered = true;
        colour = hoverColour;
    }

    public void unhover() {
        if (!hovered || pressed || (toggled && toggleable)) return;

        hovered = false;
        colour = baseColour;
    }

    public void click() {
        if (!active) return;
        
        toggled = !toggled;
        // println(toggled);
        function.run();
    }
}