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