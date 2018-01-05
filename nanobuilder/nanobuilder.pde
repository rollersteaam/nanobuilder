import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;

Camera cam;
Robot robot;
SelectionAgent selectionAgent;

ArrayList<Atom> atomList = new ArrayList<Atom>();

/*
MAIN FILE
The primary interface between Processing (and its libraries) and the program,
allowing all modules and classes to work properly.
*/

void setup() {
    size(1280, 720, P3D);

    cam = new Camera(this);
    cam.speed = 7.5;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
    
    selectionAgent = new SelectionAgent();

    for (int i = 0; i < 50; i++) {
        new Atom();
    }
    
    try {
        robot = new Robot();
    } catch (AWTException e) {}
    
    // Required for keyEvent to work, interestingly.
    registerMethod("keyEvent", this);
}

void drawRect(float x, float y, float w, float h, color color_) {
    pushStyle();
    pushMatrix();
    noLights();

    fill(color_);

    /*
    Get camera's forward pointing vector and begin to draw 2D element
    at a unit vector position (so it is created right in front of the camera's view). 
    */
    // getForward() returns a normalized vector (unit vector) that is helpful to us.
    PVector camFwd = cam.getForward();
    PVector rectPos = PVector.add(cam.position, new PVector(
        camFwd.x,
        camFwd.y,
        camFwd.z
    ));
    translate(rectPos.x, rectPos.y, rectPos.z);

    /*
    Make the object's rotation have a relationship with camera rotation
    so that it is 'billboarded', and therefore rotationally stationary
    with camera view.
    */
    rotateY(radians(270) - cam.pan);
    rotateX(cam.tilt);

    /*
    Due to the issues from the perspective of the camera, I had to find arbitrary values
    found by trial and error that best mask 2D elements to the view by a normalized
    value.
    */
    float normX = 1.03;
    float normY = 0.58;
    // Now time to change the pixel parameters to ones that correspond to that on screen.
    float pixelsX = (float) (x / width) * normX * 2 - normX;
    float pixelsY = (float) (y / height) * normY * 2 - normY;

    float pixelsW = (float) (w / width) * normX * 2;
    float pixelsH = (float) (h / height) * normY * 2;

    rect(pixelsX, pixelsY, pixelsW, pixelsH);
    // float ratio1 = (float) mouseX / width;
    // float ratio2 = (float) mouseY / height;

    popMatrix();
    popStyle();
}

boolean rightClicker = false;

void draw() {
    background(100, 100, 220);    
    lights();

    for (Atom atom : atomList) {
        atom.display();
    }

    drawOriginArrows();
    drawOriginGrid();
    selectionAgent.draw();
    selectionAgent.updateSelectionMovement();

    if (rightClicker) {
        drawRect(mouseX, mouseY, 120, 200, color(230, 230, 230));
        pushMatrix();
        translate(0, 0, 0.005);
        drawRect(mouseX + 5, mouseY + 5, 120 - 10, 40 - 10, color(120, 120, 120));
        popMatrix();
    }

    // SPACE
    if (keys.containsKey(32) && keys.get(32)) cam.velocity.sub(PVector.mult(cam.getUp(), cam.speed));
    // SHIFT
    if (keys.containsKey(16) && keys.get(16)) cam.velocity.add(PVector.mult(cam.getUp(), cam.speed));
}

void mousePressed(MouseEvent event) {
    // If selection agent's events have been triggered, then we are finished for this mouse event.
    if (mouseButton == LEFT) {
        rightClicker = false;
        if (selectionAgent.mousePressed()) return;
    } else if (mouseButton == RIGHT) {
        rightClicker = true;
    } else if (mouseButton == CENTER) {
        // Undeclared for now.
    }
}

void mouseReleased() {
    if (selectionAgent.mouseReleased()) return;
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    if (selectionAgent.mouseWheel(e)) return;
}

boolean turnCamera = false;

void keyPressed() {
    if (key == 'z') {
        if (turnCamera) {
            cam.sensitivity = 0;
            robot.mouseMove(width/4 + width/2, height/2 + height/4);
            turnCamera = false;
            cursor();
        } else {
            cam.sensitivity = 0.5;
            turnCamera = true;
            noCursor();
        }
    }
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
    
    //println(key);
    
    //if (toggleKeys.containsKey(key)) {
    //    if (event.getAction() == KeyEvent.PRESS) {
    //        toggleKeys.put(Character.toLowerCase(key), !toggleKeys.get(key));
    //    }
    //} else {
    //    if (event.getAction() == KeyEvent.PRESS) {
    //        toggleKeys.put(Character.toLowerCase(key), true);
    //    }
    //}

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
    fill(color(0, 0, 255));
    box(20, 20, 300);
    
    fill(color(0, 255, 0));
    box(20, 300, 20);

    fill(color(255, 0, 0));
    box(300, 20, 20); 
}

// Draws squares around an area on the origin point of the scene.
void drawOriginGrid() {
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = 0; y < 5; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    } 
}

