interface Event {
    void Perform();
}

class ObserverEvents {
    class printMessage implements Event {
        String expStr;
        
        public printMessage(String expStr) {
            this.expStr = expStr;   
        }
        
        void Perform()
        {
            println("You clicked on me, " + expStr);
        }
    }
    
    class rotateCameraY implements Event {
        void Perform() {
            Camera.rotY += radians(10);
            println("Rotating");
        }
    }        
}