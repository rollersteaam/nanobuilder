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
import java.util.Timer; 
import java.util.TimerTask; 
import java.util.Collections; 

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
WorldManager worldManager;
SelectionManager selectionManager;
UIManager uiManager;
UIFactory uiFactory;

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
    cam.speed = 30;              // default is 3
    cam.sensitivity = 0;      // default is 2
    cam.controllable = true;
    cam.position = new PVector(-width, height/2, 0);

    float fov = PI/3.0f;
    float cameraZ = (height/2.0f) / tan(fov/2.0f);
    perspective(fov, PApplet.parseFloat(width)/PApplet.parseFloat(height), cameraZ/10.0f / 300, cameraZ*10.0f * 300);
    
    worldManager = new WorldManager();
    selectionManager = new SelectionManager();
    uiManager = new UIManager();
    uiFactory = new UIFactory();
    
    // for (int i = 0; i < 5; i++) {
    //     int randNo = (int) random(1, 20);
    //     new Atom(randNo);
    //     // new Atom(0, 500, 0, 300);
    // }

    // for (int i = 0; i < 15; i++) {
    //     new Atom();
    // }

    // Atom atom1 = new Atom(100, 200, -700, 5);
    // Atom atom2 = new Atom(100, -2000, -700, 5);
    // AtomBond testBond = new AtomBond(atom1, atom2);

    Atom testAtom = new Atom(10);
    // testAtom.addNeutron();

    for (int i = 0; i < 200; i++) {
        testAtom.addNeutron();
    }

    // new Atom(1000);

    // new Electron(150, 150, 150, new Proton(0, 0, 0));
    // for (int i = 0; i < 50; i++) {
        // new Electron(600 * i + 20, 600 * i + 20, 600 * i + 20, new Proton(600 * i, 600 * i, 600 * i));
    // }
    // Atom matt = new Atom(0, 400, 0, 250);

    // Proton contentOne = new Proton(x, y, z);
    // new Electron(x + contentOne.r + 10, y + contentOne.r + 10, z + contentOne.r + 10, contentOne);
}

public void draw() {
    // Undoes the use of DISABLE_DEPTH_TEST so 3D objects act naturally after it was called.
    hint(ENABLE_DEPTH_TEST);

    // background(70);
    background(135, 135, 255);
    lights();
    noStroke();

    worldManager.update();

    // float biggestDistance = 0;

    // for (int i = 0; i < particleList.size(); i++) {
    //     Particle particle = particleList.get(i);
    //     particle.evaluatePhysics();
    //     particle.display();

    //     float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

    //     if ((dist > biggestDistance) || (biggestDistance == 0)) {
    //         biggestDistance = dist;
    //     }
    // }

    // for (Particle particle : particleList) {
    // }

    // drawOriginArrows();
    // drawOriginGrid();

//     pushStyle();
//     // stroke(color(70, 70, 255));
// // strokeWeight(8);
//     // fill(255, 0, 0, map(biggestDistance, 900, 1000, 0, 25));
//     // box(2000);
//     fill(255, 0, 0, map(biggestDistance, 9000, 10000, 0, 25));
//     box(20000);
//     popStyle();

    // pushMatrix();
    // drawCylinder(8, 100, 500);
    // popMatrix();

    // pushMatrix();
    // rotateY(PI/2);
    // rotateX(PI/4);
    // drawCylinder(8, 100, 500);
    // popMatrix();

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
    if (mouseButton == LEFT) {
        if (cam.fireAtom()) return;
        if (uiManager.checkForFocus()) return;
        if (selectionManager.mousePressed()) return;
    }
}

