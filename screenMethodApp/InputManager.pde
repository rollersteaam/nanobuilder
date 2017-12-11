class InputManager {
	boolean forward;
	boolean back;
	
	boolean right;
	boolean left;
	
	boolean up;
	boolean down;
	
    boolean rotating;

    int counter;

	void evaluateActiveInput() {
        counter++;
        println("I love evaluating active input" + counter);

		if (up)
			// camera.y += 50;
            cam.pan(0, -50);
			
		if (down)
			// camera.y -= 50;
            cam.pan(0, 50);
			
		if (forward) {
			camera.z += 50 * camera.getXAxisModifier();
			// camera.z -= 1;

            // cam.setDistance(camera.z);
            // cam.pan(0, 50);
            camera.x -= 50 * camera.getZAxisModifier();
            // cam.setDistance(cam.getDistance() + 0.1, 0);
            // cam.setDistance(-1, 0);
            float[] vecLookAt = cam.getLookAt();
            println(vecLookAt[0]);
            println(vecLookAt[1]);
            println(vecLookAt[2]);
            // println(cam.getDistance());
            cam.lookAt(vecLookAt[0] + camera.x, vecLookAt[1], vecLookAt[2] + camera.z, 0);
        }

		if (back) {
			camera.z -= 50 * camera.getXAxisModifier();
            println("Moving backwards");
			// camera.z += 50;

            // cam.setDistance(camera.z);
            camera.x += 50 * camera.getZAxisModifier();
            // cam.setDistance(cam.getDistance() + 50);
            // float[] vecLookAt = cam.getLookAt();
            // println(cam.getDistance());
            // cam.lookAt(vecLookAt[0], vecLookAt[1], vecLookAt[2], cam.getDistance() - camera.z);

			// camera.z += 1;

            // cam.setDistance(camera.z);
            // cam.pan(0, 50);
            // camera.x -= 50 * camera.getZAxisModifier();
            // cam.setDistance(cam.getDistance() - 0.1, 0);
            // cam.setDistance(-1, 0);
            float[] vecLookAt = cam.getLookAt();
            println(vecLookAt[0]);
            println(vecLookAt[1]);
            println(vecLookAt[2]);
            // println(cam.getDistance());
            // cam.lookAt(vecLookAt[0], vecLookAt[1], vecLookAt[2] + camera.z, 0);
            cam.lookAt(vecLookAt[0] + camera.x, vecLookAt[1], vecLookAt[2] + camera.z, 0);
        }

		if (left)
			// camera.x += 50 * camera.getZAxisModifier();
            cam.pan(-50, 0);
			
		if (right)
			// camera.x -= 50 * camera.getZAxisModifier();
            cam.pan(50, 0);

        if (rotating) {
            // camera.rotY += radians((mouseX - prevX));
            // camera.rotX += radians((mouseY - prevY));
            // camera.rotateY(radians(mouseX - prevX));
            // camera.rotateX(radians(mouseY - prevY) * -1); // Inverts the Y axis rotation.
            cam.rotateY(radians(mouseX - prevX) * -1);
            // camera.rotateY(radians(mouseX - prevX));
            cam.rotateX(radians(mouseY - prevY)); // Inverts the Y axis rotation.
            // camera.rotateX(radians(mouseY - prevY) * -1);
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