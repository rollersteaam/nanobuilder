protected static class AtomHelper {
    protected static int calculateNumberOfShells(int electrons) {
        if (electrons == 0)
            throw new IllegalStateException("An atom can't have 0 electrons.");
        
        return ceil((electrons - 2) / 8) + 1;
    }
}

class Atom extends Particle {
    Proton core;
    ArrayList<Proton> listProtons = new ArrayList<Proton>();
    ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();
    float orbitDistance;

    Atom(float x, float y, float z, int electrons) {
        super(x, y, z, AtomHelper.calculateNumberOfShells(electrons) * 200);
        core = new Proton(x, y, z, this);
        listProtons.add(core);
        children.add(core);

        // An atom always has one shell, or it's not an atom.
        shells.add(new ElectronShell(2, 1, orbitDistance));
        
        for (int i = 0; i < (AtomHelper.calculateNumberOfShells(electrons) - 1); i++) {
            shells.add(new ElectronShell(8, i + 2, orbitDistance));
        }

        int remainingElectrons = electrons;
        // For every shell the atom has...
        for (int i = 0; i < shells.size(); i++) {
            // Begin to add all electrons needed to each shell.
            while (remainingElectrons > 0) {
                /*
                For every shell, add an electron, passing in i, the shell iterator.
                This shows the size of the list, and so the position if we + 1.

                Passing in the index + 1 just means the electron is projected at the
                correct distance based on the shell's 'radius'.
                */
                if (!shells.get(i).addElectron())
                    break;
                else
                    remainingElectrons--;
            }
        }
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
    
    @Override
    public boolean select() {
        if (!shouldParticlesDraw) return true;
        
        return false;
    }

    @Override
    void display() {
        if (shape == null) return;

        calculateShouldParticlesDraw();

        if (shouldParticlesDraw) return;
        // if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            // 255
            // lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / (r + 4000))
            lerp(0, 255, (PVector.dist(cam.position, pos) / ((r*2) + 100)) )
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();
    }

    private class ElectronShell {
        private ArrayList<Electron> contents = new ArrayList<Electron>();
        private int max;
        private int shellNumber;
        // Orbit distance is passed in from a property in atoms during shell construction
        private float orbitDistance;
        // TODO: Find a way to declare this statically?
        /*
        An array of standardised vectors that can be added onto
        the atom's 'core' position and used to project electrons in a circle
        around the atom.
        */
        private final PVector[] projectionVertices = new PVector[] {
            new PVector(-100, 100, 0),
            new PVector(0, 100, 0),
            new PVector(100, 100, 0),
            new PVector(100, 0, 0),
            new PVector(100, -100, 0),
            new PVector(0, -100, 0),
            new PVector(-100, -100, 0),
            new PVector(-100, 0, 0)
        };
        // private final PVector[] projectionVertices = new PVector[] {
        //     new PVector(-100, 100, 0).normalize(),
        //     new PVector(0, 100, 0).normalize(),
        //     new PVector(100, 100, 0).normalize(),
        //     new PVector(100, 0, 0).normalize(),
        //     new PVector(100, -100, 0).normalize(),
        //     new PVector(0, -100, 0).normalize(),
        //     new PVector(-100, -100, 0).normalize(),
        //     new PVector(-100, 0, 0).normalize()
        // };

        ElectronShell(int max, int shellNumber, float orbitDistance) {
            this.max = max;
            this.shellNumber = shellNumber;
            this.orbitDistance = orbitDistance;
        }

        int getSize() {
            return contents.size();
        }

        // void determinePositionAdjustment(float number) {
        //     int numberValue = (int) number/4;
        //     int numberRoundedDown = floor(number/4);
        //     int numberOnEdge = numberRoundedDown;
        //     if (numberRoundedDown < numberValue) {
        //         numberOnEdge += 1;
        //     }

        //     return 200/numberOnEdge;
        // }

        // Edge ENUMS
        // Should have same level of accessibility to the function(s) that use them.
        static final int TOP_EDGE = 1;
        static final int RIGHT_EDGE = 2;
        static final int BOTTOM_EDGE = 3;
        static final int LEFT_EDGE = 4;

        PVector calculatePositionAlongEdge(int edge, float number, float maxEdgeNumber) {
            PVector edgePosition;
            number += 1;
            maxEdgeNumber += 1;
            println("---");
            println(number);
            println(maxEdgeNumber);
            println((number/maxEdgeNumber) * 200f);
            if (edge == TOP_EDGE) {
                edgePosition = projectionVertices[0].copy();
                edgePosition.x += (number/maxEdgeNumber) * 200f;
            } else if (edge == RIGHT_EDGE) {
                edgePosition = projectionVertices[2].copy();
                edgePosition.y += (number/maxEdgeNumber) * 200f;
            } else if (edge == BOTTOM_EDGE) {
                edgePosition = projectionVertices[4].copy();
                edgePosition.x -= (number/maxEdgeNumber) * 200f;
            } else if (edge == LEFT_EDGE) {
                edgePosition = projectionVertices[6].copy();
                edgePosition.y -= (number/maxEdgeNumber) * 200f;
            } else throw new IllegalArgumentException("Provided bad edge number as argument (< 0 or > 4).");
            return edgePosition.normalize();
        }

        PVector calculateElectronProjectionVector(int iterNo, int amountOfElectrons, int surplusAmount) {
            if (iterNo >= amountOfElectrons) throw new IllegalArgumentException("Iteration number was illegally manipulated.");
            float edgeBreak = amountOfElectrons / 4f;
            println("== RIPTIDE ==");
            println(iterNo);
            println(amountOfElectrons);
            println(surplusAmount);
            println(edgeBreak);
            println("==");
            if (iterNo <= edgeBreak) {
                // Edge 1
                if (surplusAmount > 0)
                    return calculatePositionAlongEdge(TOP_EDGE, iterNo, floor(edgeBreak) + 1);
                else
                    return calculatePositionAlongEdge(TOP_EDGE, iterNo, floor(edgeBreak));
            } else if (iterNo >= edgeBreak && iterNo <= edgeBreak * 2) {
                // Edge 2
                if (surplusAmount > 1)
                    return calculatePositionAlongEdge(RIGHT_EDGE, iterNo, floor(edgeBreak) + 1);
                else
                    return calculatePositionAlongEdge(RIGHT_EDGE, iterNo, floor(edgeBreak));
            } else if (iterNo >= edgeBreak * 2 && iterNo <= edgeBreak * 3) {
                // Edge 3
                if (surplusAmount > 2)
                    return calculatePositionAlongEdge(BOTTOM_EDGE, iterNo, floor(edgeBreak) + 1);
                else
                    return calculatePositionAlongEdge(BOTTOM_EDGE, iterNo, floor(edgeBreak));
            } else if (iterNo >= edgeBreak * 3) {
                // Edge 4
                /*
                We don't provide a +1 to the maximum along edge because you cannot have >3 surplus,
                which would mathematically result in a normal rectangular distribution anyway.
                */
                return calculatePositionAlongEdge(LEFT_EDGE, iterNo, floor(edgeBreak));
            } else throw new IllegalArgumentException("Iteration number was illegally manipulated. " + iterNo + " " + amountOfElectrons + " " + edgeBreak);
        }

        boolean addElectron() {
            // This will probably only occur when a new shell needs creating, but SRP means it's implemented here.
            if (contents.size() == max) return false;

            // Initial position is not important, it will be changed immediately.
            Electron newElectron = new Electron(0, 0, 0, core);
            children.add(newElectron);
            contents.add(newElectron);

            int amountOfElectrons = contents.size();
            // Surplus electrons represent the number of electrons that can't be "divided" along the edges of a rectangle...
            int surplusElectrons = (int) (( (amountOfElectrons / 4f) - floor(amountOfElectrons / 4f) ) / 0.25f);
            println("Your surplus for this trip evening is: " + surplusElectrons);

            for (int i = 0; i < contents.size(); i++) {
                Electron electron = contents.get(i);

                PVector newPosition;

                if (max == 2) {
                    if (i == 0)
                        newPosition = projectionVertices[0].copy().setMag(orbitDistance + 200);
                    else
                        newPosition = projectionVertices[4].copy().setMag(orbitDistance + 200);
                } else {
                    newPosition = calculateElectronProjectionVector(i, amountOfElectrons, surplusElectrons).setMag(orbitDistance + 200 * shellNumber);
                }

                electron.pos = PVector.add(pos, newPosition);
                electron.setInitialCircularVelocityFromForce(core, core.calculateCoulombsLawForceOn(electron));
            }

            return true;
        }

        boolean removeElectron() {
            if (contents.size() == 0) return false;
            
            // Remove the last appended electron in the shell.
            int index = contents.size() - 1;
            Electron target = contents.get(index);
            target.delete();
            contents.remove(index);
            
            return true;
        }
    }

    public void addElectron() {
        if (shells.size() == 0)
            throw new IllegalStateException("An atom has no electron shells.");

        int numberOfShells = shells.size();
        ElectronShell lastShell = shells.get(numberOfShells - 1);

        if (!lastShell.addElectron()) {
            ElectronShell newShell = new ElectronShell(8, numberOfShells + 1, orbitDistance);
            shells.add(newShell);
            newShell.addElectron();
        }
    }

    public void removeElectron() {
        if (shells.size() == 0)
            throw new IllegalStateException("An atom has no electron shells.");
            
        ElectronShell lastShell = shells.get(shells.size() - 1);
        lastShell.removeElectron();

        if (lastShell.getSize() == 0)
            shells.remove(shells.size() - 1);
    }

    private boolean shouldParticlesDraw = false;

    /*
    This approach is used because it a) unifies the conditions all into one
    function allowing easy changes later if necessary, and b) limits the need
    to call PVector.dist 1,000 times just because every particle of an Atom wants
    to know
    */
    private void calculateShouldParticlesDraw() {
        if (PVector.dist(cam.position, pos) > (r * 2) + 1000) {
            shouldParticlesDraw = false;
        } else {
            shouldParticlesDraw = true;
        }
    }

    // And of course, we don't want write access to this field and so it does not win, good day sir.
    boolean shouldParticlesDraw() {
        return true;
    }
}