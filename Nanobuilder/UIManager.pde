class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;
    private RectangleUI inspector;

    void start() {
        contextMenu = new ContextMenu(0, 0, 180, 224 + 90 + 50, color(230));
        // inspector = new RectangleUI(width - 320, 20, 300, height - 40, color(80, 80, 255));
        inspector = uiFactory.createRect(width - 320, 20, 300, 400, color(80, 80, 255));
            UIElement thingText = uiFactory.createText(10, 5, 255, 200, color(230), "Inspector");
            inspector.appendChild(thingText);

            UIElement thing = uiFactory.createRect(20, 100, 260, 200, color(220));
            inspector.appendChild(thing);
        inspector.hide();
    }

    void draw() {
        // if (contextMenu == null) contextMenu = new ContextMenu(0, 0, 180, 224 + 90 + 50, color(230));

        for (UIElement element : screenElements) {
            if (element.getActive()) element.display();
        }
    }

    public void openInspector() {
        inspector.show();
    }

    public void closeInspector() {
        inspector.hide();
    }

    void leftClick() {
        contextMenu.hide();
    }

    void rightClick() {
        contextMenu.show();
    }

    void addElement(UIElement element) {
        screenElements.add(element);

        if (element instanceof ButtonUI) {
            buttons.add((ButtonUI) element);
        }
    }

    void removeElement(UIElement element) {
        screenElements.remove(element);

        if (element instanceof ButtonUI) {
            buttons.remove((ButtonUI) element);
        }
    }

    public void checkHoverForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse))
                button.hover();
            else
                button.unhover();
        }
    }

    public boolean checkClickForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse)) {
                button.click();
                return true;
            }
        }
        
        // Pass an interruption.
        return false;
    }

    boolean checkForFocus() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (UIElement element : screenElements) {
            if (element.checkIntersectionWithPoint(mouse))
                return true;
        }

        return false;
    }
}