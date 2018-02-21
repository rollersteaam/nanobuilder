class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;
    private InspectorView inspector;
    private RectangleUI toolbar;

    void start() {
        inspector = new InspectorView();

        Runnable fooAction = new Runnable() {
            public void run() {
                println("Button clicked");
            }
        };

        toolbar = uiFactory.createRectOutlined(42, 42, 64, height - 84, color(38, 38, 172), color(76, 89, 255), 6);

            ButtonUI toolbarFooButton1 = uiFactory.createButtonOutlined(16, 16, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton1.setHoverColour(color(224, 99, 23));
            toolbar.appendChild(toolbarFooButton1);
            ButtonUI toolbarFooButton2 = uiFactory.createButtonOutlined(16, 64, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton2.setHoverColour(color(224, 99, 23));
            toolbar.appendChild(toolbarFooButton2);
            ButtonUI toolbarFooButton3 = uiFactory.createButtonOutlined(16, 112, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton3.setHoverColour(color(224, 99, 23));
            toolbar.appendChild(toolbarFooButton3);
            ButtonUI toolbarFooButton4 = uiFactory.createButtonOutlined(16, 160, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton4.setHoverColour(color(224, 99, 23));
            toolbar.appendChild(toolbarFooButton4);

        contextMenu = new ContextMenu(0, 0, 180, 224 + 90 + 50, color(230));
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