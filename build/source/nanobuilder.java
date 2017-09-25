import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class nanobuilder extends PApplet {



// Invoking Master UI class //
MasterObserver UI = new MasterObserver();

// Globalizing specific UI elements //
ObserverElement2D taskMenu;
Observer Camera;

public void setup() {
    

    float screenW = width;
    float screenH = height;

    Camera = new Observer();
    taskMenu = new Menu(0, 0, screenW*0.2f, screenH, color(165, 165, 235), true);

    ObserverEvents events = new ObserverEvents();

    Event[] eventLib = new Event[3];
    eventLib[0] = events.new PrintMessage("" + taskMenu.colour);
    eventLib[1] = events.new PrintMessage("Welcome to Nanobuilder.");
    eventLib[2] = events.new PrintMessage("This message is in an array!");

    Button taskMenuButton1 = new Button(10, 12, 80, 5, color(200, 150, 150), true, events.new RotateCameraY(), taskMenu);
    Button taskMenuButton2 = new Button(10, 19, 80, 5, color(150, 200, 150), true, eventLib[1], taskMenu);
    Button taskMenuButton3 = new Button(10, 26, 80, 5, color(150, 150, 200), true, eventLib[0], taskMenu);

    SpatialSphere myNewSphere = new SpatialSphere(500, 500, 300, 50, color(135, 135, 135), true);
    SpatialSphere myNewSphere2 = new SpatialSphere(700, 500, 300, 50, color(185, 135, 135), true);
    SpatialSphere myNewSphere3 = new SpatialSphere(900, 500, 300, 50, color(135, 135, 185), true);
}

public void draw() {
    background(215, 215, 255);

    UI.ParseKeyTriggers();
    UI.ParseMouseTriggers();

    UI.Draw2DElements();

    lights();

    Camera.Observe();
    //UI.Draw3DElements();
}

public void mouseClicked() {
    int instanceScrX = mouseX;
    int instanceScrY = mouseY;

    Vector2 instance = new Vector2(instanceScrX, instanceScrY);

    for (int i = 0; i < UI.currentButtonElements.size(); i++) { // buttons don't use standardised instance coordinates, because they are 2D elements they only need to check screen relative coordinates
        Button target = UI.currentButtonElements.get(i);

        if (!target.active) continue;

        if (instanceScrX >= target.pos.x && instanceScrX <= (target.pos.x + target.w) &&
        instanceScrY >= target.pos.y && instanceScrY <= (target.pos.y + target.h)) {
            target.onMouseClicked();
            return;
        }
    }

    Vector2 closestAtom = new Vector2(0, 0);

    for (int i = 0; i < UI.currentAtoms.size(); i++) {
        SpatialSphere target = UI.currentAtoms.get(i);

        if (closestAtom.x == 0) {
            closestAtom.x = target.pos.x;
            closestAtom.y = target.pos.y;
        }

        if (dist(instance.x, instance.y, target.pos.x, target.pos.y)  < dist(instance.x, instance.y, closestAtom.x, closestAtom.y)) {
            closestAtom.x = target.pos.x;
            closestAtom.y = target.pos.y;
        }

        if (i == UI.currentAtoms.size() - 1) {
            println(instance.x + " compared to " + closestAtom.x + " and ");
            println(instance.y + " compared to " + closestAtom.y + " done ");
        }

        // State 1 - Move object to mouse position on click
        if (target.beingMoved) {
            target.pos.x = instance.x;
            target.pos.y = instance.y;
            target.beingMoved = false;
            println("Placing object.");
            return;
        }

        // State 2 - Select object for movement on click
        if (instance.x >= target.pos.x - target.w && instance.x <= (target.pos.x + target.w) &&
        instance.y >= target.pos.y - target.h && instance.y <= (target.pos.y + target.h)) {
            if (target.active) {
                target.beingMoved = true;
                println("Move is registered");
                return; // remove this line to create a weird morphing glitch between two spheres
            }
        }
    }
}

public void keyPressed() {
    UI.lastMouseX = mouseX;
    UI.lastMouseY = mouseY;

    if (key == ' ') Camera.isPanning = true;
    if (keyCode == SHIFT) Camera.isRotating = true;
}

public void mouseWheel(MouseEvent event) {
    if (event.getCount() < 0) {
        Camera.z += 50;
    } else {
        Camera.z -= 50;
    }
}
class Observer {
    int x;
    int y;
    int z;

    float rotX;
    float rotY;
    float rotZ;

    boolean isPanning = false;
    boolean isRotating = false;

    public void Observe() {
        translate(x, y, z);
        rotateX(rotX + (2 * PI / 10));
        rotateY(rotY);
        rotateZ(rotZ);
    }
}

class MasterObserver {
    public ArrayList<ObserverElement> currentGUIElements = new ArrayList<ObserverElement>();
    public ArrayList<ObserverElement2D> current2DElements = new ArrayList<ObserverElement2D>();
    public ArrayList<ObserverElement3D> current3DElements = new ArrayList<ObserverElement3D>();

    public ArrayList<Button> currentButtonElements = new ArrayList<Button>();
    public ArrayList<SpatialSphere> currentAtoms = new ArrayList<SpatialSphere>();

    public void Draw2DElements() {
        for(int i = 0; i<current2DElements.size(); i++) {
            ObserverElement2D target = current2DElements.get(i);

            if (target.isFading) {
                DrawFadeElement(target);
                continue;
            }

            if (!target.enabled || !target.active) continue;

            if (target.hovered) {
                fill(red(target.colour) * 0.75f, green(target.colour) * 0.75f, blue(target.colour) * 0.75f, target.alpha);
            } else {
                fill(target.colour, target.alpha);
            }

            stroke(target.strokeColour, target.alpha);
            rect(target.pos.x, target.pos.y, target.w, target.h);
        }
    }

    public void Draw3DElements(){
        for(int i=0; i<current3DElements.size(); i++){
            ObserverElement3D target = current3DElements.get(i);

            if (!target.enabled || !target.active) continue;

            fill(target.colour);

            pushMatrix();

            // if (target.beingMoved) {
            //     target.pos.x = newPos.x;
            //     target.pos.y = newPos.y;
            // }

            translate(target.pos.x, target.pos.y, target.pos.z);
            sphere(target.w);

            popMatrix();
        }
    }

    public void DrawFadeElement(ObserverElement2D target) {
        pushMatrix();

        float timeElapsed = millis() - target.fadeStartMillis;
        println("The time is " + timeElapsed/target.fadeDuration);

        if (target.faded) { // fading IN

            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread
                float progress = lerp(0, 255, timeElapsed/target.fadeDuration);

                if (target instanceof Button){
                    stroke(30, progress);
                } else { // Generic template
                    noStroke();
                }

                println(timeElapsed / target.fadeDuration);
                fill(target.colour, progress);
            } else { // we're finished#

                if (target instanceof Button){
                    stroke(30, 255);
                } else { // Generic template
                    noStroke();
                }

                fill(target.colour, 255); // second 'correction' needed to complete the 'journey' so transition is smooth

                target.active = true;
                target.isFading = false;
                target.faded = false;
            }

        } else { // fading OUT

            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread
                float progress = lerp(255, 0, timeElapsed/target.fadeDuration);

                if (target instanceof Button){
                    stroke(30, progress);
                } else { // Generic template
                    noStroke();
                }

                println(timeElapsed / target.fadeDuration);
                fill(target.colour, progress);
            } else { // we're finished
                if (target instanceof Button){
                    stroke(30, 0);
                } else { // Generic template
                    noStroke();
                }

                fill(target.colour, 0); // second 'correction' needed to complete the 'journey' so transition is smooth

                target.active = false;
                target.isFading = false;
                target.faded = true;
            }

        }

        rect(target.pos.x, target.pos.y, target.w, target.h);
        popMatrix();
    }

    int lastMouseX;
    int lastMouseY;

    public void ParseKeyTriggers() {
        if (keyPressed) {
            if (key == ' ' && Camera.isPanning) { // If key held
                Camera.x += mouseX - lastMouseX;
                Camera.y += mouseY - lastMouseY;

                lastMouseX = mouseX;
                lastMouseY = mouseY;
            }

            if (keyCode == SHIFT && Camera.isRotating) {
                Camera.rotX += radians(mouseY - lastMouseY);
                Camera.rotY += radians(mouseX - lastMouseX);

                lastMouseY = mouseY;
                lastMouseX = mouseX;
            }
        } else {
            if (Camera.isPanning) Camera.isPanning = false;
            if (Camera.isRotating) Camera.isRotating = false;
        }
    }

    public void ParseMouseTriggers() {
        float threshold = taskMenu.w + 200;

        for (int i = 0; i < UI.currentButtonElements.size(); i++) {
            Button target = UI.currentButtonElements.get(i);

            if (mouseX > target.pos.x && mouseX < target.pos.x + target.w && mouseY > target.pos.y && mouseY < target.pos.y + target.h) {
                target.onMouseHover();
            } else if (target.hovered) {
                target.hovered = false;
            }
        }

        // TODO: Change into a combined if statement
        if (mouseX < threshold) {
          taskMenu.setAlpha( PApplet.parseInt( 255 - abs(taskMenu.w - mouseX) ) );
          if (!taskMenu.active) taskMenu.toggleActive();
        }

        if (mouseX <= taskMenu.w) taskMenu.setAlpha(255);

        if (mouseX > threshold) {
          taskMenu.setAlpha(0);
          if (taskMenu.active) taskMenu.toggleActive();
        }
    }
}
class Vector2 { // TODO: Make all objects utilise Vector2 and Vector3 positional types.
    public float x;
    public float y;

