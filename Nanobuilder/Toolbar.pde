class Toolbar extends UIElement {
    Runnable fooAction = new Runnable() {
        public void run() {
            println("Button clicked");
        }
    };

    Toolbar() {
        RectangleUI toolbar = uiFactory.createRectOutlined(42, 42, 64, height - 84, color(38, 38, 172), color(76, 89, 255), 6);

            ButtonUI toolbarFooButton1 = uiFactory.createButtonOutlined(16, 16, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton1.setHoverColour(color(224, 99, 23));
            toolbarFooButton1.setToggleable(true);
            toolbar.appendChild(toolbarFooButton1);

            ButtonUI toolbarFooButton2 = uiFactory.createButtonOutlined(16, 64, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton2.setHoverColour(color(224, 99, 23));
            toolbarFooButton2.setToggleable(true);
            toolbar.appendChild(toolbarFooButton2);

            ButtonUI toolbarFooButton3 = uiFactory.createButtonOutlined(16, 112, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton3.setHoverColour(color(224, 99, 23));
            toolbarFooButton3.setToggleable(true);
            toolbar.appendChild(toolbarFooButton3);
            
            ButtonUI toolbarFooButton4 = uiFactory.createButtonOutlined(16, 160, 32, 32, color(255), fooAction, color(25, 25, 115), 6);
            toolbarFooButton4.setHoverColour(color(224, 99, 23));
            toolbarFooButton4.setToggleable(true);
            
            toolbar.appendChild(toolbarFooButton4);

        appendChild(toolbar);
    }
}