import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import queasycam.*; 
import java.awt.*; 
import processing.event.KeyEvent; 
import java.lang.Runnable; 
import java.util.Deque; 
import java.util.ArrayDeque; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Nanobuilder extends PApplet {

 // cam (Camera)
 // robot (Mouse manipulation)





Camera cam;
Robot robot;
SelectionManager selectionManager;
UIManager uiManager;
UIFactory uiFactory;

ArrayList<Particle> particleList = new ArrayList<Particle>();

/*
MAIN FILE
The primary interface between Processing (and its libraries) and the program,
allowing all modules and classes to work properly.
*/
public interface Runnable {
    public void run();
}

public void setup() {
    

    try {
        robot = new Robot();
    } catch (AWTException e) {}

    registerMethod("keyEvent", this);

    cam = new Camera(this);
    // cam.speed = 7.5;              // default is 3
    cam.speed = 7.5f;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;
    cam.position = new PVector(-width, height/2, 0);

    float fov = PI/3.0f;
    float cameraZ = (height/2.0f) / tan(fov/2.0f);
    perspective(fov, PApplet.parseFloat(width)/PApplet.parseFloat(height), cameraZ/10.0f / 300, cameraZ*10.0f * 300);
    
    selectionManager = new SelectionManager();
    uiManager = new UIManager();
    uiFactory = new UIFactory();
    
    // for (int i = 0; i < 50; i++) {
        // new Atom();
    // }
    // Particle proton = new Proton(0, 0, 0);
    // new Electron(0, 500, 0, proton);
    // new Electron(0, -500, 0, proton);
    // new Atom(0, 500, 0, 100);
    new Atom();
    // new Electron(0, 2000, 0, proton);
    // new Electron(0, -2000, 0, proton);
    // new Electron(0, 1000, 0);
}

public void draw() {
    // Undoes the use of DISABLE_DEPTH_TEST so 3D objects act naturally after it was called.
    hint(ENABLE_DEPTH_TEST);

    background(100, 100, 220);
    lights();
    noStroke();

    float biggestDistance = 0;

    for (Particle particle : particleList) {
        particle.evaluatePhysics();
        particle.display();

        float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

        if ((dist > biggestDistance) || (biggestDistance == 0)) {
            biggestDistance = dist;
        }
    }

    drawOriginArrows();
    drawOriginGrid();

    // pushStyle();
    // // stroke(color(70, 70, 255));
    // // strokeWeight(8);
    // // fill(255, 0, 0, map(biggestDistance, 900, 1000, 0, 25));
    // // box(2000);
    // fill(255, 0, 0, map(biggestDistance, 9000, 10000, 0, 25));
    // box(20000);
    // popStyle();

    /*
        2D drawing beyond here ONLY.
    
        This causes any more drawing to appear as a 'painting over other objects'
        allowing 2D elements to be rendered in the same environment as 3D ones.
    */
    hint(DISABLE_DEPTH_TEST);

    selectionManager.updateSelectionMovement();
    selectionManager.updateGroupSelectionDrawing();

    uiManager.checkHoverForButtons();
    uiManager.draw();

    // SPACE
    if (keys.containsKey(32) && keys.get(32)) cam.velocity.sub(PVector.mult(cam.getUp(), cam.speed));
    // SHIFT
    if (keys.containsKey(16) && keys.get(16)) cam.velocity.add(PVector.mult(cam.getUp(), cam.speed));
}

public void mousePressed(MouseEvent event) {
    // If selection agent's events have been triggered, then we are finished for this mouse event.
    if (mouseButton == LEFT)
        if (selectionManager.mousePressed()) return;
}

public void mouseReleased() {
    uiManager.checkClickForButtons();

    if (mouseButton == LEFT) {
        uiManager.leftClick();
        if (selectionManager.mouseReleased()) return;
    } else if (mouseButton == RIGHT) {
        uiManager.rightClick();
    }
    
    // TODO: Model selectionManager after uiManager.
}

public void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    if (selectionManager.mouseWheel(e)) return;
}

public void keyPressed() {
    if (key == 'z')
        cam.togglePilot();
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

    switch (event.getAction()) {
        case KeyEvent.PRESS:
            keys.put(key, true);
            break;
        case KeyEvent.RELEASE:
            keys.put(key, false);
            break;
    }
}

