class Atom extends Particle {
    Proton core;
    ArrayList<Proton> listProtons = new ArrayList<Proton>();
    ArrayList<Electron> listElectrons = new ArrayList<Electron>();
    ArrayList<Neutron> listNeutrons = new ArrayList<Neutron>();

    Atom(float x, float y, float z, float radius) {
        super(x, y, z, radius);
        core = new Proton(x, y, z);
        listProtons.add(core);
        // listElectrons.add(new Electron(x + 200, y, z, core));
        // listElectrons.add(new Electron(x - 200, y, z, core));
        addElectron();
        addElectron();
        addElectron();
        addElectron();

        // PVector newPosition = new PVector(x, y + 100, z);
    }
    
    Atom() {
        this(
            random(-2000, 2000),
            random(-2000, 2000),
            random(-2000, 2000),
            // round(random(200, 600))
            250
        );
    }

    ArrayList<Electron> shell1 = new ArrayList<Electron>();
    ArrayList<Electron> shell2 = new ArrayList<Electron>();

    PVector[] projectionVertices = new PVector[] {
        new PVector(-100, 100, 0).normalize(),
        new PVector(0, 100, 0).normalize(),
        new PVector(100, 100, 0).normalize(),
        new PVector(100, 0, 0).normalize(),
        new PVector(100, -100, 0).normalize(),
        new PVector(0, -100, 0).normalize(),
        new PVector(-100, -100, 0).normalize(),
        new PVector(-100, 0, 0).normalize()
    };

    public void addElectron() {        
        for (Electron electron : shell1) {
            // 1 and 5
            PVector newPosition;

            if (shell1.size() > 0)
                newPosition = projectionVertices[1].copy().setMag(150);
            else
                newPosition = projectionVertices[5].copy().setMag(150);
            // shell1.remove(electron);
            // if (shell1.size() > 0) {
            //     PVector newPosition = projectionVertices[shell1.size()].copy().setMag(150);
            // shell1.add(new Electron(
            //     newPosition.x,
            //     newPosition.y,
            //     newPosition.z,
            //     core
            // ));
            electron.pos = PVector.add(pos, newPosition);
            // shell1.add(new Electron(
            //     newPosition.x,
            //     newPosition.y,
            //     newPosition.z,
            //     core
            // ));
            // } else {
                
            // }
        }

        if (shell1.size() != 2) {
            int selection = (shell1.size() != 1) ? 1 : 5;
            PVector newPosition = projectionVertices[selection].copy();
            newPosition = PVector.add(pos, newPosition).setMag(150);
            shell1.add(new Electron(
                newPosition.x,
                newPosition.y,
                newPosition.z,
                core
            ));
        }

        for (Electron electron : shell2) {
            // 1 and 5
            PVector newPosition = projectionVertices[shell2.size()].copy().setMag(300);
            // shell1.remove(electron);
            // if (shell1.size() > 0) {
            //     PVector newPosition = projectionVertices[shell1.size()].copy().setMag(150);
            // shell1.add(new Electron(
            //     newPosition.x,
            //     newPosition.y,
            //     newPosition.z,
            //     core
            // ));
            electron.pos = PVector.add(pos, newPosition);
            // shell1.add(new Electron(
            //     newPosition.x,
            //     newPosition.y,
            //     newPosition.z,
            //     core
            // ));
            // } else {
                
            // }
        }

        if (shell2.size() != 8) {
            PVector newPosition = projectionVertices[shell2.size()].copy();
            newPosition = PVector.add(pos, newPosition).setMag(300);
            shell2.add(new Electron(
                newPosition.x,
                newPosition.y,
                newPosition.z,
                core
            ));
        }

        // int totalElectrons = initialShell1Count + initialShell2Count;
        // print(totalElectrons);
        // for (int i = 0; i < totalElectrons; i++) {
        //     if (shell1.size() == 2) {
        //         PVector newPosition = projectionVertices[shell2.size()].copy().setMag(300);
        //         shell2.add(new Electron(
        //             newPosition.x,
        //             newPosition.y,
        //             newPosition.z,
        //             core
        //         ));
        //     } else {
        //         if (shell1.size() == 1) {
        //             PVector newPosition = projectionVertices[shell1.size()].copy().setMag(150);
        //             shell1.add(new Electron(
        //                 newPosition.x,
        //                 newPosition.y,
        //                 newPosition.z,
        //                 core
        //             ));
        //         } else {
        //             PVector newPosition = projectionVertices[shell1.size()].copy().setMag(150);
        //             shell1.add(new Electron(
        //                 newPosition.x,
        //                 newPosition.y,
        //                 newPosition.z,
        //                 core
        //             ));
        //         }
        //     }
        // }
    }

    @Override
    void display() {
        if (PVector.dist(cam.position, pos) < (r + 700))
            return;

        // hint(ENABLE_DEPTH_TEST);

        color formattedColor = color(
            red(currentColor),
            green(currentColor),
            blue(currentColor),
            lerp(0, 255, (PVector.dist(cam.position, pos) * 2) / ((r + 2000)))
        );

        pushStyle();
        fill(formattedColor);
        shape.setFill(formattedColor);
        popStyle();

        super.display();

        // hint(DISABLE_DEPTH_TEST);
    }
}