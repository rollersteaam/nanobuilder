class Atom {
    PVector pos = new PVector();
    PVector velocity = new PVector();
    PVector acceleration = new PVector(0, 0, 0);
    
    float r;

    float charge;
    double mass;

    color baseColor;
    color currentColor;

    PShape shape;

    Atom(float x, float y, float z, float r) {
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

        atomList.add(this);
    }

    Atom() {
        this(
            random(-500, 500),
            random(-500, 500),
            random(-500, 500),
            round(random(25, 100))
        );
    }

    void delete() {
        shape = null;
        atomList.remove(this);
    }

    void select() {
        // currentColor = color(135);
        acceleration.mult(0);
        velocity.mult(0);
    }

    void deselect() {
        // revertToBaseColor();
        acceleration.mult(0);
        velocity.mult(0);
    }

    public void setColour(color colour) {
        shape.setFill(colour);
    }

    void revertToBaseColor() {
        shape.setFill(baseColor);
    }

    void setPosition(PVector newPos) {
        pos = newPos.copy();
    }

    void evaluateElectricalField() {
        for (Atom atom : atomList) {
            if (atom == this) continue;

            PVector dir = PVector.sub(pos, atom.pos).normalize();
            float sum = abs(dir.x) + abs(dir.y) + abs(dir.z);
            PVector mod = new PVector(abs(dir.x) / sum, abs(dir.y) / sum, abs(dir.z) / sum);

            // println("START");
            // println(dir);
            // println(sum);
            // println(mod);

            // println("PHASE 2:");
            // println(atom.charge);
            // println(charge);
            // println(atom.charge * charge);
            // println(dir.x * mod.x);

            // println(atom.charge * charge * dir.x * mod.x);
            // println((float) atom.mass * 4 * PI * 8.85 * pow(10,5));

            // println((atom.charge * charge * dir.x * mod.x) / ((float) mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2)));
            // println("END");
            // println();

            // float top = atom.charge * charge * dir.x * mod.x;
            float bottom = (float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2);
            if (bottom == 0) continue;
            
            //
            PVector d = PVector.sub(atom.pos, pos);
            float distance = d.mag();
            double force = atom.charge*charge/(4*PI*8.85*pow(10, -12)*distance*distance);
            //PVector f = d.setMag((float) force*pow(10, -52));  
            PVector f = d.setMag((float) force*1000);
            println(f);
            atom.acceleration = PVector.div(f, (float) atom.mass);
            //
            
            //atom.acceleration.add(
            //    (atom.charge * charge * dir.x) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 3000),
            //    (atom.charge * charge * dir.y) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 3000),
            //    (atom.charge * charge * dir.z) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 3000)
            //    // (atom.charge * charge * abs(dir.x) * mod.x) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 100),
            //    // (atom.charge * charge * abs(dir.y) * mod.y) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 100),
            //    // (atom.charge * charge * abs(dir.z) * mod.z) / ((float) atom.mass * 4 * PI * 8.85 * pow(10, 5) * pow(PVector.dist(atom.pos, pos), 2) / 100)
            //);
        }
    }

    void display() {
        // acceleration = acceleration.random3D().mult(2);
        PVector oldVelocity = velocity.copy();
        velocity.add(acceleration);
        pos.add(velocity);
        
        acceleration = new PVector();

        if (pos.x > 10000 || pos.x < -10000) {
            pos.sub(oldVelocity.copy().normalize().mult(r));
            velocity.x *= -1;
            velocity.x *= 0.75;
        }

        if (pos.y > 10000 || pos.y < -10000) {
            pos.sub(oldVelocity.copy().normalize().mult(r));
            velocity.y *= -1;
            velocity.y *= 0.75;
        }

        if (pos.z > 10000 || pos.z < -10000) {
            pos.sub(oldVelocity.copy().normalize().mult(r));
            velocity.z *= -1;
            velocity.z *= 0.75;
        }
        // if (pos.x > 1000 || pos.x < -1000) {
        //     pos.sub(oldVelocity.copy().normalize().mult(r));
        //     velocity.x *= -1;
        // }

        // if (pos.y > 1000 || pos.y < -1000) {
        //     pos.sub(oldVelocity.copy().normalize().mult(r));
        //     velocity.y *= -1;
        // }

        // if (pos.z > 1000 || pos.z < -1000) {
        //     pos.sub(oldVelocity.copy().normalize().mult(r));
        //     velocity.z *= -1;
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
}