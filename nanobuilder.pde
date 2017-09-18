import java.util.ArrayList;

// Invoking Master UI class //
MasterObserver UI = new MasterObserver();

// Globalizing specific UI elements //
ObserverElement taskMenu;
Observer Camera;

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
        rotateX(rotX);
        rotateY(rotY);
        rotateZ(rotZ);
    }
}

class Position { // created mainly for the screen to world conversion
    float x;
    float y;

    public Position(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

Position ScreenToWorldSpace(float x, float y) {
    float cameraScale = 1 + (Camera.z*-1/50 / 100); // Times the translation by *-1 to flip its sign.

    float newX = (x - Camera.x) * cameraScale; // this is inverted because the camera represents its translation, not its current position...
    float newY = (y - Camera.y) * cameraScale;

    return new Position(newX, newY);
}

void setup() {
    size(1280, 720, P3D);

    float screenW = width;
    float screenH = height;

    Camera = new Observer();
    taskMenu = new ObserverElement(0, 0, screenW*0.2, screenH, color(165, 165, 235), true, true);

    ObserverEvents events = new ObserverEvents();

    Event[] eventLib = new Event[3];
    eventLib[0] = events.new PrintMessage("" + taskMenu.Colour);
    eventLib[1] = events.new PrintMessage("Welcome to Nanobuilder.");
    eventLib[2] = events.new PrintMessage("This message is in an array!");

    Button taskMenuButton1 = new Button(10, 12, 80, 5, color(200, 150, 150), true, events.new RotateCameraY(), taskMenu);
    Button taskMenuButton2 = new Button(10, 19, 80, 5, color(150, 200, 150), true, eventLib[1], taskMenu);
    Button taskMenuButton3 = new Button(10, 26, 80, 5, color(150, 150, 200), true, eventLib[0], taskMenu);

    SpatialSphere myNewSphere = new SpatialSphere(500, 500, 50, color(135, 135, 135), true);
    SpatialSphere myNewSphere2 = new SpatialSphere(700, 500, 50, color(185, 135, 135), true);
    SpatialSphere myNewSphere3 = new SpatialSphere(900, 500, 50, color(135, 135, 185), true);
}

void draw() {
    background(215, 215, 255);
    lights();

    UI.ParseKeyTriggers();
    UI.ParseMouseTriggers();

    UI.DrawActiveScreenElements();

    Camera.Observe();
    UI.DrawActiveElements();
}

void mouseClicked() {
    Position instance = ScreenToWorldSpace(mouseX, mouseY); // record an initial instance because mouse position could vary over the time it takes to iterate through current buttons, progressively slower the more buttons exist too.
    int instanceScrX = mouseX;
    int instanceScrY = mouseY;

    boolean eventCompleted = false;

    for (int i = 0; i < UI.currentButtonElements.size(); i++) { // buttons don't use standardised instance coordinates, because they are 2D elements they only need to check screen relative coordinates
        Button target = UI.currentButtonElements.get(i);

        if (!target.active) continue;

        if (instanceScrX >= target.x && instanceScrX <= (target.x + target.w) && instanceScrY >= target.y && instanceScrY <= (target.y + target.h)) { // simple boundary check
            target.onMouseClicked();
            eventCompleted = true;
        }
    }

    if (eventCompleted) return;

    Position closestAtom = new Position(0, 0);

    for (int i = 0; i < UI.currentAtoms.size(); i++) {
        SpatialSphere target = UI.currentAtoms.get(i);

        if (closestAtom.x == 0) {
            closestAtom.x = target.x;
            closestAtom.y = target.y;
        }

        if (dist(instance.x, instance.y, target.x, target.y)  < dist(instance.x, instance.y, closestAtom.x, closestAtom.y)) {
            closestAtom.x = target.x;
            closestAtom.y = target.y;
        }

        if (i == UI.currentAtoms.size() - 1) {
            println(instance.x + " compared to " + closestAtom.x + " and ");
            println(instance.y + " compared to " + closestAtom.y + " done ");
        }

        // State 1 - Move object to mouse position on click
        if (target.beingMoved) {
            println("Placing object.");
            target.x = instance.x;
            target.y = instance.y;
            target.beingMoved = false;
            return;
        }

        // State 2 - Select object for movement on click
        if (instance.x >= target.x - target.w && instance.x <= (target.x + target.w) && instance.y >= target.y - target.h && instance.y <= (target.y + target.h)) {
            if (target.active) {
                target.beingMoved = true;
                println("Move is registered");
                return; // remove this line to create a weird morphing glitch between two spheres
            }
        }
    }

    println("I'm clicking");
}

void keyPressed() {
    UI.lastMouseX = mouseX;
    UI.lastMouseY = mouseY;

    if (key == ' ') Camera.isPanning = true;
    if (keyCode == SHIFT) Camera.isRotating = true;
}

void mouseWheel(MouseEvent event) {
    if (event.getCount() < 0) {
        Camera.z += 50;
    } else {
        Camera.z -= 50;
    }
}