// Draws a lattice (structured cube) of particles.
public void drawParticleLattice() {
    for (int y = 0; y < 5; y++) {
        for (int z = 0; z < 5; z++) {
            for (int x = 0; x < 5; x++) {
                new Particle(200 * x, 200 * y, 200 * z, 100); 
            }
        }
    }   
}

// Draws arrows pointing out from the origin point of the scene.
public void drawOriginArrows() {
    pushStyle();
    fill(color(0, 0, 255));
    box(20, 20, 300);
    
    fill(color(0, 255, 0));
    box(20, 300, 20);

    fill(color(255, 0, 0));
    box(300, 20, 20);
    popStyle(); 
}

// Draws squares around an area on the origin point of the scene.
public void drawOriginGrid() {
    for (int y = 0; y < 5; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = 0; x < 5; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = 0; y < 5; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    }
    for (int y = -5; y < 0; y ++) {
        for (int x = -5; x < 0; x ++) {
            pushStyle();
            pushMatrix();
            rotateX(PI/2);
            stroke(255, 180);
            noFill();
            rect(100 * x, 100 * y, 100, 100);
            popMatrix();
            popStyle();
        }
    } 
}
class Atom extends Particle {
    Atom(float x, float y, float z, float radius) {
        super(x, y, z, radius);
        Proton contentOne = new Proton(x, y, z);
        new Electron(x + contentOne.r + 10, y + contentOne.r + 10, z + contentOne.r + 10, contentOne);
    }
    
    Atom() {        
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            round(random(200, 600))
        );
    }

    public @Override
    void display() {
        shape.setFill(
            color(
                red(currentColor),
                green(currentColor),
                blue(currentColor),
                lerp(0, 255, PVector.dist(cam.position, pos) / 2000)
            )
        );
        super.display();
    }
}
class ButtonUI extends UIElement {
    Runnable function;
    
    ButtonUI(float x, float y, float w, float h, int colour, Runnable function) {
        super(x, y, w, h, colour);
        this.function = function;
    }

    public @Override
    void display() {
        super.display();

        stroke(160, 160, 255, 230);
        strokeWeight(2);
        rect(position.x, position.y, size.x, size.y);

        finishDrawing();
    }

    public void hover() {
        colour = color(200, 200, 255);
    }

    public void unhover() {
        colour = color(200);
    }

    public void click() {
        if (!active) return;
        
        function.run();
    }
}
class Camera extends QueasyCam {
    /*
    Completing our camera extension, an argument of our processing 'app'
    is required to be passed to QueasyCam's constructor (Camera's parent).
    */
    Camera(PApplet applet) {
        super(applet);
    }
    
    public float getRotY() {
        return abs(tilt % PI);
    }

    public float getRotYDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(tilt % PI));
    }
    
    public float getRotX() {
        return abs(pan % (2 * PI));
    }

    public float getRotXDeg() {
        // An absolute value has to be returned here so that the orientation is easier to handle.
        return abs(degrees(pan % (2 * PI)));
    }

    public float getXAxisModifier() {
        float rotX = getRotXDeg();
        float mod = 0;
        println(rotX);

        if (rotX >= 0 && rotX <= 180)
            mod = (rotX - 90) / 90;
        else // (rotX > 180 && rotX <= 360)
            mod = (rotX - 270) / 90;
        
        println(abs(mod));
        return abs(mod); // Modifier always between 0 or 1.
    }

    public float getZAxisModifier() {
        float rotX = getRotXDeg();
        float mod = 0;
        println(rotX);

        if (rotX >= 0 && rotX <= 90)
            mod = rotX / 90;
        else if (rotX > 90 && rotX <= 270)
            mod = (rotX - 180) / 90;
        else // (rotX > 270 && rotX <= 360)
            mod = (rotX - 360) / 90;

        println(abs(mod));
        return abs(mod);
    }

    public void pilot() {
        sensitivity = 0;
        robot.mouseMove(width/4 + width/2, height/2 + height/4);
        cursor();
        piloting = true;
    }

    public void stopPiloting() {
        sensitivity = 0.5f;
        noCursor();
        piloting = false;
    }

    private boolean piloting = true;

    public void togglePilot() {
        if (piloting)
            stopPiloting();
        else
            pilot();
    }
}
class ContextMenu extends UIElement {
    RectangleUI mainPanel;
    ButtonUI testButton;
    TextUI testText;

