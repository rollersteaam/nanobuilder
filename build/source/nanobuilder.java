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
ObserverElement taskMenu;
Observer Camera;

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
        rotateX(rotX);
        rotateY(rotY);
        rotateZ(rotZ);
    }
}

class Position { // created mainly for the screen to world conversion
    float x;
    float y;

    public Position(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

public Position ScreenToWorldSpace(float x, float y) {
    float cameraScale = 1 + (Camera.z*-1/50 / 100); // Times the translation by *-1 to flip its sign.

    float newX = (x - Camera.x) * cameraScale; // this is inverted because the camera represents its translation, not its current position...
    float newY = (y - Camera.y) * cameraScale;

    return new Position(newX, newY);
}

public void setup() {
    
    

    float screenW = width; // instantiate as floats so we can use maths on them
    float screenH = height;

    /* Syntax for most ObserverElements
     Button testButt1 = new Button(
     10, = X
     2, = Y
     80, = W
     5, = H
     color(100), = COLOUR
     sideMenu, = PARENT
     1 = DYNAMIC, DON'T INCLUDE IF STATIC
     );
     */

    Camera = new Observer();
    taskMenu = new ObserverElement(0f, 0f, screenW*0.2f, screenH, color(165, 165, 235), true, true);

    ObserverEvents.printMessage[] aLangLib = new ObserverEvents.printMessage[2];
    aLangLib[0] = UI.Events.new printMessage("Welcome to Nanobuilder.");
    aLangLib[1] = UI.Events.new printMessage("This message is in an array!");

    Event[] eventLib = new Event[1];
    eventLib[0] = UI.Events.new printMessage("" + taskMenu.Colour);

    Button taskMenuButton1 = new Button(10, 12, 80, 5, color(200, 150, 150), true, UI.Events.new rotateCameraY(), taskMenu);
    Button taskMenuButton2 = new Button(10, 19, 80, 5, color(150, 200, 150), true, aLangLib[1], taskMenu);
    Button taskMenuButton3 = new Button(10, 26, 80, 5, color(150, 150, 200), true, eventLib[0], taskMenu);

    SpatialSphere myNewSphere = new SpatialSphere(500, 500, 50, color(135, 135, 135), true);
    SpatialSphere myNewSphere2 = new SpatialSphere(700, 500, 50, color(185, 135, 135), true);
    SpatialSphere myNewSphere3 = new SpatialSphere(900, 500, 50, color(135, 135, 185), true);
}

public void draw() {
    background(215, 215, 255);
    lights();

    UI.ParseKeyTriggers();
    //UI.ParseMouseTriggers();

    UI.DrawActiveScreenElements();

    Camera.Observe();
    UI.DrawActiveElements();
}

public void mouseClicked() {
    Position instance = ScreenToWorldSpace(mouseX, mouseY); // record an initial instance because mouse position could vary over the time it takes to iterate through current buttons, progressively slower the more buttons exist too.
    int instanceScrX = mouseX;
    int instanceScrY = mouseY;

    boolean eventCompleted = false;

    for (int i = 0; i < UI.CurrentButtonElements.size(); i++) { // buttons don't use standardised instance coordinates, because they are 2D elements they only need to check screen relative coordinates
        Button target = UI.CurrentButtonElements.get(i);

        if (!target.active) continue;

        if (instanceScrX >= target.x && instanceScrX <= (target.x + target.w) && instanceScrY >= target.y && instanceScrY <= (target.y + target.h)) { // simple boundary check
            target.onMouseClicked();
            eventCompleted = true;
        }
    }

    if (eventCompleted) return;

    Position closestAtom = new Position(0, 0);

    for (int i = 0; i < UI.CurrentAtoms.size(); i++) {
        SpatialSphere target = UI.CurrentAtoms.get(i);

        if (closestAtom.x == 0) {
            closestAtom.x = target.x;
            closestAtom.y = target.y;
        }

        if (dist(instance.x, instance.y, target.x, target.y)  < dist(instance.x, instance.y, closestAtom.x, closestAtom.y)) {
            closestAtom.x = target.x;
            closestAtom.y = target.y;
        }

        if (i == UI.CurrentAtoms.size() - 1) {
            println(instance.x + " compared to " + closestAtom.x + " and ");
            println(instance.y + " compared to " + closestAtom.y + " done ");
        }

        // State 1 - Move object to mouse position on click
        if (target.beingMoved) {
            println("Placing object.");
            target.x = instance.x;
            target.y = instance.y;
            target.beingMoved = false;
            return;
        }

        // State 2 - Select object for movement on click
        if (instance.x >= target.x - target.w && instance.x <= (target.x + target.w) && instance.y >= target.y - target.h && instance.y <= (target.y + target.h)) {
            if (target.active) {
                target.beingMoved = true;
                println("Move is registered");
                return; // remove this line to create a weird morphing glitch between two spheres
            }
        }
    }

    println("I'm clicking");
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
class MasterObserver {
    public ArrayList<ObserverElement> CurrentGUIElements = new ArrayList<ObserverElement>();
    
    public ArrayList<ObserverElement> CurrentScreenElements = new ArrayList<ObserverElement>();
    public ArrayList<Button> CurrentButtonElements = new ArrayList<Button>();
    public ArrayList<SpatialSphere> CurrentAtoms = new ArrayList<SpatialSphere>();

    ObserverEvents Events = new ObserverEvents();

    int lastMouseX;
    int lastMouseY;

    public void DrawActiveScreenElements() {
        for(int i = 0; i<CurrentScreenElements.size(); i++) {
            ObserverElement target = CurrentGUIElements.get(i);
            if (!target.enabled || !target.active) continue;
            
            if (target.isFading) {
                DrawFadeElement(target);
                continue;
            }
            
            if (target instanceof Button){
                stroke(30);
            } else { // Generic template
                noStroke();
            }
            
            fill(target.Colour);
            rect(target.x, target.y, target.w, target.h);
        }
    }

    public void DrawActiveElements(){
        for(int i=0; i<CurrentGUIElements.size(); i++){
            ObserverElement target = CurrentGUIElements.get(i);
            if (!target.enabled || !target.active || target.screenElement) continue;

            if (target.isFading) { // Handle fade elements elsewhere, bypasses the need for running a second list iteration
                DrawFadeElement(target);
                continue;
            }

            if (target instanceof Button){
                stroke(30);
            } else { // Generic template
                noStroke();
            }
            
            fill(target.Colour);
            
            pushMatrix();
            if (target instanceof SpatialSphere) {
                if (target.beingMoved) {
                    Position newPos = ScreenToWorldSpace(mouseX, mouseY);
                    target.x = newPos.x;
                    target.y = newPos.y;
                }
                
                translate(target.x, target.y);
                sphere(target.w);
            } else if (target instanceof Button) { 
                translate(0, 0, 0.1f);
                rect(target.x, target.y, target.w, target.h);
            } else { // Generic template
                rect(target.x, target.y, target.w, target.h);
            }
            popMatrix();
        }
    }

    public void DrawFadeElement(ObserverElement target) {
        pushMatrix();
        if (target instanceof Button){
            stroke(30);
        } else { // Generic template
            noStroke();
        }

        float timeElapsed = millis() - target.fadeStartMillis;
        println("The time is " + timeElapsed/target.fadeDuration);
        
        if (target.faded) { // fading IN
            
            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread
                println(timeElapsed / target.fadeDuration);
                fill(target.Colour, lerp(0, 255, timeElapsed/target.fadeDuration));
            } else { // we're finished#
                fill(target.Colour, 255); // second 'correction' needed to complete the 'journey' so transition is smooth
                println("We're done");
                
                target.active = !target.active;
                target.isFading = false;
                target.faded = false;
            }
            
        } else { // fading OUT
            
            if (timeElapsed < target.fadeDuration) { // we don't use while here otherwise the fading process would halt the Draw method as we don't make a seperate thread    
                println(timeElapsed / target.fadeDuration);
                fill(target.Colour, lerp(255, 0, timeElapsed/target.fadeDuration));
            } else { // we're finished
                fill(target.Colour, 0); // second 'correction' needed to complete the 'journey' so transition is smooth
                println("We're done fading out");
                
                target.active = !target.active;
                target.isFading = false;
                target.faded = true;
            }          
            
        }    

        rect(target.x, target.y, target.w, target.h);
        popMatrix();
    }
    
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
        if (mouseX <= taskMenu.w){ 
            if(taskMenu.enabled && !taskMenu.active && !taskMenu.isFading) taskMenu.fadeToggleActive(400);
            if(!taskMenu.enabled) println("I received the trigger but the task menu is disabled.");
            if(taskMenu.active) println("I received the trigger but the menu's already active.");
            if(taskMenu.isFading) println("I received the trigger but the task menu is currently fading.");
        } else {
            if(taskMenu.enabled && taskMenu.active && !taskMenu.isFading) taskMenu.fadeToggleActive(400);
            if(!taskMenu.enabled) println("I received the trigger but the task menu is disabled.");
            if(!taskMenu.active) println("I received the trigger but the menu's already inactive.");
            if(taskMenu.isFading) println("I received the trigger but the task menu is currently fading.");
        }
    }
}
class ObserverElement{
    protected float x, y, w, h;
    protected int Colour = color(35);
    protected ObserverElement parent;
    protected ArrayList<ObserverElement> children = new ArrayList<ObserverElement>();

