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
        first.addBond(this);
        second.addBond(this);

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

    void display() {
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

    void delete() {
        first.removeBond(this);
        second.removeBond(this);
        worldManager.unregisterBond(this);
        shape = null;
        top = null;
        bottom = null;
        body = null;
    }
}
