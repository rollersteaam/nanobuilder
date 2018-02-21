class Toolbar extends UIElement {
    Runnable fooAction = new Runnable() {
        public void run() {
            println("Button clicked");
        }
    };

    Toolbar() {
        RectangleUI toolbar = uiFactory.createRectOutlined(42, 42, 64, height - 84, color(38, 38, 172), color(76, 89, 255), 6);

            ButtonUI selectionToolButton = uiFactory.createButtonOutlined(16, 16, 32, 32, color(220), fooAction, color(200, 115, 25), 2);
            selectionToolButton.setHoverColour(color(224, 99, 23));
            selectionToolButton.setToggleable(true);
                ImageUI selectionToolButtonImage = uiFactory.createImage(10, 4, 32, 32, "SelectionTool.png");
                selectionToolButton.appendChild(selectionToolButtonImage);
            toolbar.appendChild(selectionToolButton);

            ButtonUI newAtomToolButton = uiFactory.createButtonOutlined(16, 64, 32, 32, color(220), fooAction, color(200, 115, 25), 2);
            newAtomToolButton.setHoverColour(color(224, 99, 23));
            newAtomToolButton.setToggleable(true);
                ImageUI newAtomToolButtonImage = uiFactory.createImage(0, 0, 32, 32, "NewAtomTool.png");
                newAtomToolButton.appendChild(newAtomToolButtonImage);
            toolbar.appendChild(newAtomToolButton);

            ButtonUI deleteToolButton = uiFactory.createButtonOutlined(16, 112, 32, 32, color(220), fooAction, color(200, 115, 25), 2);
            deleteToolButton.setHoverColour(color(224, 99, 23));
            deleteToolButton.setToggleable(true);
                ImageUI deleteToolButtonImage = uiFactory.createImage(0, 0, 32, 32, "DeleteTool.png");
                deleteToolButton.appendChild(deleteToolButtonImage);
            toolbar.appendChild(deleteToolButton);
            
            ButtonUI toolbarFooButton4 = uiFactory.createButtonOutlined(16, 160, 32, 32, color(220), fooAction, color(200, 115, 25), 2);
            toolbarFooButton4.setHoverColour(color(224, 99, 23));
            toolbarFooButton4.setToggleable(true);
            
            toolbar.appendChild(toolbarFooButton4);

        appendChild(toolbar);
    }
}