    protected boolean enabled = true;
    protected boolean active = true;
    protected boolean screenElement = false;
    protected boolean beingMoved = false;

    protected boolean faded = false;
    protected boolean isFading = false;
    protected int fadeStartMillis;
    protected int fadeDuration = 1000;

    public ObserverElement(float x, float y, float w, float h, int Colour, boolean startActive){
        this.Colour = Colour;
        this.x = x; this.y = y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }

    public ObserverElement(float x, float y, float w, float h, int Colour, boolean startActive, ObserverElement parent){
        parent.children.add(this);
        this.parent = parent;

        this.Colour = Colour;
        this.x = parent.x + x; this.y = parent.y + y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }

    // Through overloaded matches, this UI element will have dimensions based off percentages of its parent allowing for dynamic UI design
    // This is why ObserverElements should NOT be constructed with normal integer values unless intended to, because it will create it with a percentage relevance to its parent
    public ObserverElement(int x, int y, int w, int h, int Colour, boolean startActive, ObserverElement parent){
        parent.children.add(this);
        this.parent = parent;
        this.screenElement = parent.screenElement;

        this.Colour = Colour;
        this.x = parent.x + (parent.w * x/100); this.y = parent.y + (parent.h * y/100); this.w = (parent.w * w/100); this.h = (parent.h * h/100);
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentGUIElements.add(this);
    }
    
