class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;
    private InspectorView inspector;
    private Toolbar toolbar;

    void start() {
        contextMenu = new ContextMenu(0, 0, 180, 224 + 90 + 50, color(230));
        inspector = new InspectorView();
        toolbar = new Toolbar();
    }

    void draw() {
        for (UIElement element : screenElements) {
            if (element.getActive()) element.display();
        }
    }

    void update() {
        inspector.updateDisplay();
        checkHoverForButtons();
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