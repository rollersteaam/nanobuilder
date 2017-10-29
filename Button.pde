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