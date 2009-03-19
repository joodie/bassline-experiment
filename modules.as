const SAMPLE_RATE:Number = 44100.0

class Oscillator {
    public var output:Vector.<Number> = buffer();
    public var frequency:Vector.<Number> = buffer();
    private var phase:Number = 0.0;

    public function run(frames:uint):void {
	var phaseStep:Number = this.frequency[0] / (SAMPLE_RATE / 2)
	for (var i:uint = 0; i < frames; i++) {
	    if (this.phase < 1.0) {
		this.output[i] = 0.5;
	    }
	    else {
		this.output[i] = -0.5;
	    }
	    this.phase += phaseStep;
	    if (this.phase >= 2.0) {
		this.phase -= 2.0;
	    }
	}
    }
}

class Sequencer { 
    public var output:Vector.<Number> = buffer()
    public var trigger:Vector.<Number> = buffer()
    public var note0:Vector.<Number> = buffer()
    public var note1:Vector.<Number> = buffer()
    public var note2:Vector.<Number> = buffer()
    public var note3:Vector.<Number> = buffer()
    private var step:uint = 0;
    private var trigHigh:Boolean = true
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    switch (step) {
		case 0: 
		  this.output[i] = this.note0[0];
		break
		case 1: 
		  this.output[i] = this.note1[0];
		break
		case 2: 
		  this.output[i] = this.note2[0];
		break
		case 3: 
		  this.output[i] = this.note3[0];
		break
	    }
	    if (trigger[i] > 0.5) {
		if (!trigHigh) {
		    if (++step > 3) step -= 4		    
		}
		trigHigh = true
	    }
	    else {
		trigHigh = false
	    }
	}
		
    }
}

class Clock {
    public var output:Vector.<Number> = buffer()
    public var frequency:Vector.<Number> = buffer()
    private var phase:Number = 0.0
    
    public function run(frames:uint):void {
	var step:Number = frequency[0] / SAMPLE_RATE
	for (var i:uint = 0; i < frames; i++) {
	    if (phase <= 0.1) {
		output[i] = 1.0
	    }
	    else {
		output[i] = 0.0
	    }
	    phase += step
	    if (phase >= 1.0) phase -= 1.0
	}
    }
}

