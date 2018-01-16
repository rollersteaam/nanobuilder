class ContextMenu extends UIElement {
    RectangleUI mainPanel;
    ButtonUI testButton;
    TextUI testText;

    Runnable createAtomAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            new Particle(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 100);
        }
    };

    Runnable createElectronAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
        }
    };

    Runnable deleteItemsInSelection = new Runnable() {
        public void run() {
            selectionManager.deleteItemsInSelection();
        }
    };

    Runnable paintAtom = new Runnable() {
        public void run() {
            selectionManager.paintParticles();
        }
    };

    ContextMenu(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(3, 3, w + 4, h + 4, color(135));
        mainPanel = uiFactory.createRect(1, 1, w, h, colour);

        testButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0), createAtomAtCamera);
        testText = uiFactory.createText(w/4, 40/4 + 2.5, w - 12, 38, color(70), "Add Atom");
        
        UIElement testButton2 = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0), deleteItemsInSelection);
        UIElement testText2 = uiFactory.createText(w/4, 40/4 + 2.5 + 40 + 4, w - 12, 38, color(70), "Delete");

        appendChild(background);

        appendChild(mainPanel);
        appendChild(testButton);
        appendChild(testText);

        appendChild(testButton2);
        appendChild(testText2);

        UIElement paint = uiFactory.createButton(5, 5 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 255, 0), paintAtom);
        UIElement paintText = uiFactory.createText(34, 8, w - 12, 38, color(70), "Paint Red");
        paint.appendChild(paintText);

        appendChild(paint);
        UIElement electron = uiFactory.createButton(5, 5 + 40 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 0, 255), createElectronAtCamera);
        UIElement electronText = uiFactory.createText(32, 8, w - 12, 38, color(70), "Create Electron");
        electron.appendChild(electronText);

        appendChild(electron);
        
        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}