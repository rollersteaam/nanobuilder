class Atom extends Particle {
    Proton core;
    ArrayList<Particle> nucleus = new ArrayList<Particle>();
    float nucleusRadius = 0;

    ArrayList<ElectronShell> shells = new ArrayList<ElectronShell>();
    float orbitOffset = 0;

    Atom(float x, float y, float z, int electrons, int protons, int neutrons) {
        super(x, y, z, 200);
        
        core = new Proton(x, y, z, this);
        core.setCoreOf(this);
        nucleus.add(core);

        worldManager.atomList.add(this);

        // An atom always has one shell, or it's not an atom and should throw an exception before this anyway.
        shells.add(new ElectronShell(this, 2, 1));

        for (int remainingElectrons = electrons; remainingElectrons > 0; remainingElectrons--) {
            addElectron();
        }

        int remainingProtons = protons - 1;
        int remainingNeutrons = neutrons;
        for (int remainingSum = remainingProtons + remainingNeutrons; remainingSum > 0; remainingSum--) {
            if (random.nextInt(1) == 0) {
                if (remainingProtons > 0) {
                    nucleus.add(new Proton(500, 500, 500, this));
                    remainingProtons--;
                } else {
                    nucleus.add(new Neutron(500, 500, 500, this));
                }
            } else {
                if (remainingNeutrons > 0) {
                    nucleus.add(new Neutron(500, 500, 500, this));
                    remainingNeutrons--;
                } else {
                    nucleus.add(new Proton(500, 500, 500, this));                    
                }
            }
        }

        redistributeNucleus();
    }
    
    Atom(float x, float y, float z) {
        this(
            x,
            y,
            z,
            round(random(1, 50)),
            round(random(1, 20)),
            round(random(1, 20))
        );
    }
    
    Atom(int electrons, int protons, int neutrons) {
        this(
            random(-6000, 6000),
            random(-6000, 6000),
            random(-6000, 6000),
            electrons,
            protons,
            neutrons
        );
    }

    Atom() {
        this(
            round(random(1, 50)),
            round(random(1, 20)),
            round(random(1, 20))
        );
    }

    public void remove(Particle particle) {
        println("DROWN");

        if (particle instanceof Neutron)
            remove((Neutron) particle);
        else if (particle instanceof Proton)
            remove((Proton) particle);
        else if (particle instanceof Electron)
            remove((Electron) particle);
        else throw new IllegalArgumentException("Particle seems to be unaccounted for.");
    }

    public void remove(Neutron neutron) {
        println("Releasing ownership...");

        nucleus.remove(neutron);
        neutron.isolate();
        redistributeNucleus();
    }

    public void remove(Proton proton) {
        println("Releasing ownership...");

        nucleus.remove(proton);
        proton.isolate();
        redistributeNucleus();
    }

    public void remove(Electron electron) {
        println("Releasing ownership...");

        for (ElectronShell shell : shells) {
            if (shell.removeElectron(electron)) {
                recalculateMass();
                electron.isolate();
                return;
            }
        }
    }

    public void remove(ElectronShell electronShell) {
        for (ElectronShell shell : shells) {
            if (shell == electronShell) {
                shell.delete();
                shells.remove(shell);
                recalculateRadius();
                return;
            }
        }
    }

    @Override
    void delete() {
        super.delete();

        for (Particle particle : nucleus) {
            particle.delete();
        }

        nucleus.clear();

        for (ElectronShell shell : shells) {
            shell.delete();
        }

        shells.clear();

        core = null;
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

    void recalculateRadius() {
        if (shape == null) return;
        shape.scale(1 / (r / 200));
        r = shells.size() * 200 + nucleusRadius + orbitOffset;
        shape.scale(r / 200);
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

        // if (shouldParticlesDraw) return;
        // if (PVector.dist(cam.position, pos) < ((r) + 1500)) return;

        color formattedColor = color(
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

        recalculateMass();

        if (newElectron == null) {
            ElectronShell newShell = new ElectronShell(this, (int) (2 * pow(numberOfShells + 1, 2)), numberOfShells + 1);
            shells.add(newShell);
            newShell.addElectron();
            recalculateRadius();
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

        recalculateMass();

        if (lastShell.getSize() == 0) {
            shells.remove(shells.size() - 1);
            recalculateRadius();
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
    boolean shouldParticlesDraw() {
        return shouldParticlesDraw;
    }
}