    public ObserverElement(float x, float y, float w, float h, int Colour, boolean startActive, boolean screenElement){
        this.screenElement = screenElement;

        this.Colour = Colour;
        this.x = x; this.y = y; this.w = w; this.h = h;
        this.active = startActive;
        this.faded = !this.active;

        UI.CurrentScreenElements.add(this);
        UI.CurrentGUIElements.add(this);
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

// Extensions of ObserverElement
// UI elements that can be placed. Spatial elements mean they are 3D.

class Button extends ObserverElement{
    Event event;
    
    Button(float x, float y, float w, float h, int Colour, boolean startActive, Event event){
        super(x, y, w, h, Colour, startActive);
        UI.CurrentButtonElements.add(this);
        this.event = event;
    }
    
    Button(float x, float y, float w, float h, int Colour, boolean startActive, Event event, ObserverElement parent){
        super(x, y, w, h, Colour, startActive, parent);
        UI.CurrentButtonElements.add(this);
        
        if (parent.screenElement) {
            screenElement = true;
            UI.CurrentScreenElements.add(this);
        }
        
        this.event = event;
    }
 
    Button(int x, int y, int w, int h, int Colour, boolean startActive, Event event, ObserverElement parent){
        super(x, y, w, h, Colour, startActive, parent);
        UI.CurrentButtonElements.add(this);
        
        if (parent.screenElement) {
            screenElement = true;
            UI.CurrentScreenElements.add(this);
        }
        
        this.event = event;
    }

    public void onMouseClicked(){
        event.Perform();
    }
}

class SpatialSphere extends ObserverElement {
    SpatialSphere(float x, float y, float r, int Colour, boolean startActive) {
        super(x, y, r, r, Colour, startActive);
        UI.CurrentAtoms.add(this);
    }
}
interface Event {
    public void Perform();
}

class ObserverEvents {
    class printMessage implements Event {
        String expStr;
        
        public printMessage(String expStr) {
            this.expStr = expStr;   
        }
        
        public void Perform()
        {
            println("You clicked on me, " + expStr);
        }
    }
    
    class rotateCameraY implements Event {
        public void Perform() {
            Camera.rotY += radians(10);
            println("Rotating");
        }
    }        
}
    public void settings() {  size(1280, 720, P3D);  smooth(); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "nanobuilder" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
