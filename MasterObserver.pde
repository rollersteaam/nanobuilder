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

    Vector3 ScreenPosToWorldPos(float x, float y) {
        float cameraScale = 1 + (pos.z/-50 / 100 * 100); // -50 so negative Z values represent backwards zoom.

        float newX = (x - pos.x) * cameraScale;
        float newY = (y - pos.y) * cameraScale;
        float newZ = pos.z; // TODO: This needs further implementation.

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

            picker.start(i);

            fill(target.colour);

            pushMatrix();

            if (target.beingMoved) {
                stroke(target.strokeColour, target.alpha);

                Vector3 lastWorldMouse = camera.ScreenPosToWorldPos(lastMouseX, lastMouseY);
                Vector3 worldMouse = camera.ScreenPosToWorldPos(mouseX, mouseY);
                //target.pos.x += mouseX - lastMouseX;
                target.pos.x += worldMouse.x - lastWorldMouse.x;
                //target.pos.y += mouseY - lastMouseY;
                target.pos.y += worldMouse.y - lastWorldMouse.y;

            } else if (target.hovered) {
                stroke(target.strokeColour, target.alpha / 2);
            } else {
                noStroke();
            }

            translate(target.pos.x, target.pos.y, target.pos.z);
            sphere(target.w);

            popMatrix();
        }
        
        picker.stop();
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
            if (key == ' ' && camera.isPanning) { // If key held
                camera.pos.x += mouseX - lastMouseX;
                camera.pos.y += mouseY - lastMouseY;
            }

            if (keyCode == SHIFT && camera.isRotating) {
                camera.rotX += radians(mouseY - lastMouseY);
                camera.rotY += radians(mouseX - lastMouseX);
            }
        } else {
            if (camera.isPanning) camera.isPanning = false;
            if (camera.isRotating) camera.isRotating = false;
        }
    }

    void ParseMouseTriggers() {
        Vector2 instance = new Vector2(mouseX, mouseY);
        float threshold = taskMenu.w + 200;

        Button button = UI.getButtonAtPosition(instance);
        
        if (button != null)
             button.hovered = true;
             
         //for (Button _button : UI.currentButtonElements) {
         //    if (_button != button)
         //        _button.hovered = false;
         //}
         for (int i = 0; i < UI.currentButtonElements.size(); i++) {
              Button target = UI.currentButtonElements.get(i);
              
              if (target != button)
                  target.hovered = false;
         }
        
        SpatialSphere atom = UI.getAtomAtPosition(instance);
        
        if (atom != null)
             atom.hovered = true;
        
         for (SpatialSphere _atom : UI.currentAtoms) {
             if (_atom != atom)
                 _atom.hovered = false;
         }

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
    
    Button getButtonAtPosition(Vector2 target) {        
        for (Button button : UI.currentButtonElements) {
            if (!button.active) continue;
    
            if (target.x >= button.pos.x &&
                target.x <= button.pos.x + button.w &&
                target.y >= button.pos.y &&
                target.y <= button.pos.y + button.h)
            {
                return button;
            }
        }
        
        return null;
    }
    
    SpatialSphere getAtomAtPosition(Vector2 target) {
        Vector2 closestAtom = new Vector2(0, 0);
        
        for (SpatialSphere atom : UI.currentAtoms) {
            if (!atom.active) continue;
    
            if (closestAtom.x == 0 && closestAtom.y == 0) {
                closestAtom.x = atom.pos.x;
                closestAtom.y = atom.pos.y;
            }
    
            if (dist(target.x, target.y, atom.pos.x, atom.pos.y) < dist(target.x, target.y, atom.pos.x, atom.pos.y)) {
                closestAtom.x = atom.pos.x;
                closestAtom.y = atom.pos.y;
            }
        }
        
        println(target.x + " compared to " + closestAtom.x + " and ");
        println(target.y + " compared to " + closestAtom.y + " done ");
        
        int resolvedId = picker.get(round(target.x), round(target.y));
        
        if (resolvedId > UI.currentAtoms.size()) // Resolve ID can return higher than no of elements, this is a bug in the library.
            resolvedId = -1;
        
        if (resolvedId == -1)
            return null;
            
        return UI.currentAtoms.get(resolvedId);
    }
    
    void checkForButtonClick(Vector2 target) {
        Button clickedButton = UI.getButtonAtPosition(target); 

        if (clickedButton != null) {
             clickedButton.onMouseClicked();
        }
    }
    
    SpatialSphere currentlyMovingAtom;
    
    void checkForAtomClick(Vector2 target) {
        SpatialSphere clickedAtom = UI.getAtomAtPosition(target);
    
        if (clickedAtom != null) {
             if (currentlyMovingAtom == null)
                 currentlyMovingAtom = clickedAtom;
             
             currentlyMovingAtom.beingMoved = false;
             clickedAtom.beingMoved = true;
             
             currentlyMovingAtom = clickedAtom;
        } else {
            for (int i = 0; i < UI.currentAtoms.size(); i++) {
                SpatialSphere atom = UI.currentAtoms.get(i);
                atom.beingMoved = false;
            }
        }
    }
}