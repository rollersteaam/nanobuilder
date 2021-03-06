class Particle {
    PVector pos = new PVector();
    PVector velocity = new PVector();
    PVector acceleration = new PVector();
    PVector displayedAcceleration = new PVector();

    float r;

    float charge;
    float mass = 1;

    color baseColor;
    color currentColor;

    PShape shape;

    Atom parent;
    ArrayList<Particle> children = new ArrayList<Particle>();

    boolean deleted = false;

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
    
    public String getName() {
        return this.getClass().getSimpleName();
    }

    public void addChild(Particle child) {
        children.add(child);
    }

    public void removeChild(Particle child) {
        children.remove(child);
    }

    void isolate() {
        for (Particle child : children) {
            child.parent = null;
        }

        children.clear();

        // if (parent == null) return;

        // parent.children.remove(this);
        parent = null;
    }

    void delete() {
        shape = null;
        worldManager.unregisterParticle(this);
        deleted = true;
        if (parent != null)
            parent.remove(this);
    }

    boolean select() {
        if (parent == null) return true;
        return parent.shouldParticlesDraw();
        // currentColor = color(135);
        // acceleration.mult(0);
        // velocity.mult(0);
    }

    void deselect() {
        // revertToBaseColor();
        // acceleration.mult(0);
        // velocity.mult(0);
    }

    public void setColour(color colour) {
        shape.setFill(colour);
        currentColor = colour;
    }

    void revertToBaseColor() {
        shape.setFill(baseColor);
        currentColor = baseColor;
    }

    void addPosition(PVector addingPos) {
        pos.x += addingPos.x;
        pos.y += addingPos.y;
        pos.z += addingPos.z;

        for (Particle child : children) {
            child.addPosition(addingPos);
        }
    }

    void setPosition(PVector newPos) {
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

    void evaluatePhysics() {
        // if ((pos.x + r) >= 10000 || (pos.x - r) <= -10000) {
        //     addPosition(new PVector(-(velocity.x), 0, 0));
        //     velocity.x *= -1;
        //     velocity.x /= 4;            
        //     // delete();
        // }

        // if ((pos.y + r) >= 10000 || (pos.y - r) <= -10000) {
        //     addPosition(new PVector(0, -(velocity.y), 0));
        //     velocity.y *= -1;
        //     velocity.y /= 4;            
        //     // delete();
        // }

        // if ((pos.z + r) >= 10000 || (pos.z - r) <= -10000) {
        //     addPosition(new PVector(0, 0, -(velocity.z)));
        //     velocity.z *= -1;
        //     velocity.z /= 4;            
        //     // delete();
        // }

        /*
        Rough collision stuff goes here
        */
        // If distance from another atom is less than radius then intersection
        // for (Particle particle : worldManager.particleList) {
        //     // Spherical intersection
        //     // Determine the highest radius
        //     // float comparedRadius = (r > particle.r) ? r : particle.r;
        //     if (particle == this)
        //         continue;
        //     // Atoms are "abstract" but simplified collisions should still allow
        //     // atom and particle collisions, e.g. if the target particle doesn't belong to an atom.
        //     if (particle.parent != null || parent != null)
        //         continue;

        //     // if (PVector.dist(pos, particle.pos) <= r * 2) {
        //     //     collide(particle);
        //     // }
        //     if (PVector.dist(pos, particle.pos) <= (r + particle.r)) {
        //         collide(particle);
        //     }
        // }

        // if (parent != null) {
        //     PVector diff = PVector.sub(pos, parent.pos);
            
        //     if (diff.mag() > parent.r + 100)
        //         parent.remove(this);
        // }

        velocity.add(acceleration);
        // pos.add(velocity);
        addPosition(velocity);
        /*
        Acceleration once 'dealt' is never kept, since it converts into velocity.
        This line resets acceleration so we're ready to regather all forces next frame.
        */
        displayedAcceleration = acceleration;
        acceleration = new PVector();
    }

    public void collide(Particle particle) {
        // // To make a more accurate incident vector, we could also set mag the magnitude to the radius of either atom (probably this one).
        // PVector incidentVector = PVector.sub(pos, particle.pos);
        // // Impulse = change in momentum
        // // p = m1v1 - m2v2
        // float impulse = mass * (velocity.mag()) - particle.mass * (particle.velocity.mag());
        // println(impulse);
        // // Initial kinetic energy
        // // E = 1/2*m1*v1^2 + 1/2*m2*v2^2
        // float energy = 1/2 * mass * pow((velocity.mag()), 2) + 1/2 * particle.mass * pow((particle.velocity.mag()), 2);
        // println(energy);
        // println();
        // // This new velocity magnitude should change depending on who calls collide.
        // // After -2 * impulse plus or minus can be used. It's a quadratic equation.
        // float newVelocityMagnitude = -2 * impulse - sqrt( pow(2 * impulse, 2) - 4 * ( pow(impulse, 2) - 2 * energy * mass ) );
        // // So we must halve it after we're done.
        // newVelocityMagnitude /= 2;
        // newVelocityMagnitude *= 1e25;

        // incidentVector.setMag(newVelocityMagnitude);
        // /*
        //     New added velocity needs to be opposite the direction of incidence...

        //     Note that this doesn't logically follow, this is because the directions of the particle velocitys'
        //     are not factored in during the above calculations. There may be a requirement to evaluate this later.

        //     For now, believable collision is observed with this config.
        // */
        // if (newVelocityMagnitude > 0) incidentVector.mult(-1);
        // particle.velocity = incidentVector;
        // particle.velocity.set(incidentVector.x, incidentVector.y, incidentVector.z);
        
        // velocity.set(
        //     incidentVector.x,
        //     incidentVector.y,
        //     incidentVector.z
        // );
        float selfPreviousX = velocity.x;
        float selfPreviousY = velocity.y;
        float selfPreviousZ = velocity.z;

        velocity.set(
            (velocity.x * (mass - particle.mass) + 2 * particle.mass * particle.velocity.x) / (mass + particle.mass),
            (velocity.y * (mass - particle.mass) + 2 * particle.mass * particle.velocity.y) / (mass + particle.mass),
            (velocity.z * (mass - particle.mass) + 2 * particle.mass * particle.velocity.z) / (mass + particle.mass)
        );
        
        // particle.velocity.set(
        //     (particle.velocity.x * (mass - particle.mass) + 2 * particle.mass * particle.velocity.x) / (mass + particle.mass),
        //     (particle.velocity.y * (mass - particle.mass) + 2 * particle.mass * particle.velocity.y) / (mass + particle.mass),
        //     (velocity.z * (mass - particle.mass) + 2 * particle.mass * particle.velocity.z) / (mass + particle.mass)
        // );
        particle.velocity.set(
            (particle.velocity.x * (particle.mass - mass) + 2 * mass * selfPreviousX) / (mass + particle.mass),
            (particle.velocity.y * (particle.mass - mass) + 2 * mass * selfPreviousY) / (mass + particle.mass),
            (particle.velocity.z * (particle.mass - mass) + 2 * mass * selfPreviousZ) / (mass + particle.mass)
        );


        // particle.collide(this);
        // particle.velocity.add(incidentVector);
        // And now attempt to cancel any attempts to process the collision a second time.
    }

    void display() {
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
        float bottomExpression = 4 * PI * 8.85 * pow(10, -12) * pow(vector.mag(), 2);
        /*
        If the force is infinite (which should be impossible)
        then disregard current tick. We aren't trying to emulate infinity.
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