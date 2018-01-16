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

    @Override
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