// OBJECT Element: Sphere
// WORLD
// Can be bonded to other 3D elements, BINDING its movement.
// TODO: Add further properties.
class SpatialSphere extends ObserverElement3D {
    SpatialSphere(float x, float y, float z, float r, color colour, boolean startActive) {
        super(x, y, z, r, r, colour, startActive);
        UI.currentAtoms.add(this);
    }

    SpatialSphere(float x, float y, float z, float r, color colour, boolean startActive, ObserverElement3D parent) {
        super(x, y, z, r, r, colour, startActive, parent);
        UI.currentAtoms.add(this);
    }

    // Returns coordinates of the starting positions of an object boundary in CARTESIAN method.
    @Override // Overriden because sphere's drawing method doesn't act in a "cartesian" way and spills "negatively".
    Vector2 WorldStartToScreenSpace() {
        float tempX = screenX(pos.x - w, pos.y, pos.z);
        float tempY = screenY(pos.x, pos.y - h, pos.z);
        return new Vector2(tempX, tempY);
    }
}