class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;
    private RectangleUI inspector;
    private RectangleUI toolbar;

    private TextUI mass, volume, charge, velocity, acceleration, bearing;

    void start() {
        inspector = uiFactory.createRectOutlined(width - 400, 42, 358, 568, color(38, 38, 172), color(76, 89, 255), 6);
        
            TextUI title = uiFactory.createText(0, 32, 358, 200, color(255), "Neutron", CENTER);
            // TextUI title = uiFactory.createText(0, 0, 358, 200, color(255), "Electron", CENTER);
            title.setTextSize(72);
            inspector.appendChild(title);

            TextUI fundamentalTitle = uiFactory.createText(38, 135, 358, 200, color(255), "Fundamental Properties", LEFT);
            fundamentalTitle.setTextSize(24);
            inspector.appendChild(fundamentalTitle);

            RectangleUI fundamentalGroup = uiFactory.createRectOutlined(28, 171, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI massParent = uiFactory.createText(10, 13, 200, 100, color(10), "Mass", LEFT);
                    mass = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    massParent.appendChild(mass);
                fundamentalGroup.appendChild(massParent);
                
                TextUI volumeParent = uiFactory.createText(10, 57, 200, 100, color(10), "Volume", LEFT);
                    volume = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    volumeParent.appendChild(volume);
                fundamentalGroup.appendChild(volumeParent);

                TextUI chargeParent = uiFactory.createText(10, 101, 200, 100, color(10), "Charge", LEFT);
                    charge = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    chargeParent.appendChild(charge);
                fundamentalGroup.appendChild(chargeParent);

            inspector.appendChild(fundamentalGroup);

            TextUI instanceTitle = uiFactory.createText(38, 332, 358, 200, color(255), "Instance Properties", LEFT);
            instanceTitle.setTextSize(24);
            inspector.appendChild(instanceTitle);

            RectangleUI instanceGroup = uiFactory.createRectOutlined(28, 362, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI velocityParent = uiFactory.createText(10, 18, 200, 100, color(10), "Velocity", LEFT);
                    velocity = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    velocityParent.appendChild(velocity);
                instanceGroup.appendChild(velocityParent);
                
                TextUI accelerationParent = uiFactory.createText(10, 62, 200, 100, color(10), "Acceleration", LEFT);
                    acceleration = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    accelerationParent.appendChild(acceleration);
                instanceGroup.appendChild(accelerationParent);

                TextUI bearingParent = uiFactory.createText(10, 106, 200, 100, color(10), "Bearing", LEFT);
                    bearing = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    bearingParent.appendChild(bearing);
                instanceGroup.appendChild(bearingParent);

            inspector.appendChild(instanceGroup);

        inspector.hide();

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