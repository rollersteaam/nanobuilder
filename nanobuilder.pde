import java.util.ArrayList;

// Invoking Master UI class //
MasterObserver UI = new MasterObserver();

// Globalizing specific UI elements //
ObserverElement2D taskMenu;
Observer Camera;

void setup() {
    size(1280, 720, P3D);

    float screenW = width;
    float screenH = height;

    Camera = new Observer();
    taskMenu = new Menu(0, 0, screenW*0.2, screenH, color(165, 165, 235), true);

    ObserverEvents events = new ObserverEvents();

    Event[] eventLib = new Event[3];
    eventLib[0] = events.new PrintMessage("" + taskMenu.colour);
    eventLib[1] = events.new PrintMessage("Welcome to Nanobuilder.");
    eventLib[2] = events.new PrintMessage("This message is in an array!");

    Button taskMenuButton1 = new Button(10, 12, 80, 5, color(200, 150, 150), true, events.new RotateCameraY(), taskMenu);
    Button taskMenuButton2 = new Button(10, 19, 80, 5, color(150, 200, 150), true, eventLib[1], taskMenu);
    Button taskMenuButton3 = new Button(10, 26, 80, 5, color(150, 150, 200), true, eventLib[0], taskMenu);

    SpatialSphere myNewSphere = new SpatialSphere(500, 500, 300, 50, color(135, 135, 135), true);
    SpatialSphere myNewSphere2 = new SpatialSphere(700, 500, 300, 50, color(185, 135, 135), true);
    SpatialSphere myNewSphere3 = new SpatialSphere(900, 500, 300, 50, color(135, 135, 185), true);
}

void draw() {
    background(215, 215, 255);

    UI.ParseKeyTriggers();
    UI.ParseMouseTriggers();

    UI.Draw2DElements();

    lights();

    Camera.Observe();
    UI.Draw3DElements();
}

void mouseClicked() {
    int instanceScrX = mouseX;
    int instanceScrY = mouseY;

    Vector2 instance = new Vector2(instanceScrX, instanceScrY);

    for (int i = 0; i < UI.currentButtonElements.size(); i++) { // buttons don't use standardised instance coordinates, because they are 2D elements they only need to check screen relative coordinates
        Button target = UI.currentButtonElements.get(i);

        if (!target.active) continue;

        if (instanceScrX >= target.pos.x && instanceScrX <= (target.pos.x + target.w) &&
        instanceScrY >= target.pos.y && instanceScrY <= (target.pos.y + target.h)) {
            target.onMouseClicked();
            return;
        }
    }

    Vector2 closestAtom = new Vector2(0, 0);

    for (int i = 0; i < UI.currentAtoms.size(); i++) {
        SpatialSphere target = UI.currentAtoms.get(i);

        if (closestAtom.x == 0) {
            closestAtom.x = target.pos.x;
            closestAtom.y = target.pos.y;
        }

        if (dist(instance.x, instance.y, target.pos.x, target.pos.y)  < dist(instance.x, instance.y, closestAtom.x, closestAtom.y)) {
            closestAtom.x = target.pos.x;
            closestAtom.y = target.pos.y;
        }

        if (i == UI.currentAtoms.size() - 1) {
            println(instance.x + " compared to " + closestAtom.x + " and ");
            println(instance.y + " compared to " + closestAtom.y + " done ");
        }

        // State 1 - Move object to mouse position on click
        if (target.beingMoved) {
            target.pos.x = instance.x;
            target.pos.y = instance.y;
            target.beingMoved = false;
            println("Placing object.");
            return;
        }

        // State 2 - Select object for movement on click
        if (instance.x >= target.pos.x - target.w && instance.x <= (target.pos.x + target.w) &&
        instance.y >= target.pos.y - target.h && instance.y <= (target.pos.y + target.h)) {
            if (target.active) {
                target.beingMoved = true;
                println("Move is registered");
                return; // remove this line to create a weird morphing glitch between two spheres
            }
        }
    }
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
