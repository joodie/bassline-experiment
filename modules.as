const SAMPLE_RATE:Number = 44100.0

const MIDI_NOTES:Array = []

function midiNoteToFrequency(note:uint):Number {
    return 440.0 * Math.pow(2.0,(note-69.0)/12.0)
}

for (var i:int =0; i < 128; i++) {
    MIDI_NOTES.push(midiNoteToFrequency(i))
}

class Oscillator {
    public var output:Vector.<Number> = buffer();
    public var frequency:Vector.<Number> = buffer();
    private var phase:Number = 0.0;
    private var phaseStep:Number = 0.0;
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    phaseStep = frequency[i] / (SAMPLE_RATE / 2)
	    if (phase < 1.0) {
		output[i] = 0.5;
	    }
	    else {
		output[i] = -0.5;
	    }
	    phase += phaseStep;
	    if (phase >= 2.0) {
		phase -= 2.0;
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
    public var triggerOut:Vector.<Number> = buffer()
    public var step:uint = 0;
    private var trigHigh:Boolean = true
    private var lastNote:Number = 0.0
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    if (trigger[i] > 0.5) {
		if (!trigHigh) {
		    if (++step > 3) step -= 4
		    trigHigh = true
		}
	    }
	    else {
		trigHigh = false
	    }
	    switch (step) {
		case 0: 
		  this.output[i] = this.note0[0]
		break
		case 1: 
		  this.output[i] = this.note1[0]
		break
		case 2: 
		  this.output[i] = this.note2[0]
		break
		case 3: 
		  this.output[i] = this.note3[0]
		break
	    }
	    if (output[i] == -1.0) {
		output[i] = lastNote
		triggerOut[i] = 0.0
	    }
	    else {
		lastNote = output[i]
		triggerOut[i] = trigger[i]
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

class SimpleOnePoleFilter {
    public var input:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public var frequency:Vector.<Number> = buffer()
    private var prev:Number = 0.0
    public function run(frames:uint):void {
	var a:Number = SAMPLE_RATE / (frequency[0] * 2 * Math.PI)
	for (var i:uint = 0; i < frames; i++) {
	    prev = output[i] = prev + ((input[i] - prev) / a)
	}	
    }
}

// http://www.musicdsp.org/showArchiveComment.php?ArchiveID=29
class SimpleResonantFilter {
    public var input:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public var frequency:Vector.<Number> = buffer() // between 0 .. +/- 0.5
    public var q:Vector.<Number> = buffer() // between 0 .. 1
    private var buf0:Number = 0.0
    private var buf1:Number = 0.0
    public function run(frames:uint):void {
	var fb:Number = q[0] + q[0] / (1.0 - frequency[0])
	for (var i:uint = 0; i < frames; i++) {
	    buf0 = buf0 + frequency[0] * (input[i] - buf0 + fb * (buf0 - buf1))
	    output[i] = buf1 = buf1 + frequency[0] * (buf0 - buf1)
	}	
    }
}

class Decay {
    public var trigger:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public var decay:Vector.<Number> = buffer()
    private var trigHigh:Boolean = true
    private var state:Number = 0.0
    public function run(frames:uint):void {
	var d:Number = Math.max(0.0,Math.min(1.0,decay[0]))
	for (var i:uint = 0; i < frames; i++) {
	    if (trigger[i] > 0.5) {
		if (!trigHigh) {
		    state = 1.0
		    trigHigh = true
		}
	    }
	    else {
		trigHigh = false
	    }
	    output[i] = state
	    state *= d
	}
    }
}

class MultiplyAA {
    public var input1:Vector.<Number> = buffer()
    public var input2:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    output[i] = input1[i] * input2[i]
	}
    }
}

class MultiplyCA {
    public var inputC:Vector.<Number> = buffer()
    public var inputA:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    output[i] = inputC[0] * inputA[i]
	}
    }
}

class AddAA {
    public var input1:Vector.<Number> = buffer()
    public var input2:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    output[i] = input1[i] + input2[i]
	}
    }
}


class Interpolate {
    public var input:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    private var buffer:Number = 0.0
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    output[i] = input[0] - ( input[0] - buffer) * ((frames - i) / frames)
	}
	buffer = output[i-1]
    }
}

