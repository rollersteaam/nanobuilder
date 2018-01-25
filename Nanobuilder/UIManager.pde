class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;

    void draw() {
        if (contextMenu == null) contextMenu = new ContextMenu(0, 0, 180, 224, color(230));

        for (UIElement element : screenElements) {
            if (element.getActive()) element.display();
        }
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

    public void checkClickForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse)) button.click();
        }
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