public void mouseReleased() {
    if (uiManager.checkClickForButtons()) return;

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
class Atom extends Particle {
    Proton core;
    ArrayList<Particle> nucleus = new ArrayList<Particle>();
    float nucleusRadius = 0;

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();
    float orbitOffset = 0;

    Atom(float x, float y, float z, int electrons) {
        super(x, y, z, 200);
        
        core = new Proton(x, y, z, this);
        nucleus.add(core);

        worldManager.atomList.add(this);

        // An atom always has one shell, or it's not an atom and should throw an exception before this anyway.
        shells.add(new ElectronShell(this, 2, 1));

        for (int remainingElectrons = electrons; remainingElectrons > 0; remainingElectrons--) {
            addElectron();
        }

        recalculateRadius();
        recalculateMass();
    }
    
    Atom(float x, float y, float z) {
        this(
            x,
            y,
            z,
            (int) random(1, 20)
        );
    }
    
    Atom(int electrons) {
        this(
            random(-2000, 2000),
            random(-2000, 2000),
            random(-2000, 2000),
            electrons
        );
    }

    Atom() {
        this(round(random(1, 50)));
    }

    public void recalculateMass() {
        mass = 0;

        for (Particle particle : nucleus) {
            mass += particle.mass;
        }

        /*
        Here I don't just get the size and multiply by const because we want to maximize
        the user's freedom (so they can do weird things like change the mass of an electron)
        */
        for (ElectronShell shell : shells) {
            mass += shell.getMass();
        }

        if (mass == 0)
            throw new IllegalStateException("Illegal termination of Atom constituents/handling of Atom state. Found during mass recalculation.");
    }

    public void addNeutron() {
        nucleus.add(new Neutron(500, 500, 500, this));
        redistributeNucleus();
    }

    public void addProton() {
        nucleus.add(new Proton(500, 500, 500, this));
        redistributeNucleus();
    }

    /*
    Using the equation for a sphere, I make a pass every 156 units in the Z axis to determine the magnitude limit
    for the circular projection of the nucleus' contents. As the list is run in normal order, the core proton should
    always be the first one projected.
    */
    public void redistributeNucleus() {
        int numberOfNucleons = nucleus.size();
        // println("____");
        // println("Number in nucleus: " + numberOfNucleons);
        // /*
        // (2 * nucleon radius)^3 results in a volume for a cube occupying the same space. <-- subject to change
        // sphereRadius = cubed root of [3*number of nucleons*(2 * nucleon radius)^3 / 4 * PI]
        // */
        // float minNucleusRadius = pow( (3*numberOfNucleons*pow(156, 3)) / (4*PI) , 1f/3f);
        // minNucleusRadius += minNucleusRadius * ( floor(minNucleusRadius / 78) - minNucleusRadius / 78 );
        
        // // if (guide != null) guide.delete();
        // // guide = new Particle(pos.x, pos.y, pos.z, minNucleusRadius);
        // // guide.setColour(color(255, 80));
            
        // // float z = -minNucleusRadius;
        // println("Minimum radius of nucleus: " + minNucleusRadius);

        // orbitOffset = minNucleusRadius;

        // println("I would judge... " + minNucleusRadius * 2 / 156 + " can fit.");

        // Set first nucleon (the core proton) as the center particle for model's sake.
        // nucleus.get(0).pos = pos;
        // Therefore start further in advance.

        numberOfNucleons -= 1;
        int zPRadius = 156;

        for (int currentNucleonIndex = 1; numberOfNucleons > 0; zPRadius += 156) {    
            float pRadius = 0;
            for (int z = zPRadius; z >= -zPRadius; z -= 156) {
                // float pRadius = sqrt( pow(zPRadius, 2) - pow(z, 2) );

                float pFillable = ceil((2 * PI * pRadius) / 156);
                // float pAngleSep = 156 / (pFillable * pRadius);
                // float pAngleSep = (2 * PI) / pFillable;
                float pAngleSep = (pFillable == 0) ? 0 : (2 * PI) / pFillable;
                pFillable = (pFillable == 0) ? 1 : pFillable;

                for (int i = 0; (i < pFillable && numberOfNucleons > 0); i++, currentNucleonIndex++, numberOfNucleons--) {
                    Particle nucleon = nucleus.get(currentNucleonIndex);
                    float angle = pAngleSep * i;

                    // println("=== ANGLE ===");
                    // println(degrees(angle));
                    // println("===");

                    nucleon.pos = PVector.add(pos,
                        new PVector(
                            sin(angle) * pRadius,
                            cos(angle) * pRadius,
                            z
                        )
                    );
                }

                if (z == 0) nucleusRadius = pRadius;
                pRadius += (z > 0) ? 156 : -156;
            }
        }

        //     for (int projectionLevel = 0; projectionLevel * 156 <= projectionLim; projectionLevel++) {
        //         float radius = projectionLevel * 156;
        //         float numberFillable = (2 * PI * radius) / 156;
        //         float angularSeperation = (projectionLevel == 0 || i == 0) ? 0 : 156 / (projectionLevel * i);

        //         for (int i = 0; i < totalElectrons; i++) {
        //             Electron electron = contents.get(i);

        //             float angle = angularSeperation * i;

        //             if (shellNumber % 2 == 1)
        //                 electron.pos = PVector.add(pos, new PVector(sin(angle), cos(angle), 0).setMag(containingAtom.orbitOffset + 200 * shellNumber) );
        //             else
        //                 electron.pos = PVector.add(pos, new PVector(sin(angle), 0, cos(angle)).setMag(containingAtom.orbitOffset + 200 * shellNumber) );
                        
        //             electron.setInitialCircularVelocityFromForce(core, core.calculateCoulombsLawForceOn(electron));
        //         }
        //     }
        // // }

        // int i = 1;
        // // z += 78 + 39 / 2;
        // nucleusNum--;
        // while (z < minNucleusRadius) {
        //     // squared root of [sphere radius squared - the difference in X/Z sphere traversal squared] is equal to dY.
        //     // This difference in Y becomes the limit that our projection method uses for all given passes.
        //     println();
        //     println("At diff " + (z - minNucleusRadius) + " away from the edge...");
        //     float planeLimit = sqrt( pow(minNucleusRadius, 2) - pow(z, 2) );
        //     println("I would judge... " + (minNucleusRadius * 2) / 156 + " would fit for this pass.");
        //     println("I would judge... " + (planeLimit * 2) / 156 + " would fit for this pass.");
        //     println();
        //     println("2D plane limit: " + planeLimit);

        //     int projectionLevel = 0;
        //     int projectionLevelLimit = 1;
        //     int projectionLevelCounter = 0;
        //     float projectionLevelMagnitude = 0;
        //     float projectionLevelAngSep = 0;

        //     // for (nucleusNum > 0; nucleusNum--) {
        //     while (nucleusNum > 0) {
        //         Particle nucleon = nucleus.get(i);
                
        //         nucleon.pos = PVector.add(pos, new PVector(
        //                 sin(projectionLevelAngSep * projectionLevelCounter) * projectionLevelMagnitude,
        //                 cos(projectionLevelAngSep * projectionLevelCounter) * projectionLevelMagnitude,
        //                 z
        //             )
        //         );

        //         projectionLevelCounter++;
        //         nucleusNum--;
        //         i++;

        //         if (projectionLevelCounter == projectionLevelLimit) {
        //             projectionLevel++;
        //             projectionLevelMagnitude = projectionLevel * 156;

        //             if (projectionLevelMagnitude > planeLimit) {
        //                 println(projectionLevelMagnitude);
        //                 println(planeLimit);
        //                 break;
        //             }

        //             projectionLevelLimit = ceil((2*PI*projectionLevelMagnitude)/156);
        //             projectionLevelAngSep = 2*PI/projectionLevelLimit;
        //             projectionLevelCounter = 0;
        //         }
        //     }

        //     z += 156;
        // }
        redistributeElectronShells();
        recalculateRadius();
        recalculateMass();
    }

    public void recalculateRadius() {
        shape.scale(1 / (r / 200));
        r = shells.size() * 200 + nucleusRadius + orbitOffset;
        shape.scale(r / 200);
    }
    
    @Override
    public boolean select() {
        if (!shouldParticlesDraw) return true;
        
        return false;
    }

    public @Override
    void display() {
        if (shape == null) return;

        calculateShouldParticlesDraw();

        // if (shouldParticlesDraw) return;
        // if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        int formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // 255
            // lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / (r + 4000))
            // lerp(0, 255, (PVector.dist(cam.position, pos) / ((r*2) + 100)) )
            lerp(0, 255, (PVector.dist(cam.position, pos) - 2000) / 750 )
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }

    public void addElectron() {
        if (shells.size() == 0)
            throw new IllegalStateException("An atom has no electron shells.");

        int numberOfShells = shells.size();
        ElectronShell lastShell = shells.get(numberOfShells - 1);

        Electron newElectron = lastShell.addElectron();

        if (newElectron == null) {
            ElectronShell newShell = new ElectronShell(this, (int) (2 * pow(numberOfShells + 1, 2)), numberOfShells + 1);
            shells.add(newShell);
            newShell.addElectron();
            recalculateRadius();
            recalculateMass();
        } else {
            children.add(newElectron);
        }
    }

    public void removeElectron() {
        if (shells.size() == 0)
            println("Warning: Tried to remove an electron when there are no electron shells.");
            // throw new IllegalStateException("An atom has no electron shells.");
            
        ElectronShell lastShell = shells.get(shells.size() - 1);
        lastShell.removeElectron();

        if (lastShell.getSize() == 0) {
            shells.remove(shells.size() - 1);
            recalculateRadius();
            recalculateMass();
        }
    }

    public void redistributeElectronShells() {
        for (ElectronShell shell : shells) {
            shell.redistribute();
        }
    }

    private boolean shouldParticlesDraw = false;

    /*
    This approach is used because it a) unifies the conditions all into one
    function allowing easy changes later if necessary, and b) limits the need
    to call PVector.dist 1,000 times just because every particle of an Atom wants
    to know
    */
    private void calculateShouldParticlesDraw() {
        if ((PVector.dist(cam.position, pos) - 2000) / 750 > 1) {
            shouldParticlesDraw = false;
        } else {
            shouldParticlesDraw = true;
        }
    }

    // And of course, we don't want write access to this field and so it does not win, good day sir.
    public boolean shouldParticlesDraw() {
        return shouldParticlesDraw;
    }
}
class AtomBond {
    Atom first;
    Atom second;

    PVector position = new PVector();
    PVector rotation = new PVector();

    PShape shape, top, bottom, body;

    private final static float RADIUS = 32;
    private final static float SIDES = 8;

    float height;

    AtomBond(Atom first, Atom second) {
        this.first = first;
        this.second = second;

        pushStyle();

        fill(255, 200, 0);
        stroke(0, 0);

        shape = createShape(GROUP);
        
        float angle = 360 / SIDES;
        height = PVector.dist(first.pos, second.pos);
        float halfHeight = height/2;

        top = createShape();
        top.beginShape();
        for (int i = 0; i < SIDES; i++) {
            float x = cos(radians(i * angle)) * RADIUS;
            float y = sin(radians(i * angle)) * RADIUS;
            top.vertex(x, y, halfHeight);
        }
        top.endShape(CLOSE);

        bottom = createShape();
        bottom.beginShape();
        for (int i = 0; i < SIDES; i++) {
            float x = cos(radians(i * angle)) * RADIUS;
            float y = sin(radians(i * angle)) * RADIUS;
            bottom.vertex(x, y, -halfHeight);
        }
        bottom.endShape(CLOSE);

        body = createShape();
        body.beginShape(TRIANGLE_STRIP);
        for (int i = 0; i < SIDES + 1; i++) {
            float x = cos(radians(i * angle)) * RADIUS;
            float y = sin(radians(i * angle)) * RADIUS;
            body.vertex(x, y, halfHeight);
            body.vertex(x, y, -halfHeight);
        }
        body.endShape(CLOSE);

        shape.addChild(top);
        shape.addChild(bottom);
        shape.addChild(body);

        popStyle();

        worldManager.registerBond(this);
    }

    // Updates the shape's proportions to its two parents.
    private void updateShape(float distance) {
        height = distance;
        float halfHeight = height/2;

        for (int i = 0; i < SIDES; i++) {
            PVector v = top.getVertex(i);
            top.setVertex(i, v.x, v.y, halfHeight);
        }

        for (int i = 0; i < SIDES; i++) {
            PVector v = bottom.getVertex(i);
            bottom.setVertex(i, v.x, v.y, -halfHeight);
        }

        for (int i = 0; i < (SIDES + 1) * 2; i++) {
            PVector v = body.getVertex(i);
            body.setVertex(i, v.x, v.y, halfHeight);
            body.setVertex(i + 1, v.x, v.y, -halfHeight);
            // Iterate twice to skip to the next pair.
            i++;
        }
    }

    public void display() {
        pushMatrix();
        pushStyle();

        PVector dPos = PVector.sub(second.pos, first.pos);
        float distance = dPos.mag();
        position = PVector.add(first.pos, dPos.copy().div(2));

        rotation.y = asin(dPos.y/distance);
        rotation.x = atan2(dPos.z, dPos.x);

        updateShape(distance);

        translate(position.x, position.y, position.z);
        rotateY(-rotation.x - radians(90));
        rotateX(rotation.y);

        shape(shape);

        popStyle();
        popMatrix();
    }

    public void delete() {

    }
}
class ButtonUI extends UIElement {
    Runnable function;
    
    ButtonUI(float x, float y, float w, float h, int colour, Runnable function) {
        super(x, y, w, h, colour);
        this.function = function;
    }

    ButtonUI(float x, float y, float w, float h, int colour, Runnable function, int strokeColour, float strokeWeight) {
        super(x, y, w, h, colour, strokeColour, strokeWeight);
        this.function = function;
    }

    public @Override
    void display() {
        super.display();

        // pushStyle();
        // stroke(colour);
        // stroke(160, 160, 255, 230);
        // strokeWeight(2);
        rect(position.x, position.y, size.x, size.y);
        // popStyle();

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

    public boolean fireAtom() {
        if (piloting) return false;

        Atom newAtom = worldManager.createAtom();
        newAtom.applyForce(cam.position, newAtom.mass);
        return true;
    }
}
class ContextMenu extends UIElement {
    RectangleUI mainPanel;

    Runnable createAtom = new Runnable() {
        public void run() {
            selectionManager.cancel();
            selectionManager.select(worldManager.createAtom());
            hide();
        }
    };

    Runnable createElectron = new Runnable() {
        public void run() {
            selectionManager.cancel();
            selectionManager.select(worldManager.createElectron());
            hide();
        }
    };

    Runnable delete = new Runnable() {
        public void run() {
            selectionManager.delete();
            hide();
        }
    };

    Runnable paint = new Runnable() {
        public void run() {
            selectionManager.paint();
            hide();
        }
    };

    Runnable push = new Runnable() {
        public void run() {
            selectionManager.push();
            hide();
        }
    };

    Runnable insertAtomElectron = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;
            
            ((Atom) object).addElectron();
            hide();
        }
    };

    Runnable removeAtomElectron = new Runnable() {
        public void run() {
            Particle object = selectionManager.getObjectFromSelection();
            if (!(object instanceof Atom)) return;

            ((Atom) object).removeElectron();
            hide();
        }
    };

    Runnable bondAtoms = new Runnable() {
        public void run() {
            ArrayList<Particle> list = selectionManager.getObjectsFromSelection();
            if (list == null) return;

            Atom lastAtom = null;
            for (Particle particle : list) {
                if (!(particle instanceof Atom)) continue;

                if (lastAtom != null) {
                    new AtomBond(lastAtom, (Atom) particle);
                }

                lastAtom = (Atom) particle;
            }

            hide();
        }
    };

    ContextMenu(float x, float y, float w, float h, int colour) {
        super(x, y, w, h, colour);

        UIElement background = uiFactory.createRect(-3, -3, w + 4 + 3, h + 4 + 3, color(135));
        appendChild(background);

        mainPanel = uiFactory.createRect(1, 1, w, h, colour);
        appendChild(mainPanel);

        UIElement createAtomButton = uiFactory.createButton(5, 5, w - 8, 40, color(255, 0, 0), createAtom);
        UIElement createAtomText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Create Atom");
        createAtomButton.appendChild(createAtomText);
        appendChild(createAtomButton);

        UIElement deleteSelectionButton = uiFactory.createButton(5, 5 + 40 + 4, w - 8, 40, color(255, 0, 0), delete);
        UIElement deleteSelectionText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Delete");
        deleteSelectionButton.appendChild(deleteSelectionText);
        appendChild(deleteSelectionButton);

        UIElement paintButton = uiFactory.createButton(5, 5 + 40 + 40 + 4 + 4, w - 8, 40, color(0, 255, 0), paint);
        UIElement paintText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Paint Red");
        paintButton.appendChild(paintText);
        appendChild(paintButton);

        UIElement createElectronButton = uiFactory.createButton(5, 5 + 40 + 40 + 40 + 4 + 4 + 4, w - 8, 40, color(0, 0, 255), createElectron);
        UIElement createElectronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Create Electron");
        createElectronButton.appendChild(createElectronText);
        appendChild(createElectronButton);

        UIElement pushButton = uiFactory.createButton(5, 173 + 4 + 4, w - 8, 40, color(0, 0, 255), push);
        UIElement pushText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Push");
        pushButton.appendChild(pushText);
        appendChild(pushButton);

        UIElement insertElectronButton = uiFactory.createButton(5, 226, w - 8, 40, color(0, 0, 255), insertAtomElectron);
        UIElement insertElectronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Insert Electron");
        insertElectronButton.appendChild(insertElectronText);
        appendChild(insertElectronButton);

        UIElement removeElectronButton = uiFactory.createButton(5, 271, w - 8, 40, color(0, 0, 255), removeAtomElectron);
        UIElement removeElectronText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Remove Electron");
        removeElectronButton.appendChild(removeElectronText);
        appendChild(removeElectronButton);

        UIElement bondAtomsButton = uiFactory.createButton(5, 316, w - 8, 40, color(0, 0, 255), bondAtoms);
        UIElement bondAtomsText = uiFactory.createText(16, 8, w - 12, 38, color(70), "Bond Atoms");
        bondAtomsButton.appendChild(bondAtomsText);
        appendChild(bondAtomsButton);
        
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
    // static final float MASS = 9.10938356 * pow(10, -31);
    public static final float MASS = 9.10938356e-31f;
    public static final float CHARGE = -1.60217662e-19f;

    // Will add 17 to all powers of 10 for now.
    Electron(float x, float y, float z, Proton proton) {
        // super(x, y, z, random(0.84, 0.87) * 100 / 1000);
        // super(x, y, z, random(0.84, 0.87) * 100 / 3);
        super(x, y, z, 87 / 3);

        charge = CHARGE;
        mass = MASS;

        baseColor = color(0, 0, 255);
        revertToBaseColor();

        // If no initial proton then spawn with random passive velocity.
        if (proton == null) {
            velocity = PVector.random3D().setMag(2);
            return;
        }

        parent = proton.parent;

        setInitialCircularVelocityFromForce(proton, proton.calculateCoulombsLawForceOn(this));
    }

    Electron() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            null
        );
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
        // if (PVector.dist(cam.position, pos) > (r + 1000)) {
        //     for (Point point : trail) {
        //         trail.remove(point);
        //     }
        //     return;
        // }

        if (shape == null) return;

        /*
        Scales trail size based off of distance from it's 'parent' (what it's orbiting)

        It should be noted that this CAN be expensive, but by limiting the draw distance for
        seeing particles, it isn't necessarily a problem.
        */
        // Handles null pointer in case electron loses parent or has none.
        float dist;
        if (parent != null) {
            dist = min(PVector.sub(pos, parent.pos).mag(), 1000);
            
            if (!parent.shouldParticlesDraw()) {
                trail.clear();
                return;
            }
        } else {
            dist = 1000;
        }

        // float trailSize = 60 + (60 * ( (500/dist) - 1 ));
        float trailSize = 60 + (2 * ( (5000/dist) - 1 ));

        Point lastPoint = null;
        int counter = 0;
        for (Point element : trail) {
            counter++;
            pushMatrix();
            pushStyle();
                fill(0);
                // stroke(0, map(counter, 0, (trailSize - 1), 255, 0));
                stroke(
                    lerpColor(color(187, 0, 255), color(0, 187, 255), (counter * 1.5f)/trail.size()),
                    map(counter, 0, (trailSize - 1), 255, 0)
                    // 255
                );
                strokeWeight(4);

                if (lastPoint != null)
                    line(lastPoint.x, lastPoint.y, lastPoint.z, element.x, element.y, element.z);

                lastPoint = element;
            popMatrix();
            popStyle();
        }

        if (trail.size() > trailSize)
            trail.removeLast();

        if (shape == null) return;

        int formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // lerp(255, 0, PVector.dist(cam.position, pos) / ((r + 1000) * 2))
            255
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();

        // pushMatrix();
        // pushStyle();
        //     fill(0);
        //     stroke(0);
        //     strokeWeight(4);
        //     line(pos.x, pos.y, pos.z, pos.x + velocity.x, pos.y + velocity.y, pos.z + velocity.z);
        // popMatrix();
        // popStyle();

        Point point = new Point();
        trail.push(point);
    }
}
class ElectronShell {
    private Atom containingAtom;
    private ArrayList<Electron> contents = new ArrayList<Electron>();
    private int max;
    private int shellNumber;

