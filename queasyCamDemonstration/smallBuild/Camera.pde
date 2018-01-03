class Camera {
    float x;
    float y;
    float z;

    private float rotX;
    private float rotY;
    private float rotZ;

    void rotateY(float amt) {
        rotY += amt;

        if (rotY > 2 * PI)
            rotY = 0;
        else if (rotY < 0)
            rotY = 2 * PI;
    }

    float getRotY() {
        return rotY;
    }

    float getRotYDeg() {
        return degrees(cam.pan);
    }

    void rotateX(float amt) {
        rotX += amt;

        if (rotX > 2 * PI)
            rotX = 0;
        else if (rotX < 0)
            rotX = 2 * PI;
    }

    float getRotX() {
        return rotX;
    }

    float getRotXDeg() {
        return degrees(cam.pan);
    }

    float getXAxisModifier() {
        float _rotY = degrees(cam.pan);
        float mod = 0;

        if (_rotY >= 0 && _rotY <= 180)
            mod = (_rotY - 90) / 90;
        else // (_rotY > 180 && _rotY <= 360)
            mod = (_rotY - 270) / 90;
        
        return abs(mod); // Modifier always between 0 or 1.
    }

    float getZAxisModifier() {
        float _rotY = degrees(cam.pan);
        float mod = 0;

        if (_rotY >= 0 && _rotY <= 90)
            mod = _rotY / 90;
        else if (_rotY > 90 && _rotY <= 270)
            mod = (_rotY - 180) / 90;
        else // (_rotY > 270 && _rotY <= 360)
            mod = (_rotY - 360) / 90;

        return abs(mod);
    }
}