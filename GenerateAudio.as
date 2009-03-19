
package {
    import flash.display.Sprite
    import flash.text.TextField
    import flash.display.SimpleButton
    import flash.media.Sound
    import flash.events.*


    public class GenerateAudio extends Sprite {

	private var sound:Sound = new Sound()
	private var playing:Boolean = false
	private var osc:Oscillator = new Oscillator()
	private var seq:Sequencer = new Sequencer()
	private var accent:Sequencer = new Sequencer()
	private var accentDecay:Decay = new Decay()
	private var accentAmp:MultiplyAA = new MultiplyAA()
	private var accentStrength:MultiplyCA = new MultiplyCA()

	private var accentAdd:AddAA = new AddAA()
	private var slide:Sequencer = new Sequencer()
	private var clock:Clock = new Clock()
	private var decay:Decay = new Decay()
	private var filter:SimpleResonantFilter = new SimpleResonantFilter()
	private var interpolateF:Interpolate = new Interpolate()
	private var interpolateQ:Interpolate = new Interpolate()
	private var amp:MultiplyAA = new MultiplyAA()
	private var envMod:MultiplyCA = new MultiplyCA()
	private var envModAdd:AddAA = new AddAA()
	private var indicators:Array = []

	public function GenerateAudio() {
	    filter.input = osc.output
	    filter.q = interpolateQ.output
	    interpolateF.input[0] = 0.4
	    interpolateQ.input[0] = 0.4
	    decay.trigger = seq.triggerOut
	    decay.decay[0] = 0.99999
	    osc.frequency = seq.output
	    seq.note0[0] = 440.0
	    seq.note1[0] = 880.0
	    seq.note2[0] = 660.0
	    seq.note3[0] = 550.0
	    seq.trigger = clock.output
	    clock.frequency[0] = 8.0


	    accent.trigger = clock.output
	    accent.note0[0] = 0.0
	    accent.note1[0] = 0.0
	    accent.note2[0] = 0.0
	    accent.note3[0] = 0.0
	    accentAmp.input1 = accent.output
	    accentAmp.input2 = clock.output
	    accentDecay.trigger = accentAmp.output
	    accentDecay.decay[0] = 0.999
	    accentStrength.inputA = accentDecay.output
	    accentStrength.inputC[0] = 0.5

	    envMod.inputA = accentStrength.output
	    envMod.inputC[0] = 0.0
	    envModAdd.input1 = envMod.output
	    envModAdd.input2 = interpolateF.output
	    filter.frequency = envModAdd.output

	    accentAdd.input1 = accentStrength.output
	    accentAdd.input2 = decay.output
	    amp.input1 = accentAdd.output
	    amp.input2 = filter.output

	    var button:ToggleButton = new ToggleButton("POW",false,0x700000,0xf00000)
	    button.x = 10
	    button.y = 00
	    addChild(button)
	    button.onOn = function():void { playing = true }
	    button.onOff = function():void { playing = false }

	    


	    var dial:DialButton = new DialButton("SPD",20,0.5,20)
	    dial.x = 35
	    dial.y = 0
	    addChild(dial)
	    dial.onChange = function(value:Number):void {
		clock.frequency[0] = value
	    }

	    for (var i:int = 0; i < 4; i++) {
		

		var b:DialButton = new DialButton("F#"+i,Math.round(Math.random()*128),-1.0,127.0,0x00dddd)
		b.x = 60 + 25 * i
		b.y = 25
		addChild(b)
		b.onChange = (function(ii:int):Function {
			return function(value:Number):void {
			    var index:uint = Math.round(value)
			    seq["note"+ii][0] = index == -1 ? -1.0 : MIDI_NOTES[index]
			}
		    }
		)(i)
		var tb:ToggleButton = new ToggleButton("Acc",false,0x700000,0xf00000)
		tb.x = 60 + 25 * i
		tb.y = 50
		addChild(tb)
		tb.onOn = (function(ii:int):Function {
			return function():void {
			    accent["note"+ii][0] = 1.0
			}
		    }
		)(i)
		tb.onOff = (function(ii:int):Function {
			return function():void {
			    accent["note"+ii][0] = 0.0
			}
		    }
		)(i)

		tb = new ToggleButton("Glide",false,0x700000,0xf00000)
		tb.x = 60 + 25 * i
		tb.y = 75
		addChild(tb)
		tb.onOn = (function(ii:int):Function {
			return function():void {
			    slide["note"+ii][0] = 1.0
			}
		    }
		)(i)
		tb.onOff = (function(ii:int):Function {
			return function():void {
			    slide["note"+ii][0] = 0.0
			}
		    }
		)(i)


		tb = new ToggleButton(i.toString(),false,0x007000,0x00f000,0)
		tb.x = 60 + 25 * i
		tb.y = 0
		addChild(tb)
		indicators.push(tb)
	    }


	    var dial2:DialButton = new DialButton("FRQ",0.2,0.0,0.5)
	    dial2.x = 160
	    dial2.y = 25
	    addChild(dial2)
	    dial2.onChange = function(value:Number):void {
		interpolateF.input[0] = value
	    }

	    var dial3:DialButton = new DialButton("Q",0.2,0.0,1.0)
	    dial3.x = 185
	    dial3.y = 25
	    addChild(dial3)
	    dial3.onChange = function(value:Number):void {
		interpolateQ.input[0] = value
	    }

	    var dial4:DialButton = new DialButton("Decay",0.888,0.0,1.0)
	    dial4.x = 210
	    dial4.y = 25
	    addChild(dial4)
	    dial4.onChange = function(value:Number):void {
		decay.decay[0] = 1.0 - Math.pow(1.0 - (0.5 + value /4),8)
	    }

	    var dialMod:DialButton = new DialButton("Mod",0.2,0.0,1.0)
	    dialMod.x = 235
	    dialMod.y = 25
	    addChild(dialMod)
	    dialMod.onChange = function(value:Number):void {
		envMod.inputC[0] = value
	    }	    

	    var dialAcc:DialButton = new DialButton("Acc",0.5,0.2,4.0)
	    dialAcc.x = 260
	    dialAcc.y = 25
	    addChild(dialAcc)
	    dialAcc.onChange = function(value:Number):void {
		accentStrength.inputC[0] = value
	    }	    
	    addChild(debug)

	    sound.addEventListener(SampleDataEvent.SAMPLE_DATA,generateSound)

	    sound.play()
	}

	public function generateSound(event:flash.events.SampleDataEvent):void {
	    if (playing) {
		clock.run(2048)
		seq.run(2048)
		osc.run(2048)
		interpolateF.run(2048)
		decay.run(2048)
		accent.run(2048)
		accentAmp.run(2048)
		accentDecay.run(2048)
		accentStrength.run(2048)
		accentAdd.run(2048)


		envMod.run(2048)
		envModAdd.run(2048)
		interpolateQ.run(2048)
		filter.run(2048)

		amp.run(2048)
		for ( var c:int=0; c<2048; c++ ) {
		    event.data.writeFloat(amp.output[c])
		    event.data.writeFloat(amp.output[c])
		}
		for (var i:int=0; i < 4; i++) {
		    indicators[i].setValue(i == seq.step)
		}
		debug.text = accentDecay.output[0]+ " " +accentStrength.output[0].toString()
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
