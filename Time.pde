class Time {
	private int lastMillis = millis();
	private int deltaTime; // privatized as this should not be modified under any conditions.

	void calculateDeltaTime() {
		deltaTime = millis() - lastMillis;
	}
	
	int deltaTime() { // This enforces a read-only condition.
		return deltaTime;
	}
}