    Runnable createAtomAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            new Particle(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 100);
        }
    };

    Runnable createElectronAtCamera = new Runnable() {
        public void run() {
            PVector fwd = cam.getForward();
            new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
        }
    };

    Runnable deleteItemsInSelection = new Runnable() {
        public void run() {
            selectionManager.deleteItemsInSelection();
        }
    };

    Runnable paintAtom = new Runnable() {
        public void run() {
            selectionManager.paintParticles();
        }
    };

    ContextMenu(float x, float y, float w, float h, int colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(3, 3, w + 4, h + 4, color(135));
        mainPanel = uiFactory.createRect(1, 1, w, h, colour);

        testButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0), createAtomAtCamera);
        testText = uiFactory.createText(w/4, 40/4 + 2.5f, w - 12, 38, color(70), "Add Atom");
        
        UIElement testButton2 = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0), deleteItemsInSelection);
        UIElement testText2 = uiFactory.createText(w/4, 40/4 + 2.5f + 40 + 4, w - 12, 38, color(70), "Delete");

        appendChild(background);

        appendChild(mainPanel);
        appendChild(testButton);
        appendChild(testText);

        appendChild(testButton2);
        appendChild(testText2);

        UIElement paint = uiFactory.createButton(5, 5 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 255, 0), paintAtom);
        UIElement paintText = uiFactory.createText(34, 8, w - 12, 38, color(70), "Paint Red");
        paint.appendChild(paintText);

        appendChild(paint);
        UIElement electron = uiFactory.createButton(5, 5 + 40 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 0, 255), createElectronAtCamera);
        UIElement electronText = uiFactory.createText(32, 8, w - 12, 38, color(70), "Create Electron");
        electron.appendChild(electronText);

        appendChild(electron);
        
        // UI elements start active by default, hiding when construction is finished is standard practice for menus.
        hide();
    }

    @Override
    public void show() {
        super.show();
        setPosition(new PVector(mouseX, mouseY));
    }
}
class Electron extends Particle {
    final int X_DOMINANT = 0;
    final int Y_DOMINANT = 1;
    final int Z_DOMINANT = 2;

    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Particle proton) {
        super(x, y, z, random(0.84f, 0.87f) * 100 / 3);

        charge = -1.6f * pow(10, -19);
        mass = 9.10938356f * pow(10, -31);

        baseColor = color(0, 0, 255);
        revertToBaseColor();

        // If no initial proton then spawn with random velocity.
        if (proton == null) {
            velocity = PVector.random3D().setMag(30);
            return;
        }

        PVector diff = PVector.sub(pos, proton.pos).normalize();
        PVector diffMag = new PVector(
            abs(diff.x),
            abs(diff.y),
            abs(diff.z)
        );
        int magRecordCoordinate = -1;
        float magRecord = 0;
        if (diffMag.x < magRecord || magRecord == 0) {
            magRecord = diffMag.x;
            magRecordCoordinate = X_DOMINANT;
        }

        if (diffMag.y < magRecord) {
            magRecord = diffMag.y;
            magRecordCoordinate = Y_DOMINANT;
        }

        if (diffMag.z < magRecord) {
            magRecord = diffMag.z;
            magRecordCoordinate = Z_DOMINANT;
        }

        PVector toCross = new PVector();
        if (magRecordCoordinate == X_DOMINANT) {
            toCross = new PVector(1, 0, 0);
        } else if (magRecordCoordinate == Y_DOMINANT) {
            toCross = new PVector(0, 1, 0);
        } else if (magRecordCoordinate == Z_DOMINANT) {
            toCross = new PVector(0, 0, 1);
        }

        PVector cross = diff.cross(toCross);

        /*
        Substituting circular motion and couloumb's law...
        F = mv^2/r
        Fr
        - = v^2
        m
        where F = Qq
                  -
                  4(PI)(E0)R^2

        This value returns what the magnitude of the perpendicular
        vector to the proton must be for circular motion to take place.

        This is used because we are trying to model the physics, so some
        assumptions (like the initial state of an atom) need to be initially
        assumed. Any changes after are then just part of the simulated space,
        so should be dynamic.
        */
        velocity = cross.setMag(
            sqrt(
                // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
                abs(
                    proton.calculateCoulombsLawForceOn(this) * 100 * PVector.dist(proton.pos, this.pos) / (float) mass
                )
            )
        );
    }

    class TrailElement {
        PVector position;
        PShape shape;

        TrailElement() {
            position = pos.copy();

            pushStyle();
            fill(0);
            shape = createShape(SPHERE, 10);
            shape.setFill(color(0));
            popStyle();
        }
    }

    private class Point {
        float x;
        float y;
        float z;

        Point() {
            x = pos.x;
            y = pos.y;
            z = pos.z;
        }
    }

    Deque<Point> trail = new ArrayDeque<Point>();

    public @Override
    void display() {
        super.display();

        pushMatrix();
        pushStyle();
            fill(0);
            stroke(0);
            strokeWeight(4);
            line(pos.x, pos.y, pos.z, pos.x + velocity.x, pos.y + velocity.y, pos.z + velocity.z);
        popMatrix();
        popStyle();

        Point point = new Point();
        trail.push(point);

        int trailSize = 600;

        Point lastPoint = null;
        int counter = 0;
        for (Point element : trail) {
            counter++;
            pushMatrix();
            pushStyle();
                fill(0);
                stroke(0, map(counter, 0, (trailSize - 1), 255, 0));
                strokeWeight(4);

                if (lastPoint != null)
                    line(lastPoint.x, lastPoint.y, lastPoint.z, element.x, element.y, element.z);

                lastPoint = element;
            popMatrix();
            popStyle();
        }

        if (trail.size() > trailSize)
            trail.removeLast();
    }
}
class Menu extends UIElement {
    Menu(float x, float y, float w, float h, int colour) {
        super(x, y, w, h, colour);
    }

