class Particle {
    PVector pos = new PVector();
    PVector velocity = new PVector();
    PVector acceleration = new PVector();
    
    float r;

    float charge;
    double mass = 1;

    color baseColor;
    color currentColor;

    PShape shape;
    Particle parent;

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

    void delete() {
        shape = null;
        particleList.remove(this);
    }

    void select() {
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

    void setPosition(PVector newPos) {
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

    void evaluateElectricalField() {
        for (Particle particle : particleList) {
            if (particle == this) continue;
            if (particle.parent != this) continue;
            applyForce(particle, calculateCoulombsLawForceOn(particle));
        }
    }

    void evaluatePhysics() {
        velocity.add(acceleration);
        pos.add(velocity);
        /*
        Acceleration once 'dealt' is never kept, since it converts into velocity.
        This line resets acceleration so we're ready to regather all forces next frame.
        */
        acceleration = new PVector();
    }

    void display() {
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
        float bottomExpression = 4 * PI * 8.85 * pow(10, -12) * pow(vector.mag(), 2);
        /*
        If the force is infinite (which should be impossible)
        then disregard current tick.
        */
        if (bottomExpression == 0) return 0;
        return topExpression / bottomExpression;
    }

    private final int X_DOMINANT = 0;
    private final int Y_DOMINANT = 1;
    private final int Z_DOMINANT = 2;

    public void setInitialCircularVelocityFromForce(Particle particle, float force) {
        PVector diff = PVector.sub(pos, particle.pos).normalize();
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
        // return cross.setMag(
        //     sqrt(
        //         // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
        //         abs(
        //             force * 100 * PVector.dist(particle.pos, this.pos) / (float) mass
        //         )
        //     )
        // );
        velocity = cross.setMag(
            sqrt(
                // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
                abs(
                    force * 100 * PVector.dist(particle.pos, this.pos) / (float) mass
                )
            )
        );
        // velocity = cross.setMag(
        //     sqrt(
        //         // It's fine to get the absolute value here, we need the magnitude and not the 'direction' the formula returns.
        //         abs(
        //             proton.calculateCoulombsLawForceOn(this) * 100 * PVector.dist(proton.pos, this.pos) / (float) mass
        //         )
        //     )
        // );
    }
}