    ElectronShell(Atom containingAtom, int max, int shellNumber) {
        this.containingAtom = containingAtom;
        this.max = max;
        this.shellNumber = shellNumber;            
    }

    public int getSize() {
        return contents.size();
    }

    public float getMass() {
        float mass = 0;

        for (Electron electron : contents) {
            mass += electron.mass;
        }

        return mass;
    }

    public Electron addElectron() {
        // This will probably only occur when a new shell needs creating, but SRP means it's implemented here.
        if (contents.size() == max) return null;

        // Initial position is not important, it will be changed immediately.
        Electron newElectron = new Electron(0, 0, 0, containingAtom.core);
        contents.add(newElectron);
        redistribute();

        return newElectron;
    }

    public boolean removeElectron() {
        if (contents.size() == 0) return false;
        
        // Remove the last appended electron in the shell.
        int index = contents.size() - 1;
        Electron target = contents.get(index);
        target.delete();
        contents.remove(index);
        
        return true;
    }

    public void redistribute() {
        int totalElectrons = contents.size();
        float angularSeperation = (2 * PI) / totalElectrons;

        for (int i = 0; i < totalElectrons; i++) {
            Electron electron = contents.get(i);

            float angle = angularSeperation * i;

            if (shellNumber % 2 == 1)
                electron.pos = PVector.add(containingAtom.pos, new PVector(sin(angle), cos(angle), 0).setMag(containingAtom.orbitOffset + containingAtom.nucleusRadius + 200 * shellNumber) );
            else
                electron.pos = PVector.add(containingAtom.pos, new PVector(sin(angle), 0, cos(angle)).setMag(containingAtom.orbitOffset + containingAtom.nucleusRadius + 200 * shellNumber) );
                
            electron.setInitialCircularVelocityFromForce(containingAtom.core, containingAtom.core.calculateCoulombsLawForceOn(electron));
        }
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
    Neutron(float x, float y, float z, Atom parent) {
        // super(x, y, z, random(0.84, 0.87) * 100);
        super(x, y, z, 87);
        charge = 0;
        mass = 1.6726219f * pow(10, -10);

        this.parent = parent;
        parent.addChild(this);

        baseColor = color(255);
        revertToBaseColor();
    }

    public @Override
    void display() {
        if (shape == null) return;

        if (parent != null) {
            if (!parent.shouldParticlesDraw()) {
                return;
            }
        }

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
    float mass = 1;

    int baseColor;
    int currentColor;

    PShape shape;

    Atom parent;
    ArrayList<Particle> children = new ArrayList<Particle>();

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
        // worldManager.particleList.add(this);
        worldManager.registerParticle(this);
    }

    Particle() {
        this(
            random(-500, 500),
            random(-500, 500),
            random(-500, 500),
            round(random(25, 100))
        );
    }

    public void addChild(Particle child) {
        children.add(child);
    }

    public void removeChild(Particle child) {
        children.remove(child);
    }

    public void delete() {
        shape = null;
        worldManager.unregisterParticle(this);

        // TODO: Change this direct access to method based access.
        if (parent != null) {
            parent.children.remove(this);
            parent = null;
        }

        for (Particle child : children) {
            child.parent = null;
        }

        children.clear();
    }

    public boolean select() {
        if (parent == null) return true;
        return parent.shouldParticlesDraw();
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

    public void addPosition(PVector addingPos) {
        pos.x += addingPos.x;
        pos.y += addingPos.y;
        pos.z += addingPos.z;

        for (Particle child : children) {
            child.addPosition(addingPos);
        }
    }

    public void setPosition(PVector newPos) {
        PVector difference = PVector.sub(pos, newPos);
        // Accessing individual fields is fastest and safest option.
        pos.x = newPos.x;
        pos.y = newPos.y;
        pos.z = newPos.z;

        for (Particle child : children) {
            child.addPosition(difference);
        }
    }

    public void applyForce(PVector direction, float force) {
        PVector vector = PVector.sub(pos, direction);
        vector.normalize();
        vector.setMag(force * 100 / mass);
        acceleration.add(vector);
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
        vector.normalize();
        vector.setMag((force * 100) / particle.mass);
        particle.acceleration.add(vector);
    }

    public void evaluateElectricalField() {
        for (Particle particle : worldManager.particleList) {
            if (particle == this) continue;
            if (particle.parent != parent) continue;
            applyForce(particle, calculateCoulombsLawForceOn(particle));
        }
    }

    public void evaluatePhysics() {
        if ((pos.x + r) >= 10000 || (pos.x - r) <= -10000) {
            addPosition(new PVector(-(velocity.x), 0, 0));
            velocity.x *= -1;
            velocity.x /= 4;            
            // delete();
        }

        if ((pos.y + r) >= 10000 || (pos.y - r) <= -10000) {
            addPosition(new PVector(0, -(velocity.y), 0));
            velocity.y *= -1;
            velocity.y /= 4;            
            // delete();
        }

        if ((pos.z + r) >= 10000 || (pos.z - r) <= -10000) {
            addPosition(new PVector(0, 0, -(velocity.z)));
            velocity.z *= -1;
            velocity.z /= 4;            
            // delete();
        }

        /*
        Rough collision stuff goes here
        */
        // If distance from another atom is less than radius then intersection
        for (Particle particle : worldManager.particleList) {
            // Spherical intersection
            // Determine the highest radius
            // float comparedRadius = (r > particle.r) ? r : particle.r;
            if (particle == this)
                continue;
            // Atoms are "abstract" but simplified collisions should still allow
            // atom and particle collisions, e.g. if the target particle doesn't belong to an atom.
            if (particle.parent != null || parent != null)
                continue;

            // if (PVector.dist(pos, particle.pos) <= r * 2) {
            //     collide(particle);
            // }
            if (PVector.dist(pos, particle.pos) <= (r + particle.r)) {
                collide(particle);
            }
        }

        velocity.add(acceleration);
        // pos.add(velocity);
        addPosition(velocity);
        /*
        Acceleration once 'dealt' is never kept, since it converts into velocity.
        This line resets acceleration so we're ready to regather all forces next frame.
        */
        acceleration = new PVector();
    }

    public void collide(Particle particle) {
        // To make a more accurate incident vector, we could also set mag the magnitude to the radius of either atom (probably this one).
        PVector incidentVector = PVector.sub(pos, particle.pos);
        // Impulse = change in momentum
        // p = m1v1 - m2v2
        float impulse = mass * (velocity.mag()) - particle.mass * (particle.velocity.mag());
        println(impulse);
        // Initial kinetic energy
        // E = 1/2*m1*v1^2 + 1/2*m2*v2^2
        float energy = 1/2 * mass * pow((velocity.mag()), 2) + 1/2 * particle.mass * pow((particle.velocity.mag()), 2);
        println(energy);
        println();
        // This new velocity magnitude should change depending on who calls collide.
        // After -2 * impulse plus or minus can be used. It's a quadratic equation.
        float newVelocityMagnitude = -2 * impulse + sqrt( pow(2 * impulse, 2) - 4 * ( pow(impulse, 2) - 2 * energy * mass ) );
        // So we must halve it after we're done.
        newVelocityMagnitude /= 2;
        newVelocityMagnitude *= 1e25f;

        incidentVector.setMag(newVelocityMagnitude);
        /*
            New added velocity needs to be opposite the direction of incidence...

            Note that this doesn't logically follow, this is because the directions of the particle velocitys'
            are not factored in during the above calculations. There may be a requirement to evaluate this later.

            For now, believable collision is observed with this config.
        */
        if (newVelocityMagnitude > 0) incidentVector.mult(-1);
        // particle.velocity = incidentVector;
        particle.velocity.add(incidentVector);
        // And now attempt to cancel any attempts to process the collision a second time.
    }

    public void display() {
        // Added radius so pop-in limits are more forgiving and less obvious.
        float screenX = screenX(pos.x - r, pos.y - r, pos.z);
        float screenY = screenY(pos.x - r, pos.y - r, pos.z);   
        float screenX2 = screenX(pos.x + r, pos.y + r, pos.z);
        float screenY2 = screenY(pos.x + r, pos.y + r, pos.z);
  
        // Disregard objects outside of camera view, saving GPU cycles and improving performance.
        // If top left and bottom right of object are outside of dimensions, then do not render.
        // If top left and bottom right are less than 0
        // If top and left and bottom right are greater than width/height
        if (
            (screenX2 < 0 && screenY2 < 0)
            ||
            (screenX > width && screenY > height)
        )
        return;
        // if (
        //     (screenX > width) ||
        //     (screenY > height) ||
        //     (screenX < 0) ||
        //     (screenY < 0)
        // ) 
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

        where r = vector.mag()
        */
        float topExpression = targetParticle.charge * charge;
        float bottomExpression = 4 * PI * 8.85f * pow(10, -12) * pow(vector.mag(), 2);
        /*
        If the force is infinite (which should be impossible)
        then disregard current tick. We aren't trying to emulate annihilation.
        */
        if (bottomExpression == 0) return 0;
        return topExpression / bottomExpression;
    }

    // Enumerations
    // Defined static there is only one copy stored in memory.
    private static final int X_DOMINANT = 0;
    private static final int Y_DOMINANT = 1;
    private static final int Z_DOMINANT = 2;

    public void setInitialCircularVelocityFromForce(Particle particle, float force) {
        PVector diff = PVector.sub(pos, particle.pos);
        PVector diffMag = new PVector(
            abs(diff.x),
            abs(diff.y),
            abs(diff.z)
        );
        
        int magRecordCoordinate = X_DOMINANT;
        float magRecord = diffMag.x;

        if (diffMag.y <= magRecord) {
            magRecord = diffMag.y;
            magRecordCoordinate = Y_DOMINANT;
        }

        if (diffMag.z <= magRecord) {
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
                    force * 100 * PVector.dist(particle.pos, this.pos) / mass
                )
            )
        );
    }
}
class Proton extends Particle {
    public static final float MASS = 1.6726219e-27f;
    public static final float CHARGE = 1.60217662e-19f;

