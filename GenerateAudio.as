
package {
    import flash.display.Sprite
    import flash.text.TextField
    import flash.display.SimpleButton
    import flash.media.Sound
    import flash.events.*


    public class GenerateAudio extends Sprite {

	private var sound:Sound = new Sound()
	private var playing:Boolean = false
	private var osc:Oscillator = new Oscillator();
	private var seq:Sequencer = new Sequencer();
	private var clock:Clock = new Clock()

	public function GenerateAudio() {
	    osc.frequency = seq.output;
	    seq.note0[0] = 440.0
	    seq.note1[0] = 880.0
	    seq.note2[0] = 660.0
	    seq.note3[0] = 550.0
	    seq.trigger = clock.output
	    clock.frequency[0] = 8.0

	    var button:ToggleButton = new ToggleButton("POW",false,0x700000,0xf00000)
	    button.x = 10
	    button.y = 0
	    addChild(button)
	    button.onOn = function():void { playing = true }
	    button.onOff = function():void { playing = false }

	    var dial:DialButton = new DialButton(8,0.5,20,0x404040)
	    dial.x = 30
	    dial.y = 0
	    addChild(dial)
	    dial.onChange = function(value:Number):void {
		clock.frequency[0] = value
	    }
	    

	    sound.addEventListener(SampleDataEvent.SAMPLE_DATA,generateSound)

	    sound.play()
	}

	public function generateSound(event:flash.events.SampleDataEvent):void {
	    clock.run(2048)
	    seq.run(2048)
	    osc.run(2048)
	    if (playing) {
		for ( var c:int=0; c<2048; c++ ) {
		    event.data.writeFloat(osc.output[c]);
		    event.data.writeFloat(osc.output[c]);
		}
	    }
	    else {
		for ( c=0; c<2090; c++ ) {
		    event.data.writeFloat(0.0);
		    event.data.writeFloat(0.0);
		}
	    } 
	}
    }
}


// shorthand to create new sample vectors
function buffer():Vector.<Number> {
    return new Vector.<Number>(4000,true)
}

include "gui.as"

class Oscillator {
    public var output:Vector.<Number> = buffer();
    public var frequency:Vector.<Number> = buffer();
    private var phase:Number = 0.0;

    public function run(frames:uint):void {
	var phaseStep:Number = this.frequency[0] / 22050.0;
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
	var step:Number = frequency[0] / 44100.0
	for (var i:uint = 0; i < frames; i++) {
	    if (phase <= 0.0001) {
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

