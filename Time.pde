class Time {
  private int lastMillis = millis();
  private int deltaTime;

  void CalculateDeltaTime() {
    deltaTime = millis() - lastMillis;
  }
  
  int DeltaTime() {
     return deltaTime; 
  }
}