    /*
        Let's say 100 pixels = 1fm.
    
        Radius of a proton: 0.84 * 10^-15 to 0.87 * 10^-15
    */
    Proton(float x, float y, float z, Atom parent) {
        super(x, y, z, 87);
        charge = CHARGE;
        mass = MASS;

        this.parent = parent;
        parent.addChild(this);

        baseColor = color(255, 0, 0);
        revertToBaseColor();
    }

    Proton() {
        this(
            random(-1000, 1000),
            random(-1000, 1000),
            random(-1000, 1000),
            null
        );
    }

    public @Override
    void evaluatePhysics() {
        evaluateElectricalField();
        super.evaluatePhysics();
    }

    public @Override
    void display() {
        // if (PVector.dist(cam.position, pos) > (r + 1000))
        //     return;

        if (shape == null) return;

        if (parent != null) {
            if (!parent.shouldParticlesDraw()) {
                return;
            }
        }

        int formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            255
            // lerp(255, 0, PVector.dist(cam.position, pos) / ((r + 1000) * 2))
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }
}
class RectangleUI extends UIElement {
    RectangleUI(float x, float y, float w, float h, int colour) {
        super(x, y, w, h, colour);
    }

    RectangleUI(float x, float y, float w, float h, int colour, int strokeColour, float strokeWeight) {
        super(x, y, w, h, colour, strokeColour, strokeWeight);
    }

