interface Function {
    void Call();
}

class ObserverEvents {
    class PrintMessage implements Function {
        String expStr;

        PrintMessage(String expStr) {
            this.expStr = expStr;
        }

        void Perform()
        {
            println("You clicked on me, " + expStr);
        }
    }

    class RotateCameraY implements Function {
        void Perform() {
            Camera.rotY += radians(10);
            println("Rotating");
        }
    }
}
