interface Event {
    void Perform();
}

class ObserverEvents {
    class PrintMessage implements Event {
        String expStr;

        PrintMessage(String expStr) {
            this.expStr = expStr;
        }

        void Perform()
        {
            println("You clicked on me, " + expStr);
        }
    }

    class RotateCameraY implements Event {
        void Perform() {
            Camera.rotY += radians(10);
            println("Rotating");
        }
    }
}
