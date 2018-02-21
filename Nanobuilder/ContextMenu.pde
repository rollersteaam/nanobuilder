class ContextMenu extends UIElement {
    RectangleUI mainPanel;

    Runnable createAtom = new Runnable() {
        public void run() {
            selectionManager.cancel();
            selectionManager.select(worldManager.createAtom());
            hide();
        }
    };

    Runnable createElectron = new Runnable() {
        public void run() {
            selectionManager.cancel();
            selectionManager.select(worldManager.createElectron());
            hide();
        }
    };

    Runnable delete = new Runnable() {
        public void run() {
            selectionManager.delete();
            hide();
        }
    };

    Runnable paint = new Runnable() {
        public void run() {
            selectionManager.paint();
            hide();
        }
    };

    Runnable push = new Runnable() {
        public void run() {
            selectionManager.push();
            hide();
        }
    };

    Runnable insertAtomElectron = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;
            
            ((Atom) object).addElectron();
            hide();
        }
    };

    Runnable removeAtomElectron = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;

            ((Atom) object).removeElectron();
            hide();
        }
    };

    Runnable bondAtoms = new Runnable() {
        public void run() {
            ArrayList<Particle> list = selectionManager.getObjectsFromSelection();
            if (list == null) return;

            Atom lastAtom = null;
            for (Particle particle : list) {
                if (!(particle instanceof Atom)) continue;

                if (lastAtom != null) {
                    new AtomBond(lastAtom, (Atom) particle);
                }

                lastAtom = (Atom) particle;
            }

            hide();
        }
    };

    ContextMenu(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(-3, -3, w + 4 + 3, h + 4 + 3, color(76, 89, 255));
        appendChild(background);

        mainPanel = uiFactory.createRect(1, 1, w, h, colour);
        appendChild(mainPanel);

        // color buttonColour = color(180);

        UIElement createAtomButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0, 100), createAtom);
        UIElement createAtomText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Create Atom", LEFT);
        createAtomButton.appendChild(createAtomText);
        appendChild(createAtomButton);

        UIElement deleteSelectionButton = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0, 100), delete);
        UIElement deleteSelectionText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Delete", LEFT);
        deleteSelectionButton.appendChild(deleteSelectionText);
        appendChild(deleteSelectionButton);

        UIElement paintButton = uiFactory.createButton(5, 5 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 255, 0, 100), paint);
        UIElement paintText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Paint Red", LEFT);
        paintButton.appendChild(paintText);
        appendChild(paintButton);

        UIElement createElectronButton = uiFactory.createButton(5, 5 + 40 + 40 + 40 + 4 + 4 + 4, w - 8, 40, color(0, 0, 255, 100), createElectron);
        UIElement createElectronText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Create Electron", LEFT);
        createElectronButton.appendChild(createElectronText);
        appendChild(createElectronButton);

        UIElement pushButton = uiFactory.createButton(5, 173 + 4 + 4, w - 8, 40, color(0, 0, 255, 100), push);
        UIElement pushText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Push", LEFT);
        pushButton.appendChild(pushText);
        appendChild(pushButton);

        UIElement insertElectronButton = uiFactory.createButton(5, 226, w - 8, 40, color(0, 0, 255, 100), insertAtomElectron);
        UIElement insertElectronText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Insert Electron", LEFT);
        insertElectronButton.appendChild(insertElectronText);
        appendChild(insertElectronButton);

        UIElement removeElectronButton = uiFactory.createButton(5, 271, w - 8, 40, color(0, 0, 255, 100), removeAtomElectron);
        UIElement removeElectronText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Remove Electron", LEFT);
        removeElectronButton.appendChild(removeElectronText);
        appendChild(removeElectronButton);

        UIElement bondAtomsButton = uiFactory.createButton(5, 316, w - 8, 40, color(0, 0, 255, 100), bondAtoms);
        UIElement bondAtomsText = uiFactory.createText(16, 13, w - 12, 38, color(50), "Bond Atoms", LEFT);
        bondAtomsButton.appendChild(bondAtomsText);
        appendChild(bondAtomsButton);
        
        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}