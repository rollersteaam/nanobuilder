class ObserverElement{
    protected float x, y, w, h;
    protected color Colour = color(35);
    protected ObserverElement parent;
    protected ArrayList<ObserverElement> children = new ArrayList<ObserverElement>();

    protected boolean enabled = true;
    protected boolean active = true;
    protected boolean screenElement = false;
    protected boolean beingMoved = false;

    protected boolean faded = false;
    protected boolean isFading = false;
    protected int fadeStartMillis;
    protected int fadeDuration = 1000;

    public ObserverElement(float x, float y, float w, float h, color Colour, boolean startActive){
        this.Colour = Colour;
        this.x = x; this.y = y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }

    public ObserverElement(float x, float y, float w, float h, color Colour, boolean startActive, ObserverElement parent){
        parent.children.add(this);
        this.parent = parent;

        this.Colour = Colour;
        this.x = parent.x + x; this.y = parent.y + y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }

    // Through overloaded matches, this UI element will have dimensions based off percentages of its parent allowing for dynamic UI design
    // This is why ObserverElements should NOT be constructed with normal integer values unless intended to, because it will create it with a percentage relevance to its parent
    public ObserverElement(int x, int y, int w, int h, color Colour, boolean startActive, ObserverElement parent){
        parent.children.add(this);
        this.parent = parent;
        this.screenElement = parent.screenElement;

        this.Colour = Colour;
        this.x = parent.x + (parent.w * x/100); this.y = parent.y + (parent.h * y/100); this.w = (parent.w * w/100); this.h = (parent.h * h/100);
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }
    
    public ObserverElement(float x, float y, float w, float h, color Colour, boolean startActive, boolean screenElement){
        this.screenElement = screenElement;

        this.Colour = Colour;
        this.x = x; this.y = y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentScreenElements.add(this);
        UI.CurrentGUIElements.add(this);
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
}

// Extensions of ObserverElement
// UI elements that can be placed. Spatial elements mean they are 3D.

class Button extends ObserverElement{
    Event event;
    
    Button(float x, float y, float w, float h, color Colour, boolean startActive, Event event){
        super(x, y, w, h, Colour, startActive);
        UI.CurrentButtonElements.add(this);
        this.event = event;
    }
    
    Button(float x, float y, float w, float h, color Colour, boolean startActive, Event event, ObserverElement parent){
        super(x, y, w, h, Colour, startActive, parent);
        UI.CurrentButtonElements.add(this);
        
        if (parent.screenElement) {
            screenElement = true;
            UI.CurrentScreenElements.add(this);
        }
        
        this.event = event;
    }
 
    Button(int x, int y, int w, int h, color Colour, boolean startActive, Event event, ObserverElement parent){
        super(x, y, w, h, Colour, startActive, parent);
        UI.CurrentButtonElements.add(this);
        
        if (parent.screenElement) {
            screenElement = true;
            UI.CurrentScreenElements.add(this);
        }
        
        this.event = event;
    }

    void onMouseClicked(){
        event.Perform();
    }
}

class SpatialSphere extends ObserverElement {
    SpatialSphere(float x, float y, float r, color Colour, boolean startActive) {
        super(x, y, r, r, Colour, startActive);
        UI.CurrentAtoms.add(this);
    }
}