class ContextMenu extends UIElement {
    RectangleUI mainPanel;
    ButtonUI testButton;
    TextUI testText;

    ContextMenu(float x, float y, float w, float h, color colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(-1, -1, w + 4, h + 4, color(135));

        mainPanel = uiFactory.createRect(1, 1, w, h, colour);
        testButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0));
        testText = uiFactory.createText(w/4, 40/4 + 2.5, w - 12, 38, color(70), "Add Atom");
        
        UIElement testButton2 = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0));
        UIElement testText2 = uiFactory.createText(w/4, 40/4 + 2.5 + 40 + 4, w - 12, 38, color(70), "Delete");

        appendChild(background);

        appendChild(mainPanel);
        appendChild(testButton);
        appendChild(testText);

        appendChild(testButton2);
        appendChild(testText2);

        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}