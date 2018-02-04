// Defining as abstract ensures UI element has to be inherited.
abstract class UIElement {
    /*
    Declare these final since the reference should NEVER change.
    
    If the references were changed to reflect another object,
    it could very easily cause a hard to detect overlapping issue
    that has potentially adverse effects.
    */
    protected PVector position;

    protected PVector size;
    protected color colour;
    protected boolean active = true;

    protected UIElement parent;
    protected ArrayList<UIElement> children = new ArrayList<UIElement>();

    color strokeColour = color(0, 0);
    float strokeWeight = 0;

    UIElement(float x, float y, float w, float h, color colour) {
        position = new PVector(x, y);
        size = new PVector(w, h);
        this.colour = colour;
    }

    UIElement(float x, float y, float w, float h, color colour, color strokeColour, float strokeWeight) {
        this(x, y, w, h, colour);
        this.strokeColour = strokeColour;
        this.strokeWeight = strokeWeight;
    }

    void display() {
        pushStyle();
        pushMatrix();
        noLights();

        strokeWeight(strokeWeight);
        stroke(strokeColour);
        fill(colour);
        /*
        Get camera's forward pointing vector and begin to draw 2D element
        at a unit vector position (so it is created right in front of the camera's view).

        Then project it by 625 so it maps properly to 'pixel' form.
        */
        // getForward() returns a normalized vector (unit vector) that is helpful to us.
        PVector projection = PVector.add(cam.position, cam.getForward().copy().mult(625));
        translate(projection.x, projection.y, projection.z);

        /*
        Make the object's rotation have a relationship with camera rotation
        so that it is 'billboarded', and therefore rotationally stationary
        with camera view.
        */
        rotateY(radians(270) - cam.pan);
        rotateX(cam.tilt);

        translate(-width/2, -height/2);
        // Any screen drawing methods are now properly mapped to the camera.
    }

    /*
    Base display can't call the pops, and to conventionalize
    the process finishDrawing() visually tells me the element
    is properly implemented.
    */
    protected void finishDrawing() {
        popStyle();
        popMatrix();
    }

    public boolean checkIntersectionWithPoint(PVector v) {
        if (!active) return false;
        if(
            v.x > position.x &&
            v.x < (position.x + size.x) &&
            v.y > position.y &&
            v.y < (position.y + size.y)
        ) {
            return true;
        } else {
            return false;
        }
    }

    public PVector getPosition() {
        return position;
    }

    public void setPosition(PVector newPosition) {
        for (UIElement child : children) {
            if (child == null) continue;

            child.setPosition(PVector.add(child.getPosition(), PVector.sub(newPosition, position)));
        }

        position = newPosition;
    }

    public PVector getSize() {
        return size;
    }

    public void setSize(PVector newSize) {
        size = newSize;
    }

    public boolean getActive() {
        return active;
    }

    public void show() {
        for (UIElement child : children) {
            if (child == null) continue;

            child.show();
        }

        active = true;
    }

    public void hide() {
        for (UIElement child : children) {
            if (child == null) continue;

            child.hide();
        }

        active = false;
    }

    public void appendChild(UIElement child) {
        children.add(child);
        child.setParent(this);
    }

    public void removeChild(UIElement child) {
        children.remove(child);
        child.removeParent();
    }

    public void setParent(UIElement parent) {
        if (parent == null) return;

        this.parent = parent;
        setPosition(PVector.add(position, parent.getPosition()));
    }

    public void removeParent() {
        if (parent == null) return;

        setPosition(PVector.sub(position, parent.getPosition()));
    }
}