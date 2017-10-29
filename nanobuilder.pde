import java.util.Collections;
import java.util.ArrayList;
import picking.*;

// Invoking Master UI class //
MasterObserver UI = new MasterObserver();

// "Globalizing" specific UI elements //
Observer camera = new Observer();
ObserverElement2D taskMenu;
Picker picker;
MasterTimer masterTimer = new MasterTimer();
Time time = new Time();

void setup() {
    size(1280, 720, P3D);

    float screenW = width;
    float screenH = height;

    camera = new Observer();
    taskMenu = new Menu(0, 0, screenW*0.2, screenH, color(165, 165, 235), true);
    picker = new Picker(this);

    ObserverEvents events = new ObserverEvents();

    Function[] eventLib = new Function[3];
    eventLib[0] = events.new RotateCameraY();
    eventLib[1] = events.new PrintMessage("Welcome to Nanobuilder.");
    eventLib[2] = events.new PrintMessage("This message is in an array!");

    new Button(10, 12, 80, 5, color(200, 150, 150), true, eventLib[0], taskMenu);
    new Button(10, 19, 80, 5, color(150, 200, 150), true, eventLib[1], taskMenu);
    new Button(10, 26, 80, 5, color(150, 150, 200), true, eventLib[2], taskMenu);
    
    new SpatialSphere(500, 500, -1000, 50, color(135, 135, 135), true);
    new SpatialSphere(700, 500, -1000, 50, color(185, 135, 135), true);
    new SpatialSphere(900, 500, -1000, 50, color(135, 135, 185), true);
}

void draw() {
    time.CalculateDeltaTime();

    background(215, 215, 255);
    masterTimer.Tick();

    UI.ParseKeyTriggers();
    UI.ParseMouseTriggers();

    UI.Draw2DElements();

    lights();

    camera.Observe();
    UI.Draw3DElements(); // TODO: Change draw order to give 2D elements priority.

    UI.lastMouseX = mouseX;
    UI.lastMouseY = mouseY;
}

void mouseClicked() {
    Vector2 instance = new Vector2(mouseX, mouseY);
    
    UI.checkForButtonClick(instance);
    UI.checkForAtomClick(instance);
}

void keyPressed() {
    UI.lastMouseX = mouseX;
    UI.lastMouseY = mouseY;

    if (key == ' ') camera.isPanning = true;
    if (keyCode == SHIFT) camera.isRotating = true;
}

void mouseWheel(MouseEvent event) {
    if (event.getCount() < 0) {
        camera.pos.z += 50;
    } else {
        camera.pos.z -= 50;
    }
}