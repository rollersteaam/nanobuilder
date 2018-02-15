/*
Interestingly because of the drawing buffer,
the order in which these methods are called determine
what 'layer' UI are drawn on.
*/
class UIFactory {
    RectangleUI createRect(float x, float y, float w, float h, color colour) {
        RectangleUI element = new RectangleUI(x, y, w, h, colour);
        uiManager.addElement(element);
        return element;
    }
    
    RectangleUI createRectOutlined(float x, float y, float w, float h, color colour, color strokeColour, float strokeWeight) {
        RectangleUI element = new RectangleUI(x, y, w, h, colour, strokeColour, strokeWeight);
        uiManager.addElement(element);
        return element;
    }

    TextUI createText(float x, float y, float w, float h, color colour, String text, int alignment) {
        TextUI element = new TextUI(x, y, w, h, colour, text, alignment);
        uiManager.addElement(element);
        return element;
    }

    ButtonUI createButton(float x, float y, float w, float h, color colour, Runnable function) {
        ButtonUI element = new ButtonUI(x, y, w, h, colour, function);
        uiManager.addElement(element);
        return element;
    }

    ButtonUI createButtonOutlined(float x, float y, float w, float h, color colour, Runnable function, color strokeColour, color strokeWeight) {
        ButtonUI element = new ButtonUI(x, y, w, h, colour, function, strokeColour, strokeWeight);
        uiManager.addElement(element);
        return element;
    }
}