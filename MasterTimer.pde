class Timer {
  MasterTimer masterTimer;
  String id;
  float duration; 
  Function onEnd;
  Function onIteration;
   
   Timer(MasterTimer masterTimer, String id, float duration, Function onEnd, Function onIteration) {
     this.masterTimer = masterTimer;
     this.id = id;
     this.duration = duration;
     this.onEnd = onEnd;
     this.onIteration = onIteration;
   }
   
   void Tick() {
     if (onIteration != null)
       onIteration.Call();
     
     duration -= time.DeltaTime();
     
     if (duration <= 0) {
        onEnd.Call();
        masterTimer.Destroy(id);
     }
   }
}

class MasterTimer {
  HashMap<String, Timer> activeTimers = new HashMap();
  
  void Tick() {
    for (int i = 0; i < activeTimers.size(); i++) {
       Timer timer = activeTimers.get(i);
       timer.Tick();
    }
  }
  
  Timer Create(String id, float duration, Function onEnd, Function onIteration) {
    Timer timer = new Timer(this, id, duration, onEnd, onIteration);
    activeTimers.put(id, timer);
    return timer;
  }
  
  Timer Create(String id, float duration, Function onEnd) {
    Timer timer = new Timer(this, id, duration, onEnd, null);
    activeTimers.put(id, timer);
    return timer;
  }
  
  void Destroy(String id) {
    Timer timer = activeTimers.get(id);
    timer.onEnd.Call();
  }
}