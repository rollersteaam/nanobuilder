import java.util.Collections;
import java.util.ArrayList;

import java.awt.AWTException;
import java.awt.Robot;

ArrayList<Atom> atomList = new ArrayList<Atom>();
Camera camera = new Camera();
Robot robot;

class Camera {
	float x;
	float y;
	float z;

	private float rotX;
	private float rotY;
	private float rotZ;

	void rotateY(float amt) {
		rotY += amt;

		if (rotY > 2 * PI)
			rotY = 0;
		else if (rotY < 0)
			rotY = 2 * PI;
	}

	float getRotY() {
		return rotY;
	}

	float getRotYDeg() {
		return degrees(rotY);
	}

	void rotateX(float amt) {
		rotX += amt;

		if (rotX > 2 * PI)
			rotX = 0;
		else if (rotX < 0)
			rotX = 2 * PI;
	}

	float getRotX() {
		return rotX;
	}

	float getRotXDeg() {
		return degrees(rotX);
	}

	float getXAxisModifier() {
		float _rotY = getRotYDeg();
		float mod = 0;

		if (_rotY >= 0 && _rotY <= 180)
			mod = (_rotY - 90) / 90;
		else // (_rotY > 180 && _rotY <= 360)
			mod = (_rotY - 270) / 90;
		
		return abs(mod); // Modifier always between 0 or 1.
	}

	float getZAxisModifier() {
		float _rotY = getRotYDeg();
		float mod = 0;

		if (_rotY >= 0 && _rotY <= 90)
			mod = _rotY / 90;
		else if (_rotY > 90 && _rotY <= 270)
			mod = (_rotY - 180) / 90;
		else // (_rotY > 270 && _rotY <= 360)
			mod = (_rotY - 360) / 90;

		return abs(mod);
	}
}

class Atom {
	float x;
	float y;
	float z;
	int r;

	private color baseColor = color(random(90, 255), random(90, 255), random(90, 255));
	color currentColor = baseColor;

	Atom() {
		this.x = random(-5000, 5000);
		this.y = random(-5000, 5000);
		this.z = random(-5000, 5000);
		this.r = 100;
		atomList.add(this);
	}

	Atom(float x, float y, float z, int r) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.r = r;		
		atomList.add(this);
	}

	void revertToBaseColor() {
		currentColor = baseColor;
	}
  
	void display() {
        // Added radius so pop-in limits are more forgiving, pop-in less obvious.
        float screenX = screenX(x + r, y + r, z - r);
        float screenY = screenY(x + r, y + r, z - r);
  
        if ((screenX > width) || (screenY > height) || (screenX < 0) || (screenY < 0)) // Removes objects outside of draw distance.
            return;
  
		noStroke();
		fill(currentColor);

		pushMatrix();
		translate(x, y, z);
		
		sphere(r);

		fill(0, 0);
		stroke(255, 170);
		rect(-100, -100, 200, 200);
		rotateY(radians(90));
		rect(-100, -100, 200, 200);
		popMatrix();
	} 
}

void setup() {
	size(1280, 720, P3D);
	// perspective(PI/3.0, float(width)/float(height), 0, 5000);
	float fov = PI/3.0;
	float cameraZ = (height/2.0) / tan(fov/2.0);
	perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
	// perspective();

	new Atom(0, 0, 0, 100);
	
	for (int i = 0; i < 100; i++) {
		new Atom(); 
	}
//
//    for (int y = 0; y < 5; y++) {
//      for (int z = 0; z < 5; z++) {
//          for (int x = 0; x < 5; x++) {
//             new Atom(200 * x, 200 * y, 200 * z, 100); 
//          }
//      }
//    }

    try { 
        robot = new Robot();
    } 
    catch (AWTException e) {
        e.printStackTrace();
    }
}

int prevX;
int prevY;

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

void draw() {
	background(100, 100, 220);
	lights();
	
	translate(camera.x, camera.y, camera.z);
	rotateX(camera.rotX);
	rotateY(camera.rotY);
	rotateZ(camera.rotZ);

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

Atom selectedAtom;

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

        // Allows selection in negative region camera space.
		if (mouseX >= screenPosXLimit && mouseX <= screenPosXNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYLimit) {
			selectedAtom = atom;
			return;
		}        
	}
}

class InputManager {
	boolean forward;
	boolean back;
	
	boolean right;
	boolean left;
	
	boolean up;
	boolean down;
	
    boolean rotating;

	void evaluateActiveInput() {
		if (up)
			camera.y += 50;
			
		if (down)
			camera.y -= 50;
			
		if (forward)
			camera.z += 50;
			
		if (back)
			camera.z -= 50;
			
		if (left)
			camera.x += 50;
			
		if (right)
			camera.x -= 50;

        if (rotating) {
            // camera.rotY += radians((mouseX - prevX));
            // camera.rotX += radians((mouseY - prevY));
            camera.rotateY(radians(mouseX - prevX));
            camera.rotateX(radians(mouseY - prevY) * -1); // Inverts the Y axis rotation.
        }
	}
	
	void keyPressed() {
		if (key == ' ') {
			activeInput.up = true;
			activeInput.down = false;
		}

		if (keyCode == SHIFT) {
			activeInput.down = true;
			activeInput.up = false;
		}

		if (key == 'w') {
			activeInput.forward = true;
			activeInput.back = false;
		}

		if (key == 's') {
			activeInput.back = true;
			activeInput.forward = false;
		}

		if (key == 'a') {
			activeInput.left = true;
			activeInput.right = false;
		}

		if (key == 'd') {
			activeInput.right = true;
			activeInput.left = false;
		}

		if (key == 'r') {
			// HARD RESET
			// camera.x = 0;
			// camera.y = 0;
			// camera.z = 0;
			// camera.rotX = 0;
			// camera.rotY = 0;
			// camera.rotZ = 0;
			// for (Atom atom : atomList) {
			//     atom.x = 0;
			//     atom.y = 0;
			//     atom.z = 0;
			// }

			camera.x = 0;
			camera.y = 0;
			camera.z = 0;
			camera.rotX = 0;
			camera.rotY = 0;
			camera.rotZ = 0;

			if (selectedAtom == null)
				return;

			selectedAtom.x = 0;
			selectedAtom.y = 0;
			selectedAtom.z = 0;
		}

		if (key == 'f') {
			if (selectedAtom == null)
				return;
			println("" + camera.x + " : " + selectedAtom.x);
			camera.x = selectedAtom.x + 500f;
			camera.y = selectedAtom.y + 500f;
			camera.z = selectedAtom.z + 500f;
		}

		if (keyCode == CONTROL)
			rotating = true;
	}

	void keyReleased() {
		if (key == ' ')
			activeInput.up = false;
		
		if (keyCode == SHIFT)
			activeInput.down = false;
		
		if (key == 'w')
			activeInput.forward = false;
		
		if (key == 's')
			activeInput.back = false;
		
		if (key == 'a')
			activeInput.left = false;
		
		if (key == 'd')
			activeInput.right = false;

		if (keyCode == CONTROL)
			rotating = false;
	}
}

InputManager activeInput = new InputManager();

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
