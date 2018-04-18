class Toolbar extends UIElement {

    SelectionTool selectionTool;
    Runnable selectionToolButtonFunction = new Runnable() {
        public void run() {
            handleToolTransition(selectionToolButton, selectionTool);
        }
    };

    NewAtomTool newAtomTool;
    Runnable newAtomToolButtonFunction = new Runnable() {
        public void run() {
            handleToolTransition(newAtomToolButton, newAtomTool);
        }
    };

    DeleteTool deleteTool;
    Runnable deleteToolButtonFunction = new Runnable() {
        public void run() {
            handleToolTransition(deleteToolButton, deleteTool);
        }
    };

    // Runnable toolbarFooButton4Function = new Runnable() {
    //     public void run() {
    //         // handleToolTransition(toolbarFooButton4);
    //     }
    // };

    void handleToolTransition(ButtonUI triggeringButton, Tool tool) {
        if (activeButton != null) {
            if (activeButton == triggeringButton) {
                activeButton.unpress();
                return;
            }

            activeButton.click();
        }

        activeButton = triggeringButton;
        activeButton.press();
        activeTool = tool;
    }

    ButtonUI selectionToolButton, newAtomToolButton, deleteToolButton, toolbarFooButton4;
    ButtonUI activeButton;
    Tool activeTool;

    public Tool getActiveTool() {
        return activeTool;
    }

    Toolbar() {
        // RectangleUI toolbar = uiFactory.createRectOutlined(42, 42, 64, height - 84, color(38, 38, 172), color(76, 89, 255), 6);
        RectangleUI toolbar = uiFactory.createRectOutlined(-6, 42, 64, height - 84, color(38, 38, 172), color(76, 89, 255), 6);

            selectionToolButton = uiFactory.createButtonOutlined(16, 16, 32, 32, color(220), selectionToolButtonFunction, color(200, 115, 25), 2);
            selectionToolButton.setHoverColour(color(224, 99, 23));
            selectionToolButton.setToggleable(true);
                ImageUI selectionToolButtonImage = uiFactory.createImage(10, 4, 32, 32, "SelectionTool.png");
                selectionToolButton.appendChild(selectionToolButtonImage);
            toolbar.appendChild(selectionToolButton);

            newAtomToolButton = uiFactory.createButtonOutlined(16, 64, 32, 32, color(220), newAtomToolButtonFunction, color(200, 115, 25), 2);
            newAtomToolButton.setHoverColour(color(224, 99, 23));
            newAtomToolButton.setToggleable(true);
                ImageUI newAtomToolButtonImage = uiFactory.createImage(0, 0, 32, 32, "NewAtomTool.png");
                newAtomToolButton.appendChild(newAtomToolButtonImage);
            toolbar.appendChild(newAtomToolButton);

            deleteToolButton = uiFactory.createButtonOutlined(16, 112, 32, 32, color(220), deleteToolButtonFunction, color(200, 115, 25), 2);
            deleteToolButton.setHoverColour(color(224, 99, 23));
            deleteToolButton.setToggleable(true);
                ImageUI deleteToolButtonImage = uiFactory.createImage(0, 0, 32, 32, "DeleteTool.png");
                deleteToolButton.appendChild(deleteToolButtonImage);
            toolbar.appendChild(deleteToolButton);
            
            // toolbarFooButton4 = uiFactory.createButtonOutlined(16, 160, 32, 32, color(220), toolbarFooButton4Function, color(200, 115, 25), 2);
            // toolbarFooButton4.setHoverColour(color(224, 99, 23));
            // toolbarFooButton4.setToggleable(true);
            
            // toolbar.appendChild(toolbarFooButton4);

        appendChild(toolbar);

        selectionTool = new SelectionTool();
        newAtomTool = new NewAtomTool();
        deleteTool = new DeleteTool();

        selectionToolButton.click();
    }
}