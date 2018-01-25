class ContextMenu extends UIElement {
    RectangleUI mainPanel;
    ButtonUI testButton;
    TextUI testText;

    Runnable createAtomAtCamera = new Runnable() {
        public void run() {
            selectionManager.cancel();
            PVector fwd = cam.getForward();
            Atom newAtom = new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 1);
            selectionManager.select(newAtom);
        }
    };

    Runnable createElectronAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            Electron newElectron = new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
            selectionManager.select(newElectron);
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

    Runnable pushAtom = new Runnable() {
        public void run() {
            selectionManager.pushAllObjectsFromCamera();
        }
    };

    ContextMenu(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(-3, -3, w + 4 + 3, h + 4 + 3, color(135));
        appendChild(background);

        mainPanel = uiFactory.createRect(1, 1, w, h, colour);
        appendChild(mainPanel);

        testButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0), createAtomAtCamera);
        testText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Add Atom");
        testButton.appendChild(testText);
        appendChild(testButton);

        UIElement testButton2 = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0), deleteItemsInSelection);
        UIElement testText2 = uiFactory.createText(16, 8, w - 12, 38, color(70), "Delete");
        testButton2.appendChild(testText2);
        appendChild(testButton2);

        UIElement paint = uiFactory.createButton(5, 5 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 255, 0), paintAtom);
        UIElement paintText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Paint Red");
        paint.appendChild(paintText);
        appendChild(paint);

        UIElement electron = uiFactory.createButton(5, 5 + 40 + 40 + 40 + 4 + 4 + 4, w - 8, 40, color(0, 0, 255), createElectronAtCamera);
        UIElement electronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Create Electron");
        electron.appendChild(electronText);
        appendChild(electron);

        UIElement push = uiFactory.createButton(5, 173 + 4 + 4, w - 8, 40, color(0, 0, 255), pushAtom);
        UIElement pushText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Push");
        push.appendChild(pushText);
        appendChild(push);
        
        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}