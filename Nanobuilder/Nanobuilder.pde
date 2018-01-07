import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;

Camera cam;
Robot robot;
SelectionManager selectionManager;
UIManager uiManager;
UIFactory uiFactory;

ArrayList<Atom> atomList = new ArrayList<Atom>();

/*
MAIN FILE
The primary interface between Processing (and its libraries) and the program,
allowing all modules and classes to work properly.
*/

void setup() {
    size(1280, 720, P3D);

    try {
        robot = new Robot();
    } catch (AWTException e) {}

    registerMethod("keyEvent", this);

    cam = new Camera(this);
    cam.speed = 7.5;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
    
    selectionManager = new SelectionManager();
    uiManager = new UIManager();
    uiFactory = new UIFactory();
    
    for (int i = 0; i < 50; i++) {
        new Atom();
    }
}

void draw() {
    // Undoes the use of DISABLE_DEPTH_TEST so 3D objects act naturally after it was called.
    hint(ENABLE_DEPTH_TEST);
    background(100, 100, 220);
    lights();
    noStroke();

    for (Atom atom : atomList) {
        atom.display();
    }

    drawOriginArrows();
    drawOriginGrid();

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
    if (mouseButton == LEFT)
        if (selectionManager.mousePressed()) return;
}

void mouseReleased() {
    uiManager.checkClickForButtons();

    if (mouseButton == LEFT) {
        uiManager.leftClick();
    } else if (mouseButton == RIGHT) {
        uiManager.rightClick();
    }
    
    // TODO: Model selectionManager after uiManager.
    if (selectionManager.mouseReleased()) return;
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

// Draws a lattice (structured cube) of atoms.
void drawAtomLattice() {
    for (int y = 0; y < 5; y++) {
        for (int z = 0; z < 5; z++) {
            for (int x = 0; x < 5; x++) {
                new Atom(200 * x, 200 * y, 200 * z, 100); 
            }
        }
    }   
}

// Draws arrows pointing out from the origin point of the scene.
void drawOriginArrows() {
    pushStyle();
    fill(color(0, 0, 255));
    box(20, 20, 300);
    
    fill(color(0, 255, 0));
    box(20, 300, 20);

    fill(color(255, 0, 0));
    box(300, 20, 20);
    popStyle(); 
}

// Draws squares around an area on the origin point of the scene.
void drawOriginGrid() {
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = 0; y < 5; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    } 
}

