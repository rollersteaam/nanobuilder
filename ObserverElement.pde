class Vector2 {
    public float x;
    public float y;

    public Vector2(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

class Vector3 {
    public float x;
    public float y;
    public float z;

    public Vector3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

class ObserverElement{
    protected float w, h;
    protected color colour = color(35);
    protected color strokeColour = color(30);
    protected int alpha = 255;

    protected ObserverElement parent;
    protected ArrayList<ObserverElement> children = new ArrayList<ObserverElement>();

    protected boolean enabled = true;
    protected boolean active = true;

    protected boolean screenElement = false;
    protected boolean beingMoved = false;
    protected boolean hovered = false;

    protected boolean faded = false;
    protected boolean isFading = false;
    protected int fadeStartMillis;
    protected int fadeDuration = 1000;

    ObserverElement(float w, float h, color colour, boolean startActive) {
        this.w = w;
        this.h = h;

        this.colour = colour;
        this.active = startActive;
        this.faded = !this.active;

        UI.currentGUIElements.add(this);
    }

    void setAlpha(int val) {
       alpha = val;

       if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).setAlpha(val);
            }
        }
    }

    void toggleActive(){
        active = !active;

        // If has children, iterate and turn all to same state as its parent.
        if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).active = active;
                children.get(i).faded = !active; // in the event a fade is later used, make sure variable is calibrated
            }
        }
    }

    void fadeToggleActive(int milli) { // transition effect
        isFading = true;
        fadeStartMillis = millis();
        fadeDuration = milli;

        if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).fadeToggleActive(milli);
            }
        }
    }

    void onMouseHover() {
        this.hovered = true;
    }
}

class ObserverElement2D extends ObserverElement {
    protected Vector2 pos;

    // There is no dynamic positioning function for things relative to the screen, I want it hard coded.
    // Use: A container element with static positioning relative to the screen.
    public ObserverElement2D(float x, float y, float w, float h, color colour, boolean startActive){
        super(w, h, colour, startActive);
        this.pos = new Vector2(x, y);

        UI.current2DElements.add(this);
    }

    // Use: A child element with STATIC relative positioning in a container.
    public ObserverElement2D(float x, float y, float w, float h, color colour, boolean startActive, ObserverElement2D parent){
        this(x, y, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);

        this.pos.x += parent.pos.x;
        this.pos.y += parent.pos.y;
    }

    // Use: A child element with DYNAMIC relative positioning in a container.
    public ObserverElement2D(int x, int y, int w, int h, color colour, boolean startActive, ObserverElement2D parent){
        this(x, y, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);

        this.pos.x = parent.pos.x + (parent.w * x/100);
        this.pos.y = parent.pos.y + (parent.h * y/100);
        this.w = (parent.w * w/100);
        this.h = (parent.h * h/100);
    }
}

class ObserverElement3D extends ObserverElement {
    protected Vector3 pos;

    // Use: An initial parent element that governs a chain. Its children are not positioned relatively but are BOUND.
    public ObserverElement3D(float x, float y, float z, float w, float h, color colour, boolean startActive){
        super(w, h, colour, startActive);
        this.pos = new Vector3(x, y, z);

        UI.current3DElements.add(this);
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
}

// Extensions of ObserverElement
// UI elements that can be placed. Spatial elements mean they are 3D.

// UI Element: Menu
// CONTAINER
// Exclusively a container element, it will overlap menus that were drawn before it, and overlap ALL other elements.
class Menu extends ObserverElement2D {
    Menu(float x, float y, float w, float h, color colour, boolean startActive){
        super(x, y, w, h, colour, startActive);
    }

    Menu(float x, float y, float w, float h, color colour, boolean startActive, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
    }

    Menu(int x, int y, int w, int h, color colour, boolean startActive, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
    }
}

// UI Element: Button
// ITEM - ACTIVATOR
// Supports effector functions (onHover, onClick). Drawn as a 2D rectangle.
// TODO: Implement image and styling functionality.
class Button extends ObserverElement2D {
    protected Function event;

    Button(float x, float y, float w, float h, color colour, boolean startActive, Function event){
        super(x, y, w, h, colour, startActive);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    Button(float x, float y, float w, float h, color colour, boolean startActive, Function event, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    Button(int x, int y, int w, int h, color colour, boolean startActive, Function event, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    void onMouseClicked(){
        event.Call();
    }
}

// OBJECT Element: Sphere
// WORLD
// Can be bonded to other 3D elements, BINDING its movement.
// TODO: Add further properties.
class SpatialSphere extends ObserverElement3D {
    SpatialSphere(float x, float y, float z, float r, color colour, boolean startActive) {
        super(x, y, z, r, r, colour, startActive);
        UI.currentAtoms.add(this);
    }

    SpatialSphere(float x, float y, float z, float r, color colour, boolean startActive, ObserverElement3D parent) {
        super(x, y, z, r, r, colour, startActive, parent);
        UI.currentAtoms.add(this);
    }

    // Returns coordinates of the starting positions of an object boundary in CARTESIAN method.
    @Override // Overriden because sphere's drawing method doesn't act in a "cartesian" way and spills "negatively".
    Vector2 WorldStartToScreenSpace() {
        float tempX = screenX(pos.x - w, pos.y, pos.z);
        float tempY = screenY(pos.x, pos.y - h, pos.z);
        return new Vector2(tempX, tempY);
    }
}