class Camera extends QueasyCam {
    //float x;
    //float y;
    //float z;

    //private float rotX;
    //private float rotY;
    //private float rotZ;

    //void rotateY(float amt) {
        //rotY += amt;

        //if (rotY > 2 * PI)
            //rotY = 0;
        //else if (rotY < 0)
            //rotY = 2 * PI;
    //}

    //float getRotY() {
        //return rotY;
    //}

    //void rotateX(float amt) {
        //rotX += amt;

        //if (rotX > 2 * PI)
            //rotX = 0;
        //else if (rotX < 0)
            //rotX = 2 * PI;
    //}

    //float getRotX() {
        //return rotX;
    //}

    /*
    Completing our camera extension, an argument of our processing 'app'
    is required to be passed to QueasyCam's constructor (Camera's parent).
    */
    Camera(PApplet applet) {
        super(applet);
    }
    
    float getRotYDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(tilt % PI));
    }
    
    float getRotXDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(pan % PI));
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
}