    @Override
    public void show() {
        super.show();
    }
}
class Neutron extends Particle {
    Neutron(float x, float y, float z) {
        super(x, y, z, random(0.84f, 0.87f) * 100);
        charge = 0;
        mass = 1.6726219f * pow(10, -10);

        baseColor = color(255);
        revertToBaseColor();
    }

    public @Override
    void display() {
        super.display();

        // TODO: Implement gravitational force (probably)
    }
}
class Particle {
    PVector pos = new PVector();
    PVector velocity = new PVector();
    PVector acceleration = new PVector();
    
    float r;

    float charge;
    double mass;

    int baseColor;
    int currentColor;

    PShape shape;

    Particle(float x, float y, float z, float r) {
        pos = new PVector(x, y, z);
        this.r = r;
        baseColor = color(random(90, 255), random(90, 255), random(90, 255));
        currentColor = baseColor;
        fill(currentColor);

        shape = createShape(SPHERE, r);
        shape.setStroke(false);
        shape.setFill(currentColor);

        // velocity = velocity.random3D().mult(10);
        // acceleration = acceleration.random3D().mult(5);

        particleList.add(this);
    }

    Particle() {
        this(
            random(-500, 500),
            random(-500, 500),
            random(-500, 500),
            round(random(25, 100))
        );
    }

    public void delete() {
        shape = null;
        particleList.remove(this);
    }

    public void select() {
        // currentColor = color(135);
        // acceleration.mult(0);
        // velocity.mult(0);
    }

    public void deselect() {
        // revertToBaseColor();
        // acceleration.mult(0);
        // velocity.mult(0);
    }

    public void setColour(int colour) {
        shape.setFill(colour);
        currentColor = colour;
    }

    public void revertToBaseColor() {
        shape.setFill(baseColor);
        currentColor = baseColor;
    }

    public void setPosition(PVector newPos) {
        pos = newPos.copy();
    }

    public void applyForce(Particle particle, float force) {
        /*
            Acceleration is a vector quantity (has both magnitude and direction),
            the direction is the vector to the CoM of the particle, so the magnitude must be
            the force from coulomb's law.

            The 100 mult increases the force given from the equation, because pixels need to translate
            into world space for a scale.
        */
        PVector vector = PVector.sub(particle.pos, pos);
        vector.setMag(force * 100 / (float) particle.mass);
        particle.acceleration.add(vector);
    }

    public void evaluateElectricalField() {
        for (Particle particle : particleList) {
            if (particle == this) continue;
            applyForce(particle, calculateCoulombsLawForceOn(particle));
        }
    }

