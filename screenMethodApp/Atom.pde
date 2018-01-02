class Atom {
	float x;
	float y;
	float z;
	int r;

	private color baseColor = color(random(90, 255), random(90, 255), random(90, 255));
	color currentColor = baseColor;

	Atom() {
		this.x = random(-500, 500);
		this.y = random(-500, 500);
		this.z = random(-500, 500);
		this.r = 10;
		atomList.add(this);
	}

	Atom(float x, float y, float z, int r) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.r = r;		
		atomList.add(this);
	}

	void revertToBaseColor() {
		currentColor = baseColor;
	}
  
	void display() {
        // Added radius so pop-in limits are more forgiving, pop-in less obvious.
        float screenX = screenX(x + r, y + r, z - r);
        float screenY = screenY(x + r, y + r, z - r);
  
        if ((screenX > width) || (screenY > height) || (screenX < 0) || (screenY < 0)) // Disregard objects outside of camera view.
            return;
  
		noStroke();
		fill(currentColor);

		pushMatrix();
		translate(x, y, z);
		
		sphere(r);

		//fill(0, 0);
		//stroke(255, 170);
		//rect(-100, -100, 200, 200);
		//rotateY(radians(90));
		//rect(-100, -100, 200, 200);
		popMatrix();
	} 
}