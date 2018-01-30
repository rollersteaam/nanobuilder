class ContextMenu extends UIElement {
    RectangleUI mainPanel;

    Runnable createAtomAtCamera = new Runnable() {
        public void run() {
            selectionManager.cancel();
            PVector fwd = cam.getForward();
            Atom newAtom = new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 1);
            selectionManager.select(newAtom);
            hide();
        }
    };

    Runnable createElectronAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            Electron newElectron = new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
            selectionManager.select(newElectron);
            hide();
        }
    };

    Runnable deleteItemsInSelection = new Runnable() {
        public void run() {
            selectionManager.deleteItemsInSelection();
            hide();
        }
    };

    Runnable paintAtom = new Runnable() {
        public void run() {
            selectionManager.paintParticles();
            hide();
        }
    };

    Runnable pushAtom = new Runnable() {
        public void run() {
            selectionManager.pushAllObjectsFromCamera();
            hide();
        }
    };

    Runnable insertElectronAtom = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;
            
            ((Atom) object).addElectron();
            hide();
        }
    };

    Runnable removeElectronAtom = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;

            ((Atom) object).removeElectron();
            hide();
        }
    };

    ContextMenu(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(-3, -3, w + 4 + 3, h + 4 + 3, color(135));
        appendChild(background);

        mainPanel = uiFactory.createRect(1, 1, w, h, colour);
        appendChild(mainPanel);

        UIElement addAtomButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0), createAtomAtCamera);
        UIElement addAtomText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Add Atom");
        addAtomButton.appendChild(addAtomText);
        appendChild(addAtomButton);

        UIElement deleteSelectionButton = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0), deleteItemsInSelection);
        UIElement deleteSelectionText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Delete");
        deleteSelectionButton.appendChild(deleteSelectionText);
        appendChild(deleteSelectionButton);

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

        UIElement insertElectron = uiFactory.createButton(5, 226, w - 8, 40, color(0, 0, 255), insertElectronAtom);
        UIElement insertElectronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Insert Electron");
        insertElectron.appendChild(insertElectronText);
        appendChild(insertElectron);

        UIElement removeElectron = uiFactory.createButton(5, 271, w - 8, 40, color(0, 0, 255), removeElectronAtom);
        UIElement removeElectronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Remove Electron");
        removeElectron.appendChild(removeElectronText);
        appendChild(removeElectron);
        
        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}