class ObserverEvents {
    class PrintMessage implements IFunction {
        String expStr;

        PrintMessage(String expStr) {
            this.expStr = expStr;
        }

        void Call()
        {
            println("You clicked on me, " + expStr);
        }
    }

    class RotateCameraY implements IFunction {
        void Call() {
            camera.rot.y += radians(10);
            println("Rotating");
        }
    }
}