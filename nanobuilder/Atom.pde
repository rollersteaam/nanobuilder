class Atom {
    PVector pos = new PVector();
    // float x;
    // float y;
    // float z;
    int r;

    private color baseColor = color(random(90, 255), random(90, 255), random(90, 255));
    color currentColor = baseColor;

    Atom() {
        pos.x = random(-500, 500);
        pos.y = random(-500, 500);
        pos.z = random(-500, 500);
        this.r = round(random(25, 100));
        atomList.add(this);
    }

    Atom(float x, float y, float z, int r) {
        // this.x = x;
        // this.y = y;
        // this.z = z;
        pos = new PVector(x, y, z);
        this.r = r;        
        atomList.add(this);
    }

    void revertToBaseColor() {
        currentColor = baseColor;
    }
  
    void display() {
        // Added radius so pop-in limits are more forgiving and less obvious.
        float screenX = screenX(pos.x + r, pos.y + r, pos.z - r);
        float screenY = screenY(pos.x + r, pos.y + r, pos.z - r);
  
        // Disregard objects outside of camera view, saving GPU cycles and improving performance.
        if ((screenX > width) || (screenY > height) || (screenX < 0) || (screenY < 0)) 
            return;
        
        /*
        Push functions save the current "drawing" settings for what they do, and allow
        "popping" to restore the settings back to prvious ones after you're finished.

        e.g. pushStyle saves current drawing styles.
        pushMatrix saves the current translated position which any drawing throughout the program would otherwise be affected by.
        */
        pushStyle();
        pushMatrix();
        
        noStroke();
        fill(currentColor);
        translate(pos.x, pos.y, pos.z);
        
        sphere(r);

        // Guides //
        noFill();
        stroke(255, 170);
        rect(-r, -r, r*2, r*2);
        rotateY(radians(90));
        rect(-r, -r, r*2, r*2);
        
        popMatrix();
        popStyle();
    } 
}