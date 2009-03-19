package {
    import flash.display.Sprite
    import flash.text.TextField
    import flash.text.TextFieldAutoSize
    import flash.display.SimpleButton
    import flash.media.Sound
    import flash.events.*
    import flash.utils.setTimeout

    public class GenerateAudio extends Sprite {

	private var bassline:Bassline = new Bassline()
	private var sound:Sound = new Sound()
	private var playing:Boolean = false

	private var indicators:Array = []
	private var vumeter:VUMeter = new VUMeter()

	public function GenerateAudio() {
	    clock.frequency[0] = 8.0
	    bassline.glider.frequency[0] = 8.0 / 2

	    drawRoundedRectangle(graphics, 0, 0.5,235,0,430,20)

	    var label:TextField = new TextField()
	    label.defaultTextFormat = buttonTextFormat
	    label.width = 195
	    label.autoSize = TextFieldAutoSize.CENTER
	    label.text = "Bassline experiment v1.0             (c) 2009 Joost Diepenmaat\njoost@zeekat.nl                                    http://joost.zeekat.nl"
	    label.y = 0
	    label.x = 240
	    addChild(label)	    


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
		bassline.glider.frequency[0] = value / 2
	    }

	    for (var i:int = 0; i < 16; i++) {
		var b:DialButton = new DialButton("Freq",Math.round(Math.random()*128),-1.0,127.0,0x00dddd)
		b.x = 35 + 25 * i
		b.y = 50
		addChild(b)
		b.onChange = (function(ii:int):Function {
			return function(value:Number):void {
			    var index:uint = Math.round(value)
			    bassline.seq["note"+ii][0] = index == -1 ? -1.0 : MIDI_NOTES[index]
			}
		    }
		)(i)
		var tb:ToggleButton = new ToggleButton("Acc",false,0x700000,0xf00000)
		tb.x = 35 + 25 * i
		tb.y = 75
		addChild(tb)
		tb.onOn = (function(ii:int):Function {
			return function():void {
			    bassline.accent["note"+ii][0] = 1.0
			}
		    }
		)(i)
		tb.onOff = (function(ii:int):Function {
			return function():void {
			    bassline.accent["note"+ii][0] = 0.0
			}
		    }
		)(i)

		tb = new ToggleButton("Glide",false,0x700000,0xf00000)
		tb.x = 35 + 25 * i
		tb.y = 100
		addChild(tb)
		tb.onOn = (function(ii:int):Function {
			return function():void {
			    bassline.slide["note"+ii][0] = 1.0
			}
		    }
		)(i)
		tb.onOff = (function(ii:int):Function {
			return function():void {
			    bassline.slide["note"+ii][0] = 0.0
			}
		    }
		)(i)


		tb = new ToggleButton(i.toString(),false,0x007000,0x00f000,0)
		tb.x = 35 + 25 * i
		tb.y = 25
		addChild(tb)
		indicators.push(tb)
	    }


	    var dial2:DialButton = new DialButton("FRQ",0.2,0.0,0.5)
	    dial2.x = 60
	    dial2.y = 0
	    addChild(dial2)
	    dial2.onChange = function(value:Number):void {
		bassline.interpolateF.input[0] = value
	    }

	    var dial3:DialButton = new DialButton("Q",0.2,0.0,1.0)
	    dial3.x = 85
	    dial3.y = 0
	    addChild(dial3)
	    dial3.onChange = function(value:Number):void {
		bassline.interpolateQ.input[0] = value
	    }

	    var dial4:DialButton = new DialButton("Decay",0.888,0.0,1.0)
	    dial4.x = 110
	    dial4.y = 0
	    addChild(dial4)
	    dial4.onChange = function(value:Number):void {
		bassline.decay.decay[0] = 1.0 - Math.pow(1.0 - (0.5 + value /4),8)
	    }

	    var dialMod:DialButton = new DialButton("Mod",0.2,0.0,1.0)
	    dialMod.x = 135
	    dialMod.y = 0
	    addChild(dialMod)
	    dialMod.onChange = function(value:Number):void {
		bassline.envMod.inputC[0] = value
	    }	    

	    var dialAcc:DialButton = new DialButton("Acc",0.5,0.2,4.0)
	    dialAcc.x = 160
	    dialAcc.y = 0
	    addChild(dialAcc)
	    dialAcc.onChange = function(value:Number):void {
		bassline.accentStrength.inputC[0] = value
	    }

	    var dialVol:DialButton = new DialButton("Vol",0.5,0.0,1.0)
	    dialVol.x = 185
	    dialVol.y = 0
	    addChild(dialVol)
	    dialVol.onChange = function(value:Number):void {
		bassline.volume.inputC[0] = value
	    }


	    vumeter.x = 10
	    vumeter.y = 25
	    addChild(vumeter)

	    
	    var rbutton:ToggleButton = new ToggleButton("RAND",false,0x909090,0xf0f0f0)
	    knobs.pop()
	    rbutton.x = 210
	    rbutton.y = 0
	    addChild(rbutton)
	    rbutton.onOn = function():void { 
		randomize();
		var id:Object
		id = flash.utils.setTimeout(function():void { rbutton.setValue(false) }, 200 )
	    }
	    rbutton.onOff = function():void {}

	    randomize()

	    sound.addEventListener(SampleDataEvent.SAMPLE_DATA,generateSound)

	    sound.play()
	}

	public function generateSound(event:flash.events.SampleDataEvent):void {
	    if (playing) {
		clock.run(2048)
		bassline.run(2048)


		var avg:Number = 0.0
		for ( var c:int=0; c<2048; c++ ) {
		    var out:Number = Math.min(1.0,bassline.volume.output[c])
		    avg += Math.abs(out)
		    event.data.writeFloat(out)
		    event.data.writeFloat(out)
		}
		for (var i:int=0; i < 16; i++) {
		    indicators[i].setValue(i == bassline.seq.step)
		}
		vumeter.setValue(avg/2048)
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

function randomize():void {
    for (i = 1; i < knobs.length; i++) {
	knobs[i].randomize()
    }
}

var clock:Clock = new Clock()

include "gui.as"
include "modules.as"
