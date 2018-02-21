class ImageButtonUI extends ButtonUI {
    private String filename;

    ImageButtonUI(float x, float y, float w, float h, color colour, Runnable function, String filename) {
        super(x, y, w, h, colour, function);
        this.filename = filename;
    }

    ImageButtonUI(float x, float y, float w, float h, color colour, Runnable function, String filename, color strokeColour, float strokeWeight) {
        super(x, y, w, h, colour, function, strokeColour, strokeWeight);
        this.filename = filename;
    }

    
}