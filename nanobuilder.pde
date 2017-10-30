import java.util.Collections;
import java.util.ArrayList;
import java.util.function.Function;
import picking.*;

MasterObserver ui = new MasterObserver();
MasterTimer masterTimer = new MasterTimer();
Time time = new Time();
Observer camera = new Observer();
ObserverElement2D taskMenu;
Picker picker;

void setup() {
	size(1280, 720, P3D);

	float screenW = width;
	float screenH = height;

	taskMenu = new Menu(0, 0, screenW*0.2, screenH, color(165, 165, 235), true);
	picker = new Picker(this);

    IFunction basic = new IFunction() {
         public void call() {
              print("Test");   
         }
    };

	new Button(10, 12, 80, 5, color(200, 150, 150), true, basic, taskMenu);
	new Button(10, 19, 80, 5, color(150, 200, 150), true, basic, taskMenu);
	new Button(10, 26, 80, 5, color(150, 150, 200), true, basic, taskMenu);
	
	new SpatialSphere(500, 500, -1000, 50, color(135, 135, 135), true);
	new SpatialSphere(700, 500, -1000, 50, color(185, 135, 135), true);
	new SpatialSphere(900, 500, -1000, 50, color(135, 135, 185), true);
}

void draw() {
	time.CalculateDeltaTime();

	ui.ParseKeyTriggers();

    ui.lastMouseX = mouseX;
    ui.lastMouseY = mouseY;
	ui.ParseMouseTriggers();

    masterTimer.tick();

    camera.observe();
    background(215, 215, 255);
    // Unlit drawing elements
    noLights();

    ui.draw2DElements();

    // Lit drawing elements
	lights();

	ui.draw3DElements();
}

void mouseClicked() {
	Vector2 instance = new Vector2(mouseX, mouseY);
	
	ui.checkForButtonClick(instance);
	ui.checkForAtomClick(instance);
}

void mouseWheel(MouseEvent event) {
	if (event.getCount() < 0)
		camera.pos.z += 50;
	else
		camera.pos.z -= 50;
}