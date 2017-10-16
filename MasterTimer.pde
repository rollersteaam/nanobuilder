class MasterTimer {
  Map<String, Timer> activeTimers = new HashMap();
  
  int lastMillis = millis();
  int deltaTime = 0;
  
  class Timer {
    MasterTimer masterTimer;
    string id;
    float duration; 
    Function onEnd;
    Function onIteration;
     
     Timer(MasterTime masterTimer, string id, float duration, Function onEnd, Function onIteration) {
       this.masterTime = masterTime;
       this.id = id;
       this.duration = duration;
       this.onEnd = onEnd;
       this.onIteration = onIteration;
     }
     
     void Tick() {
       if (onIteration != null)
         onIteration.Call();
       
       duration -= 
       
       if (duration <= 0) {
          onEnd.Call();
          this = null;
       }
     }
  }

  
  void Tick() {
    deltaTime = millis() - lastMillis;
    
    for (int i = 0; i < activeTimers.length; i++) {
       Timer timer = activeTimers.get(i);
       timer.Tick();
    }
  }
  
  Timer Create(string id, float duration, Function onEnd, Function onIteration) {
    Timer timer = new Timer(this, id, duration, onEnd, onIteration);
    activeTimers.put(timer.id, timer);
    return timer
  }
  
  Timer Create(string id, float duration, Function onEnd) {
    Timer timer = new Timer(this, id, duration, onEnd, null);
    activeTimers.put(timer.id, timer);
    return timer
  }
  
  Timer Destroy(string id) {
    activeTimers.
  }
}
