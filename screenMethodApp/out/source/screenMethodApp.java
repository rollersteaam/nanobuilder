import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Collections; 
import java.util.ArrayList; 
import java.awt.AWTException; 
import java.awt.Robot; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class screenMethodApp extends PApplet {







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

    public void rotateY(float amt) {
        rotY += amt;

        if (rotY > 2 * PI)
            rotY = 0;
        else if (rotY < 0)
            rotY = 2 * PI;
    }

    public float getRotY() {
        return rotY;
    }

    public float getRotYDeg() {
        return degrees(rotY);
    }

    public void rotateX(float amt) {
        rotX += amt;

        if (rotX > 2 * PI)
            rotX = 0;
        else if (rotX < 0)
            rotX = 2 * PI;
    }

    public float getRotX() {
        return rotX;
    }

    public float getRotXDeg() {
        return degrees(rotX);
    }

    public float getXAxisModifier() {
        float _rotY = getRotYDeg();
        float mod = 0;

        if (_rotY >= 0 && _rotY <= 180)
            mod = (abs(_rotY - 90) / 90);
        else if (_rotY >= 180 && _rotY <= 360)
            mod = (abs(_rotY - 270) / 90);
        
        return mod;
    }

    public float getZAxisModifier() {
        float _rotY = getRotYDeg();
        float mod = 0;

        if (_rotY >= 0 && _rotY <= 90)
            mod = (abs(_rotY) / 90);
        else if (_rotY >= 90 && _rotY <= 270)
            mod = (abs(_rotY - 180) / 90);
        else if (_rotY >= 270 && _rotY <= 360)
            mod = (abs(_rotY - 360) / 90);

        return mod;
    }
}

class Atom {
	float x;
	float y;
	float z;
	int r;

    private int baseColor = color(random(0, 255), random(0, 255), random(0, 255));
	int currentColor = baseColor;

    Atom() {
        this.x = random(-1000, 1000);
        this.y = random(-660, 660);
        this.z = random(-300, 300);
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

    public void revertToBaseColor() {
        currentColor = baseColor;
    }
  
	public void display() {
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

public void setup() {
	
    // perspective(PI/3.0, float(width)/float(height), 0, 5000);
    float fov = PI/3.0f;
    float cameraZ = (height/2.0f) / tan(fov/2.0f);
    perspective(fov, PApplet.parseFloat(width)/PApplet.parseFloat(height), cameraZ/10.0f / 300, cameraZ*10.0f * 300);
    // perspective();

	new Atom(0, 0, 50, 100);

  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }
}

int prevX;
int prevY;

public void draw() {
	background(200, 200, 220);
	lights();
	translate(camera.x, camera.y, camera.z);
    rotateX(camera.rotX);
    rotateY(camera.rotY);
    rotateZ(camera.rotZ);

    // robot.mouseMove(mouseX - width/2, mouseY - height/2);

	for (Atom atom : atomList) {
		atom.display();
	}

    fill(color(0, 0, 255));
    box(20, 20, 300);
    
    fill(color(0, 255, 0));
    box(20, 300, 20);

    fill(color(255, 0, 0));
    box(300, 20, 20);

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

	if (selectedAtom != null) {
        println(camera.getXAxisModifier());
        println(camera.getZAxisModifier());

        float _rotY = camera.getRotYDeg();

        if (_rotY >= 90 && _rotY <= 270) { // if camera rotation in INVERSE region
            selectedAtom.x -= ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * camera.getXAxisModifier();
            // selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
            // selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
            // selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * constrain( abs(sin(camera.rotY)), 0, 1 );
        } else { // if camera rotation in NORMAL region
            selectedAtom.x += ( mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z) ) * camera.getXAxisModifier();
            // selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
            // selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
            // selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * constrain( abs(sin(camera.rotY)), 0, 1 );
        }

        if (_rotY <= 360 && _rotY >= 180) {
            selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
        } else {
            selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();
        }

        selectedAtom.y += mouseY - screenY(selectedAtom.x, selectedAtom.y, selectedAtom.z);
        // selectedAtom.z -= (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * abs(sin(camera.rotY);
        // selectedAtom.z += (mouseX - screenX(selectedAtom.x, selectedAtom.y, selectedAtom.z)) * camera.getZAxisModifier();

        // println(selectedAtom.z);
        // println(screenZ(selectedAtom.x, selectedAtom.y, selectedAtom.z));
        println(round(camera.getRotYDeg() + 0.00f));

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
	
    // println(degrees(camera.rotY) % 360);

    // camera.rotY += radians((mouseX - prevX));
    // camera.rotX += radians((mouseY - prevY));
	
	activeInput.evaluateActiveInput();
	


	prevX = mouseX;
	prevY = mouseY;

// robot.mouseMove(width*3/4, height*3/4);
}

Atom selectedAtom;

public void mousePressed() {
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

        // println(screenPosXNegativeLimit);
        // println(screenPosXLimit);
        // println(screenPosYNegativeLimit);
        // println(screenPosYLimit);

        // println(degrees(camera.rotY));

        // println("NORMAL:");
        // println(screenPosXNegativeLimit + " : " + mouseX + " : " + screenPosXLimit);
        // println(screenPosYNegativeLimit + " : " + mouseY + " : " + screenPosYLimit);

		if (mouseX >= screenPosXNegativeLimit && mouseX <= screenPosXLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYLimit) {
			selectedAtom = atom;
            return;
        }

        // println("INVERSE:");
        // println(screenPosXLimit + " : " + mouseX + " : " + screenPosXNegativeLimit);
        // println(screenPosYLimit + " : " + mouseY + " : " + screenPosYNegativeLimit);

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

	public void evaluateActiveInput() {
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
            camera.rotateY(radians(mouseX - prevX));
            camera.rotateX(radians(mouseY - prevY));
            // camera.rotX += radians((mouseY - prevY));
        }
	}
	
	public void keyPressed() {
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
            if (selectedAtom == null)
                return;

            selectedAtom.x = camera.x;
            selectedAtom.y = camera.y;
            selectedAtom.z = camera.z;
        }

        if (key == 'f') {
            if (selectedAtom == null)
                return;
            println("" + camera.x + " : " + selectedAtom.x);
            camera.x = selectedAtom.x;
            camera.y = selectedAtom.y;
            camera.z = selectedAtom.z;
        }

		if (keyCode == CONTROL)
            rotating = true;
	}

	public void keyReleased() {
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

public void keyPressed() {
	activeInput.keyPressed();
}

public void keyReleased() {
	activeInput.keyReleased();
}

public void mouseWheel(MouseEvent event) {
    float e = event.getCount();

    if (selectedAtom != null) {
        // The axis modifiers are inverted here on purpose.
        // TODO: Based on rotation stage (quarter) change increment decrement phase.
        if (e > 0) {
            selectedAtom.z += 50 * camera.getXAxisModifier();
            selectedAtom.x -= 50 * camera.getZAxisModifier();
        } else {
            selectedAtom.z -= 50 * camera.getXAxisModifier();
            selectedAtom.x += 50 * camera.getZAxisModifier();
        }
    }
}
    public void settings() { 	size(1280, 720, P3D); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "screenMethodApp" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