    public @Override
    void display() {
        super.display();

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

    public void push() {
        for (Selection selection : selectedParticles) {
            Particle object = selection.getParticle();
            object.applyForce(cam.position, object.mass);
        }
    }

    public Particle getObjectFromSelection() {
        int selSize = selectedParticles.size();
        if (selSize == 0) return null;

        if (selSize == 1)
            return selectedParticles.get(0).getParticle();
        else
            // Could improve this functionality with some basic distance checking
            return selectedParticles.get((int) random(0, selSize - 1)).getParticle();
    }

    public ArrayList<Particle> getObjectsFromSelection() {
        if (selectedParticles.size() == 0) return null;

        ArrayList<Particle> list = new ArrayList<Particle>();

        for (Selection selection : selectedParticles) {
            list.add(selection.getParticle());
        }

        return list;
    }

    public boolean select(Particle particle) {
        if (particle == null) {
            println("URGENT: SelectionManager was requested to select a null reference.");
            Thread.dumpStack();
            return false;
        }

        if (particle.select()) {
            selectedParticles.add(new Selection(particle));
            return true;
        }

        return false;
    }

    public void cancel() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().deselect();
        }

        selectedParticles.clear();
        hoveringDistanceMult = 1;
    }

    public void delete() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().delete();
        }

        cancel();
    }

    public void paint() {
        if (!hasActiveSelection()) return;

        for (Selection selection : selectedParticles) {
            selection.getParticle().setColour(color(255, 0, 0));
        }

        cancel();
    }

    PVector selectingStartPos;
    RectangleUI groupSelection;

    public void startSelecting() {
        cancel();
        selectingStartPos = new PVector(mouseX, mouseY);
        groupSelection = uiFactory.createRectOutlined(selectingStartPos.x, selectingStartPos.y, 1, 1, color(30, 30, 90, 80), color(10, 10, 40, 80), 4);
    }

    public boolean stopSelecting() {
        if (selectingStartPos == null) return false;

        PVector lowerBoundary = new PVector(selectingStartPos.x, selectingStartPos.y);
        PVector higherBoundary = new PVector(mouseX, mouseY);
        boolean particleFound = false;

        /*
        Iterate through all existing particles and compare their screen coordinates
        to the selected screen area for all 4 cases, selecting all particles that
        intersect with the area.
        */
        for (Particle particle : worldManager.particleList) {
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
                higherBoundary.y > screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }
            
            // From bottom left to top right
            if (lowerBoundary.x < screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x > screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // From bottom right to top left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y > screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y < screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // From top right to bottom left
            if (lowerBoundary.x > screenPosXNegativeLimit &&
                lowerBoundary.y < screenPosYNegativeLimit &&
                higherBoundary.x < screenPosXNegativeLimit &&
                higherBoundary.y > screenPosYNegativeLimit) {
                if (select(particle))
                    particleFound = true;
            }

            // TODO: Investigate if Z values are accounted for in group selection.
        }

        selectingStartPos = null;
        uiManager.removeElement(groupSelection);
        groupSelection = null;

        return particleFound;
    }

    public Particle checkPointAgainstParticleIntersection(PVector v1) {
        for (Particle particle : worldManager.particleList) {
            float screenPosX = screenX(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosXNegativeLimit = screenX(particle.pos.x - particle.r, particle.pos.y, particle.pos.z);
            float screenPosXPositiveLimit = screenX(particle.pos.x + particle.r, particle.pos.y, particle.pos.z);
            
            float screenPosY = screenY(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosYNegativeLimit = screenY(particle.pos.x, particle.pos.y - particle.r, particle.pos.z);
            float screenPosYPositiveLimit = screenY(particle.pos.x, particle.pos.y + particle.r, particle.pos.z);
            
            float screenPosZ = screenZ(particle.pos.x, particle.pos.y, particle.pos.z);
            float screenPosZNegativeLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z - particle.r);
            float screenPosZPositiveLimit = screenZ(particle.pos.x, particle.pos.y, particle.pos.z + particle.r);

            if (v1.x >= screenPosXNegativeLimit && v1.x <= screenPosXPositiveLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (v1.x >= screenPosXPositiveLimit && v1.x <= screenPosXNegativeLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            if (v1.x >= screenPosZNegativeLimit && v1.x <= screenPosZPositiveLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }

            /*
            Allows selection in 'opposite region' camera space, since the limits switch around.
            */
            if (v1.x >= screenPosZPositiveLimit && v1.x <= screenPosZNegativeLimit && v1.y >= screenPosYNegativeLimit && v1.y <= screenPosYPositiveLimit) {
                if (particle.select()) {
                    return particle;
                }
            }
        }

        return null;
    }

    public boolean mousePressed() {
        // Pass 1
        Particle attemptedSelection = checkPointAgainstParticleIntersection(new PVector(mouseX, mouseY));
        if (attemptedSelection != null) {
            cancel();
            select(attemptedSelection);
        } else {
            startSelecting();
        }

        // No interrupts passed, return and continue on the main calling routine.
        return false;
    }

    public boolean mouseReleased() {
        // Pass 1
        /*
        If a click selection was processed before, then we don't want to cancel the
        selection this frame, regardless of if a group selection had returned no particles.
        */
        stopSelecting();

        // If active selection, cancel, but only if mouseX is not over an existing particle.
        // if (!selectionWasAttempted) cancel();

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

            // particle.addPosition( PVector.add(cam.position, new PVector(
            //     // Fine tune mode
            //     (600 * hoveringDistanceMult) * forward.x,
            //     (600 * hoveringDistanceMult) * forward.y,
            //     (600 * hoveringDistanceMult) * forward.z )) );
                // (hoveringDistanceMult) * selection.getFromCameraVector().x,
                // (hoveringDistanceMult) * selection.getFromCameraVector().y,
                // (hoveringDistanceMult) * selection.getFromCameraVector().z )) );
            
            // The changes given by the mouse need to be added to the constant difference
            // fromCameraVector.add(new PVector(
                // (mouseX - pmouseX) * xDistMul * fromCameraVectorNormalized.x,
                // (mouseY - pmouseY) * yDistMul,
                // (mouseX - pmouseX) * xDistMul
                // ));

            // Selection Guide //
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    pushStyle();
                    
                    translate(particle.pos.x - particle.r, particle.pos.y, particle.pos.z - particle.r);
                    rotateX(PI/2);
                    stroke(0, 255, 255, 180);
                    noFill();
                    
                    rect((particle.r * 2 * x)/5, (particle.r * 2 * y)/5, (particle.r * 2)/5, (particle.r * 2)/5);
                    popStyle();
                    popMatrix();
                }
            }
            
            for (int y = 0; y < 5; y ++) {
                for (int x = 0; x < 5; x ++) {
                    pushMatrix();
                    pushStyle();
                    
                    translate(particle.pos.x, particle.pos.y - particle.r, particle.pos.z + particle.r);
                    rotateY(PI/2);
                    stroke(0, 255, 255, 180);
                    noFill();
                    
                    rect((particle.r * 2 * x)/5, (particle.r * 2 * y)/5, (particle.r * 2)/5, (particle.r * 2)/5);
                    popStyle();
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

    int strokeColour = color(0, 0);
    float strokeWeight = 0;

    UIElement(float x, float y, float w, float h, int colour) {
        position = new PVector(x, y);
        size = new PVector(w, h);
        this.colour = colour;
    }

    UIElement(float x, float y, float w, float h, int colour, int strokeColour, float strokeWeight) {
        this(x, y, w, h, colour);
        this.strokeColour = strokeColour;
        this.strokeWeight = strokeWeight;
    }

    public void display() {
        pushStyle();
        pushMatrix();
        noLights();

        strokeWeight(strokeWeight);
        stroke(strokeColour);
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
        if (!active) return false;
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
    
    public RectangleUI createRectOutlined(float x, float y, float w, float h, int colour, int strokeColour, float strokeWeight) {
        RectangleUI element = new RectangleUI(x, y, w, h, colour, strokeColour, strokeWeight);
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

    public ButtonUI createButtonOutlined(float x, float y, float w, float h, int colour, Runnable function, int strokeColour, int strokeWeight) {
        ButtonUI element = new ButtonUI(x, y, w, h, colour, function, strokeColour, strokeWeight);
        uiManager.addElement(element);
        return element;
    }
}
class UIManager {
    private ArrayList<UIElement> screenElements = new ArrayList<UIElement>();
    private ArrayList<ButtonUI> buttons = new ArrayList<ButtonUI>();

    private ContextMenu contextMenu;

    public void draw() {
        if (contextMenu == null) contextMenu = new ContextMenu(0, 0, 180, 224 + 90 + 50, color(230));

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

    public boolean checkClickForButtons() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (ButtonUI button : buttons) {
            if (button.checkIntersectionWithPoint(mouse)) {
                button.click();
                return true;
            }
        }
        
        // Pass an interruption.
        return false;
    }

    public boolean checkForFocus() {
        PVector mouse = new PVector(mouseX, mouseY);

        for (UIElement element : screenElements) {
            if (element.checkIntersectionWithPoint(mouse))
                return true;
        }

        return false;
    }
}
class WorldManager {
    ArrayList<Particle> particleList = new ArrayList<Particle>();
    ArrayList<AtomBond> bondList = new ArrayList<AtomBond>();
    ArrayList<Atom> atomList = new ArrayList<Atom>();

    public void registerParticle(Particle particle) {
        particleList.add(particle);
    }

    public void unregisterParticle(Particle particle) {
        particleList.remove(particle);
    }

    public void registerBond(AtomBond bond) {
        bondList.add(bond);
    }

    public void unregisterBond(AtomBond bond) {
        bondList.remove(bond);
    }

    public Atom createAtom(PVector position) {
        return new Atom(position.x, position.y, position.z, 1);
    }

    public Atom createAtom() {
        PVector fwd = cam.getForward();
        return new Atom(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, 1);
    }

    public Electron createElectron(PVector position) {
        return new Electron(position.x, position.y, position.z, null);
    }

    public Electron createElectron() {
        PVector fwd = cam.getForward();
        return new Electron(cam.position.x + 900 * fwd.x, cam.position.y + 900 * fwd.y, cam.position.z + 900 * fwd.z, null);
    }

    // public void delete(Particle particle) {
    //     particle.delete();
    // }

    // Delete from selection.
    // public void delete() {
    //     particle.delete();
    // }

    // public void paint(Particle particle, color colour) {
    //     particle.setColour(colour);
    // }

    // Colour selection.
    // public void paint(color colour)

    // public void push(Particle particle, PVector position) {
    //     particle.applyForce(position, particle.mass);
    // }

    // // Push from camera.
    // public void push(Particle particle) {
    //     particle.applyForce(cam.position, particle.mass);
    // }

    // Push selection from camera.
    // public void push()

    public void createLattice(Particle particle, PVector position, int radius) {
        for (int y = 0; y < 5; y++) {
            for (int z = 0; z < 5; z++) {
                for (int x = 0; x < 5; x++) {
                    new Particle(200 * x, 200 * y, 200 * z, 100); 
                }
            }
        }
    }

    public void createBoundingBox(PVector position, float radius) {

    }

    public void edit(Particle particle) {

    }

    public void moveByMouse(Particle particle) {
        
    }

    public void stopMoveByMouse(Particle particle) {

    }

    public void update() {
        drawOriginGrid();

        drawBonds();
        drawParticles();

        drawOriginArrows();
    }

    private void drawBonds() {
        for (int i = 0; i < bondList.size(); i++) {
            AtomBond bond = bondList.get(i);
            bond.display();
        }
    }

    private void drawParticles() {
        float biggestDistance = 0;

        for (int i = 0; i < particleList.size(); i++) {
            Particle particle = particleList.get(i);
            if (particle instanceof Atom) continue;
            particle.evaluatePhysics();
            particle.display();

            float dist = PVector.dist(particle.pos, new PVector(0, 0, 0));

            if ((dist > biggestDistance) || (biggestDistance == 0)) {
                biggestDistance = dist;
            }
        }

        for (int i = 0; i < atomList.size(); i++) {
            Atom atom = atomList.get(i);
            atom.evaluatePhysics();
            atom.display();
        }
    }

    private void drawOriginGrid() {
        pushStyle();
        fill(color(0, 0, 255));
        box(20, 20, 300);
        
        fill(color(0, 255, 0));
        box(20, 300, 20);

        fill(color(255, 0, 0));
        box(300, 20, 20);
        popStyle();
    }

    private void drawOriginArrows() {
        // Region boxes
        // pushStyle();
        // pushMatrix();

        // fill(255, 0, 0, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(PI/2);
        // fill(0, 0, 255, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(PI);
        // fill(255, 0, 0, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();
        // pushStyle();
        // pushMatrix();

        // rotateY(3*PI/2);
        // fill(0, 0, 255, 130);
        // rect(0, -5000, 10000, 10000);

        // popMatrix();
        // popStyle();

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

    // public static final int FIRST_QUADRANT = 1;
    // public static final int SECOND_QUADRANT = 2;
    // public static final int THIRD_QUADRANT = 3;
    // public static final int FOURTH_QUADRANT = 4;

    // public int getQuadrant(float radAng) {
    //     radAng = abs(radAng);
    //     if (radAng >= 0 && radAng < 90 || radAng == 360) {
    //         return FIRST_QUADRANT;
    //     } else if (radAng >= 90 && radAng < 180) {
    //         return SECOND_QUADRANT;
    //     } else if (radAng >= 180 && radAng < 270) {
    //         return THIRD_QUADRANT;
    //     } else if (radAng >= 270 && radAng < 360) {
    //         return FOURTH_QUADRANT;
    //     } else throw new IllegalArgumentException("Attempted to find quadrant with illegal angle argument.");
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
