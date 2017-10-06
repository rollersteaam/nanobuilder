class Observer {
    Vector3 pos = new Vector3(0, 0, 0);

    float rotX;
    float rotY;
    float rotZ;

    boolean isPanning = false;
    boolean isRotating = false;

    void Observe() {
        translate(pos.x, pos.y, pos.z);
        rotateX(rotX);
        rotateY(rotY);
        rotateZ(rotZ);
    }

    Vector3 ScreenToWorldSpace(float x, float y) {
        float cameraScale = 1 + (Camera.pos.z/-50 / 100); // -50 so negative Z values represent backwards zoom.

        float newX = (x - Camera.pos.x) * cameraScale;
        float newY = (y - Camera.pos.y) * cameraScale;
        float newZ = Camera.pos.z; // TODO: This needs further implementation.

        return new Vector3(newX, newY, newZ);
    }
}

class MasterObserver {
    public ArrayList<ObserverElement> currentGUIElements = new ArrayList<ObserverElement>();
    public ArrayList<ObserverElement2D> current2DElements = new ArrayList<ObserverElement2D>();
    public ArrayList<ObserverElement3D> current3DElements = new ArrayList<ObserverElement3D>();

    public ArrayList<Button> currentButtonElements = new ArrayList<Button>();
    public ArrayList<SpatialSphere> currentAtoms = new ArrayList<SpatialSphere>();

    void Draw2DElements() {
        for(int i = 0; i<current2DElements.size(); i++) {
            ObserverElement2D target = current2DElements.get(i);

            if (target.isFading) {
                DrawFadeElement(target);
                continue;
            }

            if (!target.enabled || !target.active) continue;

            if (target.hovered) {
                fill(red(target.colour) * 0.75, green(target.colour) * 0.75, blue(target.colour) * 0.75, target.alpha);
            } else {
                fill(target.colour, target.alpha);
            }

            stroke(target.strokeColour, target.alpha);
            rect(target.pos.x, target.pos.y, target.w, target.h);
        }
    }

    void Draw3DElements(){
        for(int i=0; i<current3DElements.size(); i++){
            ObserverElement3D target = current3DElements.get(i);

            if (!target.enabled || !target.active) continue;

            MouseListener.start(i);

            fill(target.colour);

            pushMatrix();

            if (target.beingMoved) {
                stroke(target.strokeColour, target.alpha);

                target.pos.x += mouseX - lastMouseX;
                target.pos.y += mouseY - lastMouseY;

            } else if (target.hovered) {
                stroke(target.strokeColour, target.alpha / 2);
            } else {
                noStroke();
            }

            translate(target.pos.x, target.pos.y, target.pos.z);
            sphere(target.w);

            popMatrix();
        }
        
        MouseListener.stop();
    }

    void DrawFadeElement(ObserverElement2D target) {
        pushMatrix();

        float timeElapsed = millis() - target.fadeStartMillis;
        println("The time is " + timeElapsed/target.fadeDuration);

        if (target.faded) { // fading IN

            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread
                float progress = lerp(0, 255, timeElapsed/target.fadeDuration);

                if (target instanceof Button){
                    stroke(30, progress);
                } else { // Generic template
                    noStroke();
                }

                println(timeElapsed / target.fadeDuration);
                fill(target.colour, progress);
            } else { // we're finished#

                if (target instanceof Button){
                    stroke(30, 255);
                } else { // Generic template
                    noStroke();
                }

                fill(target.colour, 255); // second 'correction' needed to complete the 'journey' so transition is smooth

                target.active = true;
                target.isFading = false;
                target.faded = false;
            }

        } else { // fading OUT

            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread
                float progress = lerp(255, 0, timeElapsed/target.fadeDuration);

                if (target instanceof Button){
                    stroke(30, progress);
                } else { // Generic template
                    noStroke();
                }

                println(timeElapsed / target.fadeDuration);
                fill(target.colour, progress);
            } else { // we're finished
                if (target instanceof Button){
                    stroke(30, 0);
                } else { // Generic template
                    noStroke();
                }

                fill(target.colour, 0); // second 'correction' needed to complete the 'journey' so transition is smooth

                target.active = false;
                target.isFading = false;
                target.faded = true;
            }

        }

        rect(target.pos.x, target.pos.y, target.w, target.h);
        popMatrix();
    }

    int lastMouseX;
    int lastMouseY;

    void ParseKeyTriggers() {
        if (keyPressed) {
            if (key == ' ' && Camera.isPanning) { // If key held
                Camera.pos.x += mouseX - lastMouseX;
                Camera.pos.y += mouseY - lastMouseY;
            }

            if (keyCode == SHIFT && Camera.isRotating) {
                Camera.rotX += radians(mouseY - lastMouseY);
                Camera.rotY += radians(mouseX - lastMouseX);
            }
        } else {
            if (Camera.isPanning) Camera.isPanning = false;
            if (Camera.isRotating) Camera.isRotating = false;
        }
    }

    void ParseMouseTriggers() {
        // Vector3 instance = Camera.ScreenToWorldSpace(mouseX, mouseY); // Shouldn't be used for 2D elements.
        Vector2 instance = new Vector2(mouseX, mouseY);

        int id = MouseListener.get(mouseX, mouseY);
        if (id >= 0) {
          SpatialSphere target = UI.currentAtoms.get(id);
          target.onMouseHover();
        } else {
           for (int i = 0; i < UI.currentAtoms.size(); i++) {
              SpatialSphere target = UI.currentAtoms.get(i);
              target.hovered = false;
           } 
        }

        float threshold = taskMenu.w + 200;

        for (int i = 0; i < UI.currentButtonElements.size(); i++) {
            Button target = UI.currentButtonElements.get(i);

            if (mouseX > target.pos.x && mouseX < target.pos.x + target.w && mouseY > target.pos.y && mouseY < target.pos.y + target.h) {
                target.onMouseHover();
            } else if (target.hovered) {
                target.hovered = false;
            }
        }

        for (int i = 0; i < UI.currentAtoms.size(); i++) {
            SpatialSphere target = UI.currentAtoms.get(i);

            if (!target.active) continue;

            Vector2 boundaryStart = target.WorldStartToScreenSpace();
            Vector2 boundaryEnd = target.WorldEndToScreenSpace();

            // State 2 - Select object for movement on click
            if (instance.x >= boundaryStart.x &&
                instance.x <= boundaryEnd.x &&
                instance.y >= boundaryStart.y &&
                instance.y <= boundaryEnd.y)
            {
                target.onMouseHover();
            } else {
                target.hovered = false;
            }
        }

        // TODO: Change into a combined if statement
        if (mouseX < threshold) {
          taskMenu.setAlpha( int( 255 - abs(taskMenu.w - mouseX) ) );
          if (!taskMenu.active) taskMenu.toggleActive();
        }

        if (mouseX <= taskMenu.w) taskMenu.setAlpha(255);

        if (mouseX > threshold) {
          taskMenu.setAlpha(0);
          if (taskMenu.active) taskMenu.toggleActive();
        }
    }
}
