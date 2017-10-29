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