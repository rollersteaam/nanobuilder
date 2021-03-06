import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;
import java.lang.Runnable;
import java.util.Deque;
import java.util.ArrayDeque;
import java.util.Random;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Collections;

Random random;
Camera cam;
Robot robot;
WorldManager worldManager;
SelectionManager selectionManager;
UIManager uiManager;
UIFactory uiFactory;

PFont uiFont;

/*
MAIN FILE
The primary interface between Processing (and its libraries) and the program,
allowing all modules and classes to work properly.
*/
public interface Runnable {
    void run();
}

// Helper function
public static float roundToDP(float value, int scale) {
    int pow = 10;
    for (int i = 1; i < scale; i++) {
        pow *= 10;
    }
    float tmp = value * pow;
    float tmpSub = tmp - (int) tmp;

    return ( (float) ( (int) (
            value >= 0
            ? (tmpSub >= 0.5f ? tmp + 1 : tmp)
            : (tmpSub >= -0.5f ? tmp : tmp - 1)
            ) ) ) / pow;

    // Below will only handles +ve values
    // return ( (float) ( (int) ((tmp - (int) tmp) >= 0.5f ? tmp + 1 : tmp) ) ) / pow;
}

void changeAppIcon(PImage img) {
    final PGraphics pg = createGraphics(16, 16, P3D);

    pg.beginDraw();
    pg.image(img, 0, 0, 16, 16);
    pg.endDraw();

    frame.setIconImage(pg.image);
}

void setup() {
    size(1280, 720, P3D);

    try {
        robot = new Robot();
    } catch (AWTException e) {}

    registerMethod("keyEvent", this);

    random = new Random();

    cam = new Camera(this);
    // cam.speed = 7.5;              // default is 3
    cam.speed = 30;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;
    cam.position = new PVector(-width, height/2, 0);

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);

    uiFont = loadFont("Bahnschrift-72.vlw");

    worldManager = new WorldManager();
    selectionManager = new SelectionManager();
    uiManager = new UIManager();
    uiFactory = new UIFactory();
    
    uiManager.start();

    toolbar = uiManager.getToolbar();

    // for (int i = 0; i < 5; i++) {
    //     int randNo = (int) random(1, 20);
    //     new Atom(randNo);
    //     // new Atom(0, 500, 0, 300);
    // }

    // for (int i = 0; i < 15; i++) {
    //     new Atom();
    // }

    // Atom atom1 = new Atom(100, 200, -700, 5);
    // Atom atom2 = new Atom(100, -2000, -700, 5);
    // AtomBond testBond = new AtomBond(atom1, atom2);

    Atom testAtom = new Atom(10, 20, 20);
    // testAtom.addNeutron();

    // for (int i = 0; i < 200; i++) {
    //     if (i % 6 == 0)
    //         testAtom.addProton();
    //     else
    //         testAtom.addNeutron();
    // }

    // new Atom(1000);

    // new Electron(150, 150, 150, new Proton(0, 0, 0));
    for (int i = 0; i < 3; i++) {
        for (int y = 0; y < 3; y++) {
            for (int z = 0; z < 3; z++) {
                // new Electron(600 * i + 20, 600 * i + 20, 600 * i + 20, new Proton(600 * i, 600 * i, 600 * i));
                new Atom(400 * i, 400 * y, 400 * z, 1, 1, 0);
            }
        }
    }
    // Atom matt = new Atom(0, 400, 0, 250);

    // Proton contentOne = new Proton(x, y, z);
    // new Electron(x + contentOne.r + 10, y + contentOne.r + 10, z + contentOne.r + 10, contentOne);
    // changeAppIcon(loadImage("Icon.png"));

    PImage icon = loadImage("icon-96.png");
    surface.setIcon(icon);
}

void checkMouseWindowConditions() {
    if (!cam.piloting) return;

    int deadzone = 128;

    if ( mouseX > deadzone ) {
        cam.controllable = true;
    } else {
        cam.controllable = false;
        return;
    }

    if ( mouseX < 1280 - deadzone ) {
        cam.controllable = true;
    } else {
        cam.controllable = false;
        return;
    }

    if ( mouseY > deadzone ) {
        cam.controllable = true;
    } else {
        cam.controllable = false;
        return;
    }

    if ( mouseY < 720 - deadzone ) {
        cam.controllable = true;
    } else {
        cam.controllable = false;
        return;
    }
}

