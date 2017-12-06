import java.util.Collections;
import java.util.ArrayList;

import java.awt.AWTException;
import java.awt.Robot;
import peasy.*;

PeasyCam cam;
ArrayList<Atom> atomList = new ArrayList<Atom>();
Camera camera = new Camera();
Robot robot;
int prevX;
int prevY;
Atom selectedAtom;
InputManager activeInput = new InputManager();

void setup() {
	size(1280, 720, P3D);
	// perspective(PI/3.0, float(width)/float(height), 0, 5000);
	float fov = PI/3.0;
	float cameraZ = (height/2.0) / tan(fov/2.0);
	perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
	// perspective();

    cam = new PeasyCam(this, 100);
    cam.setActive(false);
    cam.setSuppressRollRotationMode();

	new Atom(0, 0, 0, 100);
	
	for (int i = 0; i < 100; i++) {
		new Atom();
	}

    // for (int y = 0; y < 5; y++) {
    //     for (int z = 0; z < 5; z++) {
    //         for (int x = 0; x < 5; x++) {
    //             new Atom(200 * x, 200 * y, 200 * z, 100); 
    //         }
    //     }
    // }

    try {
        robot = new Robot();
    } 
    catch (AWTException e) {
        e.printStackTrace();
    }
}

void draw() {
	background(100, 100, 220);
	lights();
	
    // camera(width/2.0 + camera.x, height/2.0 + camera.y, (height/2.0) / tan(PI*30.0 / 180.0) + camera.z, width/2.0 + camera.x, height/2.0 + camera.y, 0, 0, 1, 0);

	// translate(camera.x, camera.y, camera.z);
	translate(camera.x, 0, camera.z);
	// rotateX(camera.rotX);
	// rotateY(camera.rotY);
	// rotateZ(camera.rotZ);
    // cam.pan(50, 50);
    // cam.rotateX(camera.rotX);
    // cam.rotateY(camera.rotY);
    // cam.rotateZ(camera.rotZ);

	// robot.mouseMove(mouseX - width/2, mouseY - height/2);

	for (Atom atom : atomList) {
        atom.display();
	}

	displayOriginArrows();
	displayOriginGrid();
	evaluateAtomMovement();
	
	// println(degrees(camera.rotY) % 360);
	
	activeInput.evaluateActiveInput();
	
	prevX = mouseX;
	prevY = mouseY;

	// robot.mouseMove(width*3/4, height*3/4);
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

void keyPressed() {
	activeInput.keyPressed();
}

void keyReleased() {
	activeInput.keyReleased();
}

void mouseWheel(MouseEvent event) {
	float e = event.getCount();
	float _rotY = camera.getRotYDeg();

	if (selectedAtom != null) {
        // float pAX = selectedAtom.x;
        // float pAY = selectedAtom.y;
        // float pAZ = selectedAtom.z;
        
		// The axis modifiers are inverted here on purpose.
		if (e > 0) { // If scroll down
            cam.setDistance(cam.getDistance() + 50);

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

void displayOriginArrows() {
	fill(color(0, 0, 255));
	box(20, 20, 300);
	
	fill(color(0, 255, 0));
	box(20, 300, 20);

	fill(color(255, 0, 0));
	box(300, 20, 20); 
}

void displayOriginGrid() {
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