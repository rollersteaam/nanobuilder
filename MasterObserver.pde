class MasterObserver {
    public ArrayList<ObserverElement> currentGUIElements = new ArrayList<ObserverElement>();
    public ArrayList<ObserverElement2D> current2DElements = new ArrayList<ObserverElement2D>();
    public ArrayList<ObserverElement3D> current3DElements = new ArrayList<ObserverElement3D>();

    public ArrayList<Button> currentButtonElements = new ArrayList<Button>();
    public ArrayList<SpatialSphere> currentAtoms = new ArrayList<SpatialSphere>();

    void draw2DElements() {
        for(int i = 0; i < current2DElements.size(); i++) {
            ObserverElement2D element = current2DElements.get(i);
            
            element.tick();
        }
    }

    void draw3DElements(){
        for(int i = 0; i < current3DElements.size(); i++){
            ObserverElement3D element = current3DElements.get(i);
            
            picker.start(i);
            element.tick();
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

    void parseKeyTriggers() {
        if (keyPressed) {
            if (key == ' ') { // If key held
                camera.pos.x += mouseX - lastMouseX;
                camera.pos.y += mouseY - lastMouseY;
            }

            if (keyCode == SHIFT) {
                camera.rot.x += radians(mouseY - lastMouseY);
                camera.rot.y += radians(mouseX - lastMouseX);
            }
        }
    }

    void parseMouseTriggers() {
        Vector2 instance = new Vector2(mouseX, mouseY);
        float threshold = taskMenu.w + 200;

        Button button = ui.getButtonAtPosition(instance);
        
        if (button != null)
             button.hovered = true;
             
         //for (Button _button : ui.currentButtonElements) {
         //    if (_button != button)
         //        _button.hovered = false;
         //}
         for (int i = 0; i < ui.currentButtonElements.size(); i++) {
              Button target = ui.currentButtonElements.get(i);
              
              if (target != button)
                  target.hovered = false;
         }
        
        SpatialSphere atom = ui.getAtomAtPosition(instance);
        
        if (atom != null)
             atom.hovered = true;
        
         for (SpatialSphere _atom : ui.currentAtoms) {
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
        for (Button button : ui.currentButtonElements) {
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
        
        for (SpatialSphere atom : ui.currentAtoms) {
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
        
        if (resolvedId > ui.currentAtoms.size()) // Resolve ID can return higher than no of elements, this is a bug in the library.
            resolvedId = -1;
        
        if (resolvedId == -1)
            return null;
            
        return ui.currentAtoms.get(resolvedId);
    }
    
    void checkForButtonClick(Vector2 target) {
        Button clickedButton = ui.getButtonAtPosition(target); 

        if (clickedButton != null) {
             clickedButton.onMouseClicked();
        }
    }
    
    SpatialSphere currentlyMovingAtom;
    
    void checkForAtomClick(Vector2 target) {
        SpatialSphere clickedAtom = ui.getAtomAtPosition(target);
    
        if (clickedAtom != null) {
             if (currentlyMovingAtom == null)
                 currentlyMovingAtom = clickedAtom;
             
             currentlyMovingAtom.beingMoved = false;
             clickedAtom.beingMoved = true;
             
             currentlyMovingAtom = clickedAtom;
        } else {
            for (int i = 0; i < ui.currentAtoms.size(); i++) {
                SpatialSphere atom = ui.currentAtoms.get(i);
                atom.beingMoved = false;
            }
        }
    }
}