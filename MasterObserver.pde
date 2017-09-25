class Observer {
    int x;
    int y;
    int z;

    float rotX;
    float rotY;
    float rotZ;

    boolean isPanning = false;
    boolean isRotating = false;

    void Observe() {
        translate(x, y, z);
        rotateX(rotX + (2 * PI / 10));
        rotateY(rotY);
        rotateZ(rotZ);
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

            fill(target.colour);

            pushMatrix();

            // if (target.beingMoved) {
            //     target.pos.x = newPos.x;
            //     target.pos.y = newPos.y;
            // }

            translate(target.pos.x, target.pos.y, target.pos.z);
            sphere(target.w);

            popMatrix();
        }
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
                Camera.x += mouseX - lastMouseX;
                Camera.y += mouseY - lastMouseY;

                lastMouseX = mouseX;
                lastMouseY = mouseY;
            }

            if (keyCode == SHIFT && Camera.isRotating) {
                Camera.rotX += radians(mouseY - lastMouseY);
                Camera.rotY += radians(mouseX - lastMouseX);

                lastMouseY = mouseY;
                lastMouseX = mouseX;
            }
        } else {
            if (Camera.isPanning) Camera.isPanning = false;
            if (Camera.isRotating) Camera.isRotating = false;
        }
    }

    void ParseMouseTriggers() {
        float threshold = taskMenu.w + 200;

        for (int i = 0; i < UI.currentButtonElements.size(); i++) {
            Button target = UI.currentButtonElements.get(i);

            if (mouseX > target.pos.x && mouseX < target.pos.x + target.w && mouseY > target.pos.y && mouseY < target.pos.y + target.h) {
                target.onMouseHover();
            } else if (target.hovered) {
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
