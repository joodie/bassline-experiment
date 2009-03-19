
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

	    var dial:DialButton = new DialButton("SPED",20,0.5,20)
	    dial.x = 35
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
		    event.data.writeFloat(clock.output[c]);
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
include "modules.as"