    public void evaluatePhysics() {
        velocity.add(acceleration);
        pos.add(velocity);
        /*
        Acceleration once 'dealt' is never kept, since it converts into velocity.
        This line resets acceleration so we're ready to regather all forces next frame.
        */
        acceleration = new PVector();
    }

    public void display() {
        // if (pos.x > 10000 || pos.x < -10000) {
        //     pos.x -= velocity.copy().setMag(r*2).x;
        //     velocity.x *= -1;
        //     velocity.x *= 0.75;
        // }

        // if (pos.y > 10000 || pos.y < -10000) {
        //     pos.y -= velocity.copy().setMag(r*2).y;
        //     velocity.y *= -1;
        //     velocity.y *= 0.75;
        // }

        // if (pos.z > 10000 || pos.z < -10000) {
        //     pos.z -= velocity.copy().setMag(r*2).z;
        //     velocity.z *= -1;
        //     velocity.z *= 0.75;
        // }

        // Added radius so pop-in limits are more forgiving and less obvious.
        // float screenX = screenX(pos.x + r, pos.y + r, pos.z - r);
        // float screenY = screenY(pos.x + r, pos.y + r, pos.z - r);
  
        // Disregard objects outside of camera view, saving GPU cycles and improving performance.
        // if ((screenX > width) || (screenY > height) || (screenX < 0) || (screenY < 0)) 
        //     return;
        
        /*
        Push functions save the current "drawing" settings for what they do, and allow
        "popping" to restore the settings back to prvious ones after you're finished.

        e.g. pushStyle saves current drawing styles.
        pushMatrix saves the current translated position which any drawing throughout the program would otherwise be affected by.
        */
        pushStyle();
        pushMatrix();
        
        translate(pos.x, pos.y, pos.z);
        
        // sphere(r);
        shape(shape);

        // Guides //
        noFill();
        stroke(255, 170);

        rect(-r, -r, r*2, r*2);
        rotateY(radians(90));
        rect(-r, -r, r*2, r*2);
        
        popMatrix();
        popStyle();
    }

    public float calculateCoulombsLawForceOn(Particle targetParticle) {
        PVector vector = PVector.sub(targetParticle.pos, pos);
        /*
        Coulomb's Law of Electrostatic Force
        F = Qq
            --
            4*PI*8.85*10^-12*r^2

        where vector.mag() == r
        */
        float topExpression = targetParticle.charge * charge;
        float bottomExpression = 4 * PI * 8.85f * pow(10, -12) * pow(vector.mag(), 2);
        /*
        If the force is infinite (which should be impossible)
        then disregard current frame.
        */
        if (bottomExpression == 0) return 0;
        return topExpression / bottomExpression;
    }
}
class Proton extends Particle {
    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z) {
        super(x, y, z, random(0.84f, 0.87f) * 100);
        charge = 1.6f * pow(10, -19);
        mass = 1.6726219f * pow(10, -27);

        baseColor = color(255, 0, 0);
        revertToBaseColor();
    }

    public @Override
    void evaluatePhysics() {
        evaluateElectricalField();
        super.evaluatePhysics();
    }
}
class RectangleUI extends UIElement {
    RectangleUI(float x, float y, float w, float h, int colour) {
        super(x, y, w, h, colour);
    }

    public @Override
    void display() {
        super.display();
        // stroke(255, 160);
        rect(position.x, position.y, size.x, size.y);

        finishDrawing();
    }
}
/*
SelectionManager handles the interaction of selecting
particles in space. It also updates the movement of all
particles in its possession.
*/

class SelectionManager {
    /*
    Selection shouldn't be used outside of the selection agent, as it pertains
    to no other context.

    Class was required to be created as the Vector from the camera to the particle position
    needed to be saved for multiple particles, so a single field to save that vector was not enough.
    */
    private class Selection {
        private final Particle particle;
        /*
        Defined a getter and declared private so read-only, if this gets changed accidently
        the reason for the field existing becomes redundant.
        */
        private final PVector fromCameraVector;

        private Selection(Particle particle) {
            this.particle = particle;
            fromCameraVector = PVector.sub(particle.pos, cam.position);
        }

        public PVector getFromCameraVector() {
            return fromCameraVector.copy();
        }

