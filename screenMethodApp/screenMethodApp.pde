import java.util.Collections;
import java.util.ArrayList;

import remixlab.proscene.*;
//import remixlab.bias.Shortcut;
import remixlab.bias.event.MotionShortcut;
import remixlab.dandelion.geom.Vec;

ArrayList<Atom> atomList = new ArrayList<Atom>();
Camera camera = new Camera();

int prevX;
int prevY;
Atom selectedAtom;
InputManager activeInput = new InputManager();

Scene scene;
InteractiveFrame iFrame;


void setup() {
	size(1280, 720, P3D);
	// perspective(PI/3.0, float(width)/float(height), 0, 5000);
	float fov = PI/3.0;
	float cameraZ = (height/2.0) / tan(fov/2.0);
	perspective(fov, float(width)/float(height), cameraZ/10.0 / 300, cameraZ*10.0 * 300);
	// perspective();

    scene = new Scene(this);
    iFrame = new InteractiveFrame(scene);
    iFrame.translate(30, 30);

	// new Atom(0, 0, 0, 100);
	
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
    //new KeyboardShortcut();
    
    
    // CONTROL key
    // Enables mouse movement to look around.
    // Through binding on eyeFrame.
    
    // To use forwards and backwards functions, we need to handle the binding with our own NavigationAgent class.
    // By creating a new class to handle this, we can handle passing ourselves by manipulating return values.
    // The even tthat it returns has to be a DOF6 event, which is handled in an overidden handleFeed function when implementing Agent.
    
    scene.eyeFrame().setMotionBinding(MouseAgent.NO_BUTTON, "lookAround");
    //scene.eyeFrame().setKeyBinding(, "moveForward");
    //scene.eyeFrame().setBinding(new KeyboardShortcut('w'), "moveBackward");
    //scene.eyeFrame().moveForward();
    
    //scene.eyeFrame().setKeyBinding(KeyAgent.keyCode('s'), "moveBackward");
    //scene.eyeFrame().setMotionBinding(Event.CTRL, "lookAround");
    //scene.eyeFrame().setKeyBinding(CONTROL, "lookAround");
    
    scene.eyeFrame().setKeyBinding(Scene.keyCode('w'), "translateYNeg");
    scene.eyeFrame().setKeyBinding(Scene.keyCode('s'), "translateYPos");
    scene.eyeFrame().setKeyBinding(Scene.keyCode('a'), "translateXPos");
    scene.eyeFrame().setKeyBinding(Scene.keyCode('d'), "translateXNeg");
    
    //MotionShortcut.registerID(Scene.keyCode('w'), "w");
    scene.eyeFrame().setMotionBinding(LEFT, "moveForward");
    scene.eyeFrame().setMotionBinding(RIGHT, "moveBackward");
    //scene.eyeFrame().removeKeyBindings();
    //scene.eyeFrame().removeMotionBinding(KeyAgent.keyCode('S'));
    //scene.keyAgent().disableTracking();
    scene.removeKeyBindings();
    //MotionShortcut.registerID(KeyAgent.keyCode('w'));
    //KeyAgent.RIGHT_KEY = KeyAgent.keyCode('w');
    //scene.eyeFrame().setMotionBinding(KeyAgent.RIGHT_KEY, "moveUp");
}

void draw() {
	background(100, 100, 220);
	lights();
	
  scene.drawTorusSolenoid();

  // Save the current model view matrix
  pushMatrix();
  // Multiply matrix to get in the frame coordinate system.
  // applyMatrix(Scene.toPMatrix(iFrame.matrix())); //is possible but inefficient
  iFrame.applyTransformation();//very efficient
  // Draw an axis using the Scene static function
  scene.drawAxes(20);

  // Draw a second torus
  if (scene.motionAgent().defaultGrabber() == iFrame) {
    fill(0, 255, 255);
    scene.drawTorusSolenoid();
  }
  else if (iFrame.grabsInput()) {
    fill(255, 0, 0);
    scene.drawTorusSolenoid();
  }
  else {
    fill(0, 0, 255, 150);
    scene.drawTorusSolenoid();
  }

  popMatrix();

    // camera(width/2.0 + camera.x, height/2.0 + camera.y, (height/2.0) / tan(PI*30.0 / 180.0) + camera.z, width/2.0 + camera.x, height/2.0 + camera.y, 0, 0, 1, 0);

	// translate(camera.x, camera.y, camera.z);
	// translate(camera.x, 0, camera.z);
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

    // if (key == 'w') {
    //     cam.setDistance(cam.getDistance() - 150);
    // }

    // if (key == 's') {
    //     cam.setDistance(cam.getDistance() + 150);
    // 
    
    // Move camera forwards.
    if (key == 'w') {
        //Vec curPos = scene.eye().position();
        //Vec newPos = new Vec(curPos.x(), curPos.y(), curPos.z() - 100);
        //scene.eye().setPosition(newPos);
        
        //Vec originalLookAt = scene.eye().at();
        //Vec newLookAt = new Vec(originalLookAt.x(), originalLookAt.y(), originalLookAt.z() - 100);
        //scene.eye().lookAt(newLookAt);
    }
    
    // Move camera backwards.
    if (key == 's') {
        //Vec curPos = scene.eye().position();
        //Vec newPos = new Vec(curPos.x(), curPos.y(), curPos.z() + 100);
        //scene.eye().setPosition(newPos);
    }
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