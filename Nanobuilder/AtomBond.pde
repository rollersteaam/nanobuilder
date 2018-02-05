class AtomBond {
    Atom first;
    Atom second;

    PVector position = new PVector();
    PVector rotation = new PVector();

    PShape shape, top, bottom, body;

    private final static float RADIUS = 50;
    private final static float SIDES = 8;

    float height;

    AtomBond(Atom first, Atom second) {
        this.first = first;
        this.second = second;

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

        worldManager.registerBond(this);
        // position = PVector.sub(first.pos, second.pos).div(2);
    }

    // Updates the shape's proportions to its two parents.
    void updateShape() {

    }

    void display() {
        pushMatrix();
        pushStyle();

        PVector dPos = PVector.sub(second.pos, first.pos);
        position = PVector.add(first.pos, dPos.copy().div(2));
        rotation.y = atan2(dPos.y, dPos.x);
        rotation.x = atan2(dPos.z, dPos.x);
        translate(position.x, position.y, position.z);
        rotateX(rotation.y);
        rotateZ(rotation.x);
        // shape.scale(1, 1, PVector.dist(first.pos, second.pos) / height / 100);
        shape(shape);

        popStyle();
        popMatrix();
    }

    void delete() {

    }
}
