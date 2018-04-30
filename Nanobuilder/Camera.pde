class Camera extends QueasyCam {
    /*
    Completing our camera extension, an argument of our processing 'app'
    is required to be passed to QueasyCam's constructor (Camera's parent).
    */
    Camera(PApplet applet) {
        super(applet);
    }
    
    float getRotY() {
        return abs(tilt % PI);
    }

    float getRotYDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(tilt % PI));
    }
    
    float getRotX() {
        return abs(pan % (2 * PI));
    }

    float getRotXDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(pan % (2 * PI)));
    }

    float getXAxisModifier() {
        float rotX = getRotXDeg();
        float mod = 0;
        println(rotX);

        if (rotX >= 0 && rotX <= 180)
            mod = (rotX - 90) / 90;
        else // (rotX > 180 && rotX <= 360)
            mod = (rotX - 270) / 90;
        
        println(abs(mod));
        return abs(mod); // Modifier always between 0 or 1.
    }

    float getZAxisModifier() {
        float rotX = getRotXDeg();
        float mod = 0;
        println(rotX);

        if (rotX >= 0 && rotX <= 90)
            mod = rotX / 90;
        else if (rotX > 90 && rotX <= 270)
            mod = (rotX - 180) / 90;
        else // (rotX > 270 && rotX <= 360)
            mod = (rotX - 360) / 90;

        println(abs(mod));
        return abs(mod);
    }

    void pilot() {
        sensitivity = 0;
        robot.mouseMove(width/4 + width/2, height/2 + height/4);
        cursor();
        piloting = true;
    }

    void stopPiloting() {
        sensitivity = 0.5;
        noCursor();
        piloting = false;
    }

    boolean piloting = true;

    public void togglePilot() {
        if (piloting)
            stopPiloting();
        else
            pilot();
    }

    public boolean fireAtom() {
        if (piloting) return false;

        Atom newAtom = worldManager.createAtom();
        newAtom.applyForce(cam.position, newAtom.mass);
        return true;
    }
}