    public Vector2(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

class Vector3 {
    public float x;
    public float y;
    public float z;

    public Vector3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vector2 WorldToScreenSpace() {
        float tempX = screenX(x, y, z);
        float tempY = screenY(x, y, z);
        return new Vector2(tempX, tempY);
    }
}

class ObserverElement{
    protected float w, h;
    protected int colour = color(35);
    protected int strokeColour = color(30);
    protected int alpha = 255;

    protected ObserverElement parent;
    protected ArrayList<ObserverElement> children = new ArrayList<ObserverElement>();

    protected boolean enabled = true;
    protected boolean active = true;

    protected boolean screenElement = false;
    protected boolean beingMoved = false;
    protected boolean hovered = false;

    protected boolean faded = false;
    protected boolean isFading = false;
    protected int fadeStartMillis;
    protected int fadeDuration = 1000;

    ObserverElement(float w, float h, int colour, boolean startActive) {
        this.colour = colour;
        this.active = startActive;
        this.faded = !this.active;

        UI.currentGUIElements.add(this);
    }

    public void setAlpha(int val) {
       alpha = val;

       if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).setAlpha(val);
            }
        }
    }

    public void toggleActive(){
        active = !active;

        // If has children, iterate and turn all to same state as its parent.
        if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).active = active;
                children.get(i).faded = !active; // in the event a fade is later used, make sure variable is calibrated
            }
        }
    }

    public void fadeToggleActive(int milli) { // transition effect
        isFading = true;
        fadeStartMillis = millis();
        fadeDuration = milli;

        if(children.size() > 0){
            for(int i = 0; i < children.size(); i++){
                children.get(i).fadeToggleActive(milli);
            }
        }
    }
}

