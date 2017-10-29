interface Function {
    void Call();
}

class ObserverEvents {
    class PrintMessage implements Function {
        String expStr;

        PrintMessage(String expStr) {
            this.expStr = expStr;
        }

        void Call()
        {
            println("You clicked on me, " + expStr);
        }
    }

    class RotateCameraY implements Function {
        void Call() {
            camera.rotY += radians(10);
            println("Rotating");
        }
    }
}