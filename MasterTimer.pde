class Timer {
    String id;
    float duration;
    IFunction onEnd;
    IFunction onIteration;
     
    Timer(String id, float duration, IFunction onEnd, IFunction onIteration) {
        this.id = id;
        this.duration = duration;
        this.onEnd = onEnd;
        this.onIteration = onIteration;
        masterTimer.activeTimers.put(id, this);
    }
    
    void tick() {
        if (onIteration != null)
            onIteration.call();
        
        duration -= time.deltaTime();
        
        if (duration <= 0) {
            onEnd.call();
            masterTimer.activeTimers.remove(id);
        }
    }
    
    void destroy() {
        masterTimer.activeTimers.remove(id);
    }
    
    void destroy(boolean allowFinish) {
        if (allowFinish)
            onEnd.call();
        destroy();
    }
}

class MasterTimer {
	HashMap<String, Timer> activeTimers = new HashMap();
	
	void tick() {
		 for (int i = 0; i < activeTimers.size(); i++) {
		 	Timer timer = activeTimers.get(i);
		 	timer.tick();
		 }
	}
}