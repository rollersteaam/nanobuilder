class ObserverElement2D extends ObserverElement {
    protected Vector2 pos;

    // There is no dynamic positioning function for things relative to the screen, I want it hard coded.
    // Use: A container element with static positioning relative to the screen.
    public ObserverElement2D(float x, float y, float w, float h, color colour, boolean startActive){
        super(w, h, colour, startActive);
        this.pos = new Vector2(x, y);

        ui.current2DElements.add(this);
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
    
    void tick() {
        if (!enabled || !active) return;

        if (hovered) {
            fill(red(colour) * 0.75, green(colour) * 0.75, blue(colour) * 0.75, alpha);
        } else {
            fill(colour, alpha);
        }

        stroke(strokeColour, alpha);
        rect(pos.x, pos.y, w, h);
    }
}