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
        then disregard current frame.
        */
        if (bottomExpression == 0) return 0;
        return topExpression / bottomExpression;
    }
}