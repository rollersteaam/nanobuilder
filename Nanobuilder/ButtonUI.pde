class ButtonUI extends UIElement {
    ButtonUI(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);
    }

    @Override
    void display() {
        super.display();

        stroke(160, 160, 255, 230);
        strokeWeight(2);
        rect(position.x, position.y, size.x, size.y);

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
        
        PVector fwd = cam.getForward();
        new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 100);
    }
}