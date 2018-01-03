import queasycam.*; // cam (Camera)
import java.awt.*; // robot (Mouse manipulation)
import processing.event.KeyEvent;

QueasyCam cam;
Robot robot;

ArrayList<Atom> atomList = new ArrayList<Atom>();
Camera camera = new Camera();

Atom selectedAtom;

void setup() {
    size(1280, 720, P3D);

    cam = new QueasyCam(this);

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

void mousePressed() {
    // Case 1: Cancel selection.
    if (selectedAtom != null) {
        selectedAtom.revertToBaseColor();
        selectedAtom = null;
        return;
    }

    // Case 2: Find selectable atom.
    for (Atom atom : atomList) {
        float screenPosX = screenX(atom.x, atom.y, atom.z);
        float screenPosXNegativeLimit = screenX(atom.x - atom.r, atom.y, atom.z);
        float screenPosXLimit = screenX(atom.x + atom.r, atom.y, atom.z);
        
        float screenPosY = screenY(atom.x, atom.y, atom.z);
        float screenPosYNegativeLimit = screenY(atom.x, atom.y - atom.r, atom.z);
        float screenPosYLimit = screenY(atom.x, atom.y + atom.r, atom.z);
        
        float screenPosZ = screenZ(atom.x, atom.y, atom.z);

        if (mouseX >= screenPosXNegativeLimit && mouseX <= screenPosXLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYLimit) {
            selectedAtom = atom;
            return;
        }

        // rect(screenPosX - atom.r, screenPosY - atom.r, 50, 50);

        // Allows selection in negative region camera space.
        if (mouseX >= screenPosXLimit && mouseX <= screenPosXNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYLimit) {
            selectedAtom = atom;
            return;
        }        
    }
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    //float _rotY = camera.getRotYDeg();
    float _rotY = degrees(cam.pan);

    if (selectedAtom != null) {
        // float pAX = selectedAtom.x;
        // float pAY = selectedAtom.y;
        // float pAZ = selectedAtom.z;
        
        // The axis modifiers are inverted here on purpose.
        if (e > 0) { // If scroll down


            if (_rotY >= 315 || _rotY <= 135)
                if (_rotY >= 270 && _rotY <= 360)
                    selectedAtom.x += 200 * camera.getZAxisModifier();
                else
                    selectedAtom.x -= 200 * camera.getZAxisModifier();
            else
                if (_rotY > 135 && _rotY <= 180)
                    selectedAtom.x -= 200 * camera.getZAxisModifier();
                else
                    selectedAtom.x += 200 * camera.getZAxisModifier();

            if (_rotY >= 315 || _rotY <= 135)
                if (_rotY >= 315 || (_rotY >= 0 && _rotY < 90))
                    selectedAtom.z += 200 * camera.getXAxisModifier();
                else
                    selectedAtom.z -= 200 * camera.getXAxisModifier();
            else
                if (_rotY >= 270 && _rotY < 315)
                    selectedAtom.z += 200 * camera.getXAxisModifier();
                else
                    selectedAtom.z -= 200 * camera.getXAxisModifier();
        } else { // if scroll up
            if (_rotY >= 315 || _rotY <= 135)
                if (_rotY >= 270 && _rotY <= 360)
                    selectedAtom.x -= 200 * camera.getZAxisModifier();
                else
                    selectedAtom.x += 200 * camera.getZAxisModifier();
            else
                if (_rotY > 135 && _rotY <= 180)
                    selectedAtom.x += 200 * camera.getZAxisModifier();
                else
                    selectedAtom.x -= 200 * camera.getZAxisModifier();
            
            if (_rotY >= 315 || _rotY <= 135)
                if (_rotY >= 315 || (_rotY >= 0 && _rotY < 90))
                    selectedAtom.z -= 200 * camera.getXAxisModifier();
                else
                    selectedAtom.z += 200 * camera.getXAxisModifier();
            else
                if (_rotY >= 270 && _rotY < 315)
                    selectedAtom.z -= 200 * camera.getXAxisModifier();
                else
                    selectedAtom.z += 200 * camera.getXAxisModifier();
        }

        // println("Vector Difference: [" + (selectedAtom.x - pAX) + "," + (selectedAtom.y - pAY) + "," + (selectedAtom.z - pAZ) + "]");
        // println(camera.getRotYDeg());
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

// This ensures a character can never have more than one value associated to it (technically). It's a clean wrap too.
HashMap<Integer, Boolean> keys = new HashMap<Integer, Boolean>();

// Key Event handles the event where a person holds down a key to perform an action.
// Processing's default methods for keyPressed and keyReleased have OS limitations and result in very bogus behaviour.
public void keyEvent(KeyEvent event){
    int key = event.getKeyCode();
    
    println(key);
    
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

void drawAtomLattice() {
     for (int y = 0; y < 5; y++) {
         for (int z = 0; z < 5; z++) {
             for (int x = 0; x < 5; x++) {
                 new Atom(200 * x, 200 * y, 200 * z, 100); 
             }
         }
     }   
}

void drawOriginArrows() {
    fill(color(0, 0, 255));
    box(20, 20, 300);
    
    fill(color(0, 255, 0));
    box(20, 300, 20);

    fill(color(255, 0, 0));
    box(300, 20, 20); 
}

void drawOriginGrid() {
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            fill(0, 0);
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            fill(0, 0);
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = 0; y < 5; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            fill(0, 0);
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            fill(0, 0);
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    } 
}

void evaluateAtomMovement() {
    if (selectedAtom == null)
        return;

    //println(camera.getXAxisModifier());
    //println(camera.getZAxisModifier());
    
    float _rotY = camera.getRotYDeg();
    // println(mouseX);
    // println(screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z));
    // println( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) );
    
    if (_rotY >= 90 && _rotY <= 270) // if camera rotation in INVERSE region
        selectedAtom.x -= ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * camera.getXAxisModifier() * 2;
    else// if camera rotation in NORMAL region
        selectedAtom.x += ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * camera.getXAxisModifier() * 2;
    
    if (_rotY <= 360 && _rotY >= 180)
        selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier() * 2;
    else
        selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier() * 2;
    
    selectedAtom.y += (mouseY - screenY(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * 2;
    
    // println(round(camera.getRotYDeg() + 0.00));
    
    selectedAtom.currentColor = color(135);
    
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            
            translate(selectedAtom.x - 250, selectedAtom.y, selectedAtom.z - 250);
            rotateX(PI/2);
            stroke(255, 180);
            fill(0, 0);
            
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
    
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushMatrix();
            
            translate(selectedAtom.x, selectedAtom.y - 250, selectedAtom.z + 250);
            rotateY(PI/2);
            stroke(255, 180);
            fill(0, 0);
            
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
        }
    }
}