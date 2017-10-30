class ObserverElement3D extends ObserverElement {
    protected Vector3 pos;

    // Use: An initial parent element that governs a chain. Its children are not positioned relatively but are BOUND.
    public ObserverElement3D(float x, float y, float z, float w, float h, color colour, boolean startActive){
        super(w, h, colour, startActive);
        this.pos = new Vector3(x, y, z);

        ui.current3DElements.add(this);
    }

    // Use: A child element that is not positioned relatively. Its movement is BOUND to its parent.
    public ObserverElement3D(float x, float y, float z, float w, float h, color colour, boolean startActive, ObserverElement3D parent){
        this(x, y, z, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);
    }

    // Returns coordinates of the starting positions of an object boundary in CARTESIAN method.
    Vector2 WorldStartToScreenSpace() {
        float tempX = screenX(pos.x, pos.y, pos.z);
        float tempY = screenY(pos.x, pos.y, pos.z);
        return new Vector2(tempX, tempY);
    }

    // Returns coordinates of the ending positions of an object boundary in CARTESIAN method.
    Vector2 WorldEndToScreenSpace() {
        float tempX = screenX(pos.x + w, pos.y, pos.z);
        float tempY = screenY(pos.x, pos.y + h, pos.z);
        return new Vector2(tempX, tempY);
    }
    
    void tick() {
        if (!enabled || !active) return;
        
        pushMatrix();

        if (beingMoved) {
            stroke(strokeColour, alpha);

            Vector3 lastWorldMouse = camera.ScreenPosToWorldPos(ui.lastMouseX, ui.lastMouseY);
            Vector3 worldMouse = camera.ScreenPosToWorldPos(mouseX, mouseY);
            //target.pos.x += mouseX - lastMouseX;
            pos.x += worldMouse.x - lastWorldMouse.x;
            //target.pos.y += mouseY - lastMouseY;
            pos.y += worldMouse.y - lastWorldMouse.y;

        } else if (hovered) {
            stroke(strokeColour, alpha / 2);
        } else {
            noStroke();
        }

        translate(pos.x, pos.y, pos.z);
        sphere(w);

        popMatrix();
    }
}