void draw() {
    // Undoes the use of DISABLE_DEPTH_TEST so 3D objects act naturally after it was called.
    hint(ENABLE_DEPTH_TEST);

    // background(70);
    background(135, 135, 255);
    lights();
    noStroke();


    worldManager.update();

    checkMouseWindowConditions();

    // float biggestDistance = 0;

    // for (int i = 0; i < particleList.size(); i++) {
    //     Particle particle = particleList.get(i);
    //     particle.evaluatePhysics();
    //     particle.display();

    //     float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

    //     if ((dist > biggestDistance) || (biggestDistance == 0)) {
    //         biggestDistance = dist;
    //     }
    // }

    // for (Particle particle : particleList) {
    // }

    // drawOriginArrows();
    // drawOriginGrid();

//     pushStyle();
//     // stroke(color(70, 70, 255));
// // strokeWeight(8);
//     // fill(255, 0, 0, map(biggestDistance, 900, 1000, 0, 25));
//     // box(2000);
//     fill(255, 0, 0, map(biggestDistance, 9000, 10000, 0, 25));
//     box(20000);
//     popStyle();

    // pushMatrix();
    // drawCylinder(8, 100, 500);
    // popMatrix();

    // pushMatrix();
    // rotateY(PI/2);
    // rotateX(PI/4);
    // drawCylinder(8, 100, 500);
    // popMatrix();

    /*
        2D drawing beyond here ONLY.
    
        This causes any more drawing to appear as a 'painting over other objects'
        allowing 2D elements to be rendered in the same environment as 3D ones.
    */
    hint(DISABLE_DEPTH_TEST);

    selectionManager.updateSelectionMovement();
    selectionManager.updateGroupSelectionDrawing();

    uiManager.draw();
    uiManager.update();

    // SPACE
    if (keys.containsKey(32) && keys.get(32)) cam.velocity.sub(PVector.mult(cam.getUp(), cam.speed));
    // SHIFT
    if (keys.containsKey(16) && keys.get(16)) cam.velocity.add(PVector.mult(cam.getUp(), cam.speed));
}

Toolbar toolbar;

void mousePressed(MouseEvent event) {
    uiManager.checkPressForButtons();

    // If selection agent's events have been triggered, then we are finished for this mouse event.
    if (mouseButton == LEFT) {
        if (uiManager.checkForFocus()) return;
        if (toolbar.getActiveTool().press()) return;
        if (cam.fireAtom()) return;
    }
}

void mouseReleased() {
    if (uiManager.checkClickForButtons()) return;

    if (mouseButton == LEFT) {
        uiManager.leftClick();
        if (toolbar.getActiveTool().click()) return;
    } else if (mouseButton == RIGHT) {
        uiManager.rightClick();
    }
    
    // TODO: Model selectionManager after uiManager.
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    if (selectionManager.mouseWheel(e)) return;
}

void keyPressed() {
    if (key == 'z')
        cam.togglePilot();
}

// This ensures a character can never have more than one value associated to it (technically).
HashMap<Integer, Boolean> keys = new HashMap<Integer, Boolean>();

/*
Key Event allows greater flexibility at handling when a person presses a key on their keyboard compared to
Processing's keyPressed and keyReleased.
 
Processing's default methods for keyPressed and keyReleased have OS limitations and result in very bogus behaviour,
such as rate limiting for potentially a few seconds before allowing repeat events, and in other cases,
input lag.
*/
public void keyEvent(KeyEvent event){
    // Using key codes instead of reading the character allows us to use all the keys on the keyboard.
    int key = event.getKeyCode();

    switch (event.getAction()) {
        case KeyEvent.PRESS:
            keys.put(key, true);
            break;
        case KeyEvent.RELEASE:
            keys.put(key, false);
            break;
    }
}