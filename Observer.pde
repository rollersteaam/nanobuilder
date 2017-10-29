class Observer {
    Vector3 pos = new Vector3(0, 0, 0);
    Vector3 rot = new Vector3(0, 0, 0);

    void Observe() {
        translate(pos.x, pos.y, pos.z);
        rotateX(rot.x);
        rotateY(rot.y);
        rotateZ(rot.z);
    }

    Vector3 ScreenPosToWorldPos(float x, float y) {
        float cameraScale = 1 + (pos.z/-50 / 100 * 100); // -50 so negative Z values represent backwards zoom.

        float newX = (x - pos.x) * cameraScale;
        float newY = (y - pos.y) * cameraScale;
        float newZ = pos.z; // TODO: This needs further implementation.

        return new Vector3(newX, newY, newZ);
    }
}