class ObserverElement2D extends ObserverElement {
    protected Vector2 pos;

    // There is no dynamic positioning function for things relative to the screen, I want it hard coded.
    // Use: A container element with static positioning relative to the screen.
    public ObserverElement2D(float x, float y, float w, float h, int colour, boolean startActive){
        super(w, h, colour, startActive);
        pos = new Vector2(x, y);

        UI.current2DElements.add(this);
    }

    // Use: A child element with STATIC relative positioning in a container.
    public ObserverElement2D(float x, float y, float w, float h, int colour, boolean startActive, ObserverElement2D parent){
        this(x, y, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);

        this.pos.x += parent.pos.x;
        this.pos.y += parent.pos.y;
    }

    // Use: A child element with DYNAMIC relative positioning in a container.
    public ObserverElement2D(int x, int y, int w, int h, int colour, boolean startActive, ObserverElement2D parent){
        this(x, y, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);

        this.pos.x = parent.pos.x + (parent.w * x/100);
        this.pos.y = parent.pos.y + (parent.h * y/100);
        this.w = (parent.w * w/100);
        this.h = (parent.h * h/100);
    }
}

class ObserverElement3D extends ObserverElement {
    protected Vector3 pos;

    // Use: An initial parent element that governs a chain. Its children are not positioned relatively but are BOUND.
    public ObserverElement3D(float x, float y, float z, float w, float h, int colour, boolean startActive){
        super(w, h, colour, startActive);
        pos = new Vector3(x, y, z);

        UI.current3DElements.add(this);
    }

