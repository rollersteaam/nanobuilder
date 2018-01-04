import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;

Camera cam;
Robot robot;

ArrayList<Atom> atomList = new ArrayList<Atom>();

Atom selectedAtom;
PVector selectedAtomIncidentVector;

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
    
    for (int i = 0; i < 50; i++) {
        new Atom();
    }
    
    try {
        robot = new Robot();
    } catch (AWTException e) {}
    
    // Required for keyEvent to work, interestingly.
    registerMethod("keyEvent", this);
}

void draw() {
    background(100, 100, 220);
    lights();

    for (Atom atom : atomList) {
        atom.display();
    }

    drawOriginArrows();
    drawOriginGrid();
    evaluateAtomMovement();
    
    // SPACE
    if (keys.containsKey(32) && keys.get(32)) cam.velocity.sub(PVector.mult(cam.getUp(), cam.speed));
    // SHIFT
    if (keys.containsKey(16) && keys.get(16)) cam.velocity.add(PVector.mult(cam.getUp(), cam.speed));
}

void selectAtom(Atom atom) {
    selectedAtom = atom;
    // if (cam.position.x > 0)
        // selectedAtomIncidentVector = PVector.sub(cam.position, selectedAtom.pos);
    // else
    selectedAtomIncidentVector = PVector.sub(selectedAtom.pos, cam.position);
}

void mousePressed() {
    // Case 1: Cancel selection.
    if (selectedAtom != null) {
        selectedAtom.revertToBaseColor();
        selectedAtom = null;
        selectedAtomIncidentVector = null;
        hoveringDistanceMult = 1;
        return;
    }

    // Case 2: Find selectable atom.
    for (Atom atom : atomList) {
        float screenPosX = screenX(atom.pos.x, atom.pos.y, atom.pos.z);
        float screenPosXNegativeLimit = screenX(atom.pos.x - atom.r, atom.pos.y, atom.pos.z);
        float screenPosXPositiveLimit = screenX(atom.pos.x + atom.r, atom.pos.y, atom.pos.z);
        
        float screenPosY = screenY(atom.pos.x, atom.pos.y, atom.pos.z);
        float screenPosYNegativeLimit = screenY(atom.pos.x, atom.pos.y - atom.r, atom.pos.z);
        float screenPosYPositiveLimit = screenY(atom.pos.x, atom.pos.y + atom.r, atom.pos.z);
        
        float screenPosZ = screenZ(atom.pos.x, atom.pos.y, atom.pos.z);
        float screenPosZNegativeLimit = screenY(atom.pos.x, atom.pos.y, atom.pos.z - atom.r);
        float screenPosZPositiveLimit = screenY(atom.pos.x, atom.pos.y, atom.pos.z + atom.r);

        if (mouseX >= screenPosXNegativeLimit && mouseX <= screenPosXPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
            selectAtom(atom);
            return;
        }

        /*
        Allows selection in 'opposite region' camera space, since the limits switch around.
        */
        if (mouseX >= screenPosXPositiveLimit && mouseX <= screenPosXNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
            selectAtom(atom);
            return;
        }

        if (mouseX >= screenPosZNegativeLimit && mouseX <= screenPosZPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
            selectAtom(atom);
            return;
        }

        /*
        Allows selection in 'opposite region' camera space, since the limits switch around.
        */
        if (mouseX >= screenPosZPositiveLimit && mouseX <= screenPosZNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
            selectAtom(atom);
            return;
        }
    }
}

float hoveringDistanceMult = 1;

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    //float rotX = camera.getRotXDeg();
    float rotX = cam.getRotXDeg();

    if (selectedAtom != null) {
        // float pAX = selectedAtom.x;
        // float pAY = selectedAtom.y;
        // float pAZ = selectedAtom.z;
        
        /*
        This if block takes mouse scroll wheel input, which returns between 1 and -1 whether
        scroll up or scroll down happened.

        It takes these events and adds that to the Atom's position, based on the orientation of the camera,
        because what counts as 'X' and 'Z' and positive and negative translations change depending on the
        camera's rotation in the X axis.

        The getZAxisModifier and getXAxisModifier return a value between 0 and 1 which determines how much an atom should
        move in their respective axis. This allows the camera to move parallel to the camera.
        */
        if (e > 0) { // If scroll down
            // hoveringDistanceMult -= 100 + (100000 / PVector.dist(cam.position, selectedAtom.pos));
            hoveringDistanceMult -= 0.5 * PVector.dist(cam.position, selectedAtom.pos) / 5000;
        } else { // if scroll up
            // hoveringDistanceMult += 100 + (PVector.dist(cam.position, selectedAtom.pos) / 10);
            hoveringDistanceMult += 0.5 / PVector.dist(cam.position, selectedAtom.pos) * 500;
        }
        // println("Vector Difference: [" + (selectedAtom.x - pAX) + "," + (selectedAtom.y - pAY) + "," + (selectedAtom.z - pAZ) + "]");
        // println(camera.getRotXDeg());
    }
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

void evaluateAtomMovement() {
    if (selectedAtom == null)
        return;

    // println("The X axis should move this much... " + cam.getXAxisModifier());
    // println("The Z axis should move this much..." + cam.getZAxisModifier());
    
    float rotX = cam.getRotXDeg();
    
    // if (rotX >= 90 && rotX <= 270) // if camera rotation in INVERSE region
    //     selectedAtom.x -= ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * cam.getZAxisModifier() * 2;
    // else// if camera rotation in NORMAL region
    //     selectedAtom.x += ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * cam.getZAxisModifier() * 2;
    
    // if (rotX <= 360 && rotX >= 180)
    //     selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * cam.getXAxisModifier() * 2;
    // else
    //     selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * cam.getXAxisModifier() * 2;
    
    // selectedAtom.y += (mouseY - screenY(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * 2;

    //selectedAtom.pos = PVector.mult(cam.getForward(), cam.position);
    PVector forward = cam.getForward();
    // PVector incidentVector = selectedAtomIncidentVector.normalize();
    // println(selectedAtomIncidentVector);
    // Null is passed as an argument so the original vector variable is not normalized.
    // PVector normalizedIncidentVector = selectedAtomIncidentVector.normalize(null);

    selectedAtom.pos = PVector.add(cam.position, new PVector(
        // Fine tune mode
        (400 * hoveringDistanceMult) * forward.x,
        (400 * hoveringDistanceMult) * forward.y,
        (400 * hoveringDistanceMult) * forward.z) );
        
        // Large movement mode
        // (selectedAtomIncidentVector.x) * forward.x * hoveringDistanceMult,
        // (selectedAtomIncidentVector.y) * forward.y * hoveringDistanceMult,
        // (selectedAtomIncidentVector.x) * forward.z * hoveringDistanceMult ));

    selectedAtom.currentColor = color(135);
    
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            
            translate(selectedAtom.pos.x - 250, selectedAtom.pos.y, selectedAtom.pos.z - 250);
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            
            translate(selectedAtom.pos.x, selectedAtom.pos.y - 250, selectedAtom.pos.z + 250);
            rotateY(PI/2);
            stroke(255, 180);
            noFill();
            
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
}