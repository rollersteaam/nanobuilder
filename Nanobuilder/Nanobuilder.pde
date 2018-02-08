import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;
import java.lang.Runnable;
import java.util.Deque;
import java.util.ArrayDeque;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Collections;

Camera cam;
Robot robot;
WorldManager worldManager;
SelectionManager selectionManager;
UIManager uiManager;
UIFactory uiFactory;

/*
MAIN FILE
The primary interface between Processing (and its libraries) and the program,
allowing all modules and classes to work properly.
*/
public interface Runnable {
    void run();
}

void setup() {
    size(1280, 720, P3D);

    try {
        robot = new Robot();
    } catch (AWTException e) {}

    registerMethod("keyEvent", this);

    cam = new Camera(this);
    // cam.speed = 7.5;              // default is 3
    cam.speed = 30;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;
    cam.position = new PVector(-width, height/2, 0);

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
    
    worldManager = new WorldManager();
    selectionManager = new SelectionManager();
    uiManager = new UIManager();
    uiFactory = new UIFactory();
    
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

    Atom testAtom = new Atom(10);
    testAtom.addNeutron();
    testAtom.addNeutron();
    testAtom.addNeutron();

    // new Atom(1000);

    // new Electron(150, 150, 150, new Proton(0, 0, 0));
    // for (int i = 0; i < 50; i++) {
        // new Electron(600 * i + 20, 600 * i + 20, 600 * i + 20, new Proton(600 * i, 600 * i, 600 * i));
    // }
    // Atom matt = new Atom(0, 400, 0, 250);

    // Proton contentOne = new Proton(x, y, z);
    // new Electron(x + contentOne.r + 10, y + contentOne.r + 10, z + contentOne.r + 10, contentOne);
}

void draw() {
    // Undoes the use of DISABLE_DEPTH_TEST so 3D objects act naturally after it was called.
    hint(ENABLE_DEPTH_TEST);

    // background(70);
    background(135, 135, 255);
    lights();
    noStroke();

    worldManager.update();

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

    uiManager.checkHoverForButtons();
    uiManager.draw();

    // SPACE
    if (keys.containsKey(32) && keys.get(32)) cam.velocity.sub(PVector.mult(cam.getUp(), cam.speed));
    // SHIFT
    if (keys.containsKey(16) && keys.get(16)) cam.velocity.add(PVector.mult(cam.getUp(), cam.speed));
}

void mousePressed(MouseEvent event) {
    // If selection agent's events have been triggered, then we are finished for this mouse event.
    if (mouseButton == LEFT) {
        if (cam.fireAtom()) return;
        if (uiManager.checkForFocus()) return;
        if (selectionManager.mousePressed()) return;
    }
}

void mouseReleased() {
    if (uiManager.checkClickForButtons()) return;

    if (mouseButton == LEFT) {
        uiManager.leftClick();
        if (selectionManager.mouseReleased()) return;
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