        public Particle getParticle() {
            return particle;
        }
    }

    ArrayList<Selection> selectedParticles = new ArrayList<Selection>();
    float hoveringDistanceMult = 1;

    public boolean hasActiveSelection() {
        if (selectedParticles.size() == 0)
            return false;
        else
            return true;
    }

    public void select(Particle particle) {
        if (particle == null) {
            println("URGENT: SelectionManager was requested to select a null reference.");
            Thread.dumpStack();
            return;
        }

        particle.select();
        selectedParticles.add(new Selection(particle));
    }

    public void cancel() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().deselect();
        }

        selectedParticles.clear();
        hoveringDistanceMult = 1;
    }

    public void deleteItemsInSelection() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().delete();
        }

        cancel();
    }

    public void paintParticles() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().setColour(color(255, 0, 0));
        }

        cancel();
    }

    PVector selectingStartPos;
    RectangleUI groupSelection;

    public void startSelecting() {
        selectingStartPos = new PVector(mouseX, mouseY);
        groupSelection = uiFactory.createRect(selectingStartPos.x, selectingStartPos.y, 1, 1, color(30, 30, 90, 80));
    }

    public void stopSelecting() {
        if (selectingStartPos == null) return;

        PVector lowerBoundary = new PVector(selectingStartPos.x, selectingStartPos.y);
        PVector higherBoundary = new PVector(mouseX, mouseY);

        /*
        Iterate through all existing particles and compare their screen coordinates
        to the selected screen area for all 4 cases, selecting all particles that
        intersect with the area.
        */
        for (Particle particle : particleList) {
            float screenPosX = screenX(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosXNegativeLimit = screenX(particle.pos.x - particle.r, particle.pos.y, particle.pos.z);
            float screenPosXPositiveLimit = screenX(particle.pos.x + particle.r, particle.pos.y, particle.pos.z);
            
            float screenPosY = screenY(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosYNegativeLimit = screenY(particle.pos.x, particle.pos.y - particle.r, particle.pos.z);
            float screenPosYPositiveLimit = screenY(particle.pos.x, particle.pos.y + particle.r, particle.pos.z);
            
            float screenPosZ = screenZ(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosZNegativeLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z - particle.r);
            float screenPosZPositiveLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z + particle.r);

            // From top left to bottom right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit)
                select(particle);
            
            // From bottom left to top right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit)
                select(particle);

            // From bottom right to top left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit)
                select(particle);

            // From top right to bottom left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit)
                select(particle);

            // TODO: Investigate if Z values are accounted for in group selection.
        }

        selectingStartPos = null;
        uiManager.removeElement(groupSelection);
        groupSelection = null;
    }

    public boolean mousePressed() {
        // Case 2: Find a single particle at clicking location.
        for (Particle particle : particleList) {
            float screenPosX = screenX(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosXNegativeLimit = screenX(particle.pos.x - particle.r, particle.pos.y, particle.pos.z);
            float screenPosXPositiveLimit = screenX(particle.pos.x + particle.r, particle.pos.y, particle.pos.z);
            
            float screenPosY = screenY(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosYNegativeLimit = screenY(particle.pos.x, particle.pos.y - particle.r, particle.pos.z);
            float screenPosYPositiveLimit = screenY(particle.pos.x, particle.pos.y + particle.r, particle.pos.z);
            
            float screenPosZ = screenZ(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosZNegativeLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z - particle.r);
            float screenPosZPositiveLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z + particle.r);

            if (mouseX >= screenPosXNegativeLimit && mouseX <= screenPosXPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(particle);
                return true;
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (mouseX >= screenPosXPositiveLimit && mouseX <= screenPosXNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(particle);
                return true;
            }

            if (mouseX >= screenPosZNegativeLimit && mouseX <= screenPosZPositiveLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(particle);
                return true;
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (mouseX >= screenPosZPositiveLimit && mouseX <= screenPosZNegativeLimit && mouseY >= screenPosYNegativeLimit && mouseY <= screenPosYPositiveLimit) {
                select(particle);
                return true;
            }
        }



        // Case 3: Begin an area selection.
        startSelecting();

        // No interrupts passed, return and continue on the main calling routine.
        return false;
    }

    public boolean mouseReleased() {
        // // Case 1: Cancel selection.
        // if (hasActiveSelection()) {
        //     cancel();
        //     // return true;
        // }

        if (hasActiveSelection()) {
            cancel();
            // return true;
        }

        stopSelecting();

        return false;
    }

    public boolean mouseWheel(float e) {
        if (!hasActiveSelection()) return false;

        if (e > 0) // On Scroll Down
            // hoveringDistanceMult -= 0.5 * PVector.dist(cam.position, selectedparticle.pos) / 5000;
            hoveringDistanceMult -= 0.25f;
        else // On Scroll Up
            // hoveringDistanceMult += 0.5 / PVector.dist(cam.position, selectedparticle.pos) * 500;
            hoveringDistanceMult += 0.25f;

        return true;
    }

    public void updateGroupSelectionDrawing() {
        if (groupSelection == null) return;

        groupSelection.setSize(new PVector(mouseX - selectingStartPos.x, mouseY - selectingStartPos.y));
    }

    public void updateSelectionMovement() {
        if (!hasActiveSelection()) return;
 
        PVector forward = cam.getForward();

        // float dist = PVector.dist(cam.position, fromCameraVector);

        for (Selection selection : selectedParticles) {
            Particle particle = selection.getParticle();
            // fromCameraVector = PVector.sub(particle.pos, cam.position);
            // Normalize a copy, don't want to change the original reference otherwise that would occur every frame.
            // PVector fromCameraVectorNormalized = fromCameraVector.copy().normalize();

            // float yDistMul = PVector.dist(cam.position, particle.pos) / 900;
            // float xDistMul = PVector.dist(cam.position, particle.pos) / 500;

            // PVector cross = cam.position.copy().cross(particle.pos).normalize();

            // PVector normalizationConstant = new PVector(
            //     // map(mouseX, 0, width, -1, 1),
            //     0,
            //     map(mouseY, 0, width, -1, 1),
            //     map(mouseX, 0, width, -1, 1)
            // );

            // particle.setPosition( PVector.add(cam.position, new PVector(
                // Fine tune mode
                // (600 * hoveringDistanceMult) * forward.x,
                // (600 * hoveringDistanceMult) * forward.y,
                // (600 * hoveringDistanceMult) * forward.z )) );
                // (hoveringDistanceMult) * selection.getFromCameraVector().x,
                // (hoveringDistanceMult) * selection.getFromCameraVector().y,
                // (hoveringDistanceMult) * selection.getFromCameraVector().z )) );
            
            // The changes given by the mouse need to be added to the constant difference
            // fromCameraVector.add(new PVector(
                // (mouseX - pmouseX) * xDistMul * fromCameraVectorNormalized.x,
                // (mouseY - pmouseY) * yDistMul,
                // (mouseX - pmouseX) * xDistMul
                // ));

            // Picking guide //
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    
                    translate(particle.pos.x - 250, particle.pos.y, particle.pos.z - 250);
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
                    
                    translate(particle.pos.x, particle.pos.y - 250, particle.pos.z + 250);
                    rotateY(PI/2);
                    stroke(255, 180);
                    noFill();
                    
                    rect(100 * x, 100 * y, 100, 100);
                    popMatrix();
                }
            }
        }
    }
}
class TextUI extends UIElement {
    private String text;

    TextUI(float x, float y, float w, float h, int colour, String text) {
        super(x, y, w, h, colour);
        this.text = text;
    }

    public @Override
    void display() {
        super.display();

        textSize(18);
        text(text, position.x, position.y, size.x, size.y);

        finishDrawing();
    }
}
// Defining as abstract ensures UI element has to be inherited.
abstract class UIElement {
    /*
    Declare these final since the reference should NEVER change.
    
    If the references were changed to reflect another object,
    it could very easily cause a hard to detect overlapping issue
    that has potentially adverse effects.
    */
    protected PVector position;

    protected PVector size;
    protected int colour;
    protected boolean active = true;

    protected UIElement parent;
    protected ArrayList<UIElement> children = new ArrayList<UIElement>();

    UIElement(float x, float y, float w, float h, int colour) {
        position = new PVector(x, y);
        size = new PVector(w, h);
        this.colour = colour;
    }

    public void display() {
        pushStyle();
        pushMatrix();
        noLights();

        fill(colour);
        /*
        Get camera's forward pointing vector and begin to draw 2D element
        at a unit vector position (so it is created right in front of the camera's view).

        Then project it by 625 so it maps properly to 'pixel' form.
        */
        // getForward() returns a normalized vector (unit vector) that is helpful to us.
        PVector projection = PVector.add(cam.position, cam.getForward().copy().mult(625));
        translate(projection.x, projection.y, projection.z);

        /*
        Make the object's rotation have a relationship with camera rotation
        so that it is 'billboarded', and therefore rotationally stationary
        with camera view.
        */
        rotateY(radians(270) - cam.pan);
        rotateX(cam.tilt);

        translate(-width/2, -height/2);
        // Any screen drawing methods are now properly mapped to the camera.
    }

    /*
    Base display can't call the pops, and to conventionalize
    the process finishDrawing() visually tells me the element
    is properly implemented.
    */
    protected void finishDrawing() {
        popStyle();
        popMatrix();
    }

    public boolean checkIntersectionWithPoint(PVector v) {
        if(
            v.x > position.x &&
            v.x < (position.x + size.x) &&
            v.y > position.y &&
            v.y < (position.y + size.y)
        ) {
            return true;
        } else {
            return false;
        }
    }

    public PVector getPosition() {
        return position;
    }

    public void setPosition(PVector newPosition) {
        for (UIElement child : children) {
            if (child == null) continue;

            child.setPosition(PVector.add(child.getPosition(), PVector.sub(newPosition, position)));
        }

        position = newPosition;
    }

    public PVector getSize() {
        return size;
    }

    public void setSize(PVector newSize) {
        size = newSize;
    }

    public boolean getActive() {
        return active;
    }

    public void show() {
        for (UIElement child : children) {
            if (child == null) continue;

            child.show();
        }

        active = true;
    }

    public void hide() {
        for (UIElement child : children) {
            if (child == null) continue;

            child.hide();
        }

        active = false;
    }

    public void appendChild(UIElement child) {
        children.add(child);
        child.setParent(this);
    }

    public void removeChild(UIElement child) {
        children.remove(child);
        child.removeParent();
    }

    public void setParent(UIElement parent) {
        if (parent == null) return;

        this.parent = parent;
        setPosition(PVector.add(position, parent.getPosition()));
    }

    public void removeParent() {
        if (parent == null) return;

        setPosition(PVector.sub(position, parent.getPosition()));
    }
}
/*
Interestingly because of the drawing buffer,
the order in which these methods are called determine
what 'layer' UI are drawn on.
*/
class UIFactory {
    public RectangleUI createRect(float x, float y, float w, float h, int colour) {
        RectangleUI element = new RectangleUI(x, y, w, h, colour);
        uiManager.addElement(element);
        return element;
    }

    public TextUI createText(float x, float y, float w, float h, int colour, String text) {
        TextUI element = new TextUI(x, y, w, h, colour, text);
        uiManager.addElement(element);
        return element;
    }

    public ButtonUI createButton(float x, float y, float w, float h, int colour, Runnable function) {
        ButtonUI element = new ButtonUI(x, y, w, h, colour, function);
        uiManager.addElement(element);
        return element;
    }
}
class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;

    public void draw() {
        if (contextMenu == null) contextMenu = new ContextMenu(0, 0, 180, 200, color(230));

        for (UIElement element : screenElements) {
            if (element.getActive()) element.display();
        }
    }

    public void leftClick() {
        contextMenu.hide();
    }

    public void rightClick() {
        contextMenu.show();
    }

    public void addElement(UIElement element) {
        screenElements.add(element);

        if (element instanceof ButtonUI) {
            buttons.add((ButtonUI) element);
        }
    }

    public void removeElement(UIElement element) {
        screenElements.remove(element);

        if (element instanceof ButtonUI) {
            buttons.remove((ButtonUI) element);
        }
    }

    public void checkHoverForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse))
                button.hover();
            else
                button.unhover();
        }
    }

    public void checkClickForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse)) button.click();
        }
    }

    // public void addButton(ButtonUI button) {
    //     buttons.add(button);
    // }

    // public void removeButton(ButtonUI button) {
    //     buttons.remove(button);
    // }
}
    public void settings() {  size(1280, 720, P3D); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Nanobuilder" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
