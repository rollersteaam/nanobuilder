class ImageUI extends UIElement {
    private String filename;
    private PImage image;
    private boolean stretch = false;

    ImageUI(float x, float y, float w, float h, String filename) {
        super(x, y, w, h);
        this.filename = filename;
    
        image = loadImage(filename);
    }

    @Override
    void display() {
        if (image == null) {
            println(filename + " IS MISSING");
            return;
        }

        super.display();

        if (stretch)
            image(image, position.x, position.y, size.x, size.y);
        else
            image(image, position.x, position.y);

        finishDrawing();        
    }

    public void setStretch(boolean shouldStretch) {
        stretch = shouldStretch;
    }
}