    // Use: A child element that is not positioned relatively. Its movement is BOUND to its parent.
    public ObserverElement3D(float x, float y, float z, float w, float h, int colour, boolean startActive, ObserverElement3D parent){
        this(x, y, z, w, h, colour, startActive);
        this.parent = parent;
        parent.children.add(this);
    }
}

// Extensions of ObserverElement
// UI elements that can be placed. Spatial elements mean they are 3D.

// UI Element: Menu
// CONTAINER
// Exclusively a container element, it will overlap menus that were drawn before it, and overlap ALL other elements.
class Menu extends ObserverElement2D {
    Menu(float x, float y, float w, float h, int colour, boolean startActive){
        super(x, y, w, h, colour, startActive);
    }

    Menu(float x, float y, float w, float h, int colour, boolean startActive, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
    }

    Menu(int x, int y, int w, int h, int colour, boolean startActive, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
    }
}

// UI Element: Button
// ITEM - ACTIVATOR
// Supports effector functions (onHover, onClick). Drawn as a 2D rectangle.
// TODO: Implement image and styling functionality.
class Button extends ObserverElement2D {
    protected Event event;

    Button(float x, float y, float w, float h, int colour, boolean startActive, Event event){
        super(x, y, w, h, colour, startActive);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    Button(float x, float y, float w, float h, int colour, boolean startActive, Event event, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    Button(int x, int y, int w, int h, int colour, boolean startActive, Event event, ObserverElement2D parent){
        super(x, y, w, h, colour, startActive, parent);
        this.event = event;
        UI.currentButtonElements.add(this);
    }

    public void onMouseClicked(){
        event.Perform();
    }

    public void onMouseHover() {
        this.hovered = true;
    }
}

// OBJECT Element: Sphere
// WORLD
// Can be bonded to other 3D elements, BINDING its movement.
// TODO: Add further properties.
class SpatialSphere extends ObserverElement3D {
    SpatialSphere(float x, float y, float z, float r, int colour, boolean startActive) {
        super(x, y, z, r, r, colour, startActive);
        UI.currentAtoms.add(this);
    }

    SpatialSphere(float x, float y, float z, float r, int colour, boolean startActive, ObserverElement3D parent) {
        super(x, y, z, r, r, colour, startActive, parent);
        UI.currentAtoms.add(this);
    }
}
interface Event {
    public void Perform();
}

class ObserverEvents {
    class PrintMessage implements Event {
        String expStr;

        PrintMessage(String expStr) {
            this.expStr = expStr;
        }

        public void Perform()
        {
            println("You clicked on me, " + expStr);
        }
    }

    class RotateCameraY implements Event {
        public void Perform() {
            Camera.rotY += radians(10);
            println("Rotating");
        }
    }
}
    public void settings() {  size(1280, 720, P3D); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "nanobuilder" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
