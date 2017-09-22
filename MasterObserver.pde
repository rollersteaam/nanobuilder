class MasterObserver {
    public ArrayList<ObserverElement> currentGUIElements = new ArrayList<ObserverElement>();

    public ArrayList<ObserverElement> currentScreenElements = new ArrayList<ObserverElement>();
    public ArrayList<Button> currentButtonElements = new ArrayList<Button>();
    public ArrayList<SpatialSphere> currentAtoms = new ArrayList<SpatialSphere>();

    void DrawActiveScreenElements() {
        for(int i = 0; i<currentScreenElements.size(); i++) {
            ObserverElement target = currentScreenElements.get(i);

            if (target.isFading) {
                DrawFadeElement(target);
                continue;
            }

            if (!target.enabled || !target.active) continue;

            if (target instanceof Button){
                stroke(target.strokeColour, target.alpha);
            } else { // Generic template
                noStroke();
            }

            fill(target.Colour, target.alpha);
            rect(target.x, target.y, target.w, target.h);
        }
    }

    void DrawActiveElements(){
        for(int i=0; i<currentGUIElements.size(); i++){
            ObserverElement target = currentGUIElements.get(i);

            if (target.isFading) { // Handle fade elements elsewhere, bypasses the need for running a second list iteration
                DrawFadeElement(target);
                continue;
            }

            if (!target.enabled || !target.active || target.screenElement) continue;

            if (target instanceof Button){
                stroke(30);
            } else { // Generic template
                noStroke();
            }

            fill(target.Colour);

            pushMatrix();
            if (target instanceof SpatialSphere) {
                if (target.beingMoved) {
                    Position newPos = ScreenToWorldSpace(mouseX, mouseY);
                    target.x = newPos.x;
                    target.y = newPos.y;
                }

                translate(target.x, target.y);
                sphere(target.w);
            } else if (target instanceof Button) {
                translate(0, 0, 0.1);
                rect(target.x, target.y, target.w, target.h);
            } else { // Generic template
                rect(target.x, target.y, target.w, target.h);
            }
            popMatrix();
        }
    }

    void DrawFadeElement(ObserverElement target) {
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
                fill(target.Colour, progress);
            } else { // we're finished#
            
                if (target instanceof Button){
                    stroke(30, 255);
                } else { // Generic template
                    noStroke();
                }

                fill(target.Colour, 255); // second 'correction' needed to complete the 'journey' so transition is smooth

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
                fill(target.Colour, progress);
            } else { // we're finished
                if (target instanceof Button){
                    stroke(30, 0);
                } else { // Generic template
                    noStroke();
                }
            
                fill(target.Colour, 0); // second 'correction' needed to complete the 'journey' so transition is smooth

                target.active = false;
                target.isFading = false;
                target.faded = true;
            }

        }

        rect(target.x, target.y, target.w, target.h);
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
