// Flash Synthesizer / Bassline Experiment
// Copyright (C) 2009 Joost Diepenmaat - joost@zeekat.nl
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


// I think as an introduction the following are reasonable:

// http://www.kvraudio.com/wiki/?id=The+Basics+Of+Subtractive+Synthesis
// http://www.geocities.com/SunsetStrip/Underground/2288/2ansynth.htm
// http://www.geocities.com/sunsetstrip/studio/5821/analog.html

// But basically, any text that explains "analogue" synthesizers should
// work.

// In my code, all the audio algorhitms are in modules.as - with each class
// implementing a more or less complex building block (like the oscillator
// and filters). Every time a block of audio data is generated, it runs
// each module instance in the correct order, so, for example, the clock is
// run first, then the sequencers (in the Bassline instance), then the
// interpolator (for gliding notes), then the oscillator etc...

// This is fairly standard, but the details are a more or
// less optimized for actionscript. I don't really have the time to explain
// in full, but if you're mainly interested in the way the data is
// processed, the run() methods are the ones you need - the rest is just
// setup (which modules are used and what outputs are plugged into what
// inputs).

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
	    var bg:Sprite = new Sprite()
	    drawRoundedRectangle(bg.graphics, 0, 0.5,0,0,440,175)
	    addChild(bg)


	    var label:TextField = new TextField()
	    label.defaultTextFormat = titleTextFormat
	    label.width = 195
	    label.autoSize = TextFieldAutoSize.CENTER
	    label.text = "Bassline"
	    label.y = 5
	    label.x = 10
	    addChild(label)	    

	    label = new TextField()
	    label.defaultTextFormat = buttonTextFormat
	    label.width = 195
	    label.autoSize = TextFieldAutoSize.CENTER
	    label.text = "Bassline experiment v1.1             (c) 2009 Joost Diepenmaat\njoost@zeekat.nl                                    http://joost.zeekat.nl"
	    label.y = 50
	    label.x = 240
	    addChild(label)	    


	    var button:ToggleButton = new ToggleButton("POW",false,0x700000,0xf00000)
	    button.x = 10
	    button.y = 50
	    addChild(button)
	    button.onOn = function():void { playing = true }
	    button.onOff = function():void { playing = false }

	    var dial:DialButton = new DialButton("SPD",20,0.5,20)
	    dial.x = 35
	    dial.y = 50
	    addChild(dial)
	    dial.onChange = function(value:Number):void {
		clock.frequency[0] = value
		bassline.glider.frequency[0] = value / 2
	    }

	    for (var i:int = 0; i < 16; i++) {
		var b:DialButton = new DialButton("Freq",Math.round(Math.random()*128),-1.0,127.0,0x00dddd)
		b.x = 35 + 25 * i
		b.y = 100
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
		tb.y = 125
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
		tb.y = 150
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
		tb.y = 75
		addChild(tb)
		indicators.push(tb)
	    }


	    var dial2:DialButton = new DialButton("FRQ",0.2,0.0,0.5)
	    dial2.x = 60
	    dial2.y = 50
	    addChild(dial2)
	    dial2.onChange = function(value:Number):void {
		bassline.interpolateF.input[0] = value
	    }

	    var dial3:DialButton = new DialButton("Q",0.2,0.0,1.0)
	    dial3.x = 85
	    dial3.y = 50
	    addChild(dial3)
	    dial3.onChange = function(value:Number):void {
		bassline.interpolateQ.input[0] = value
	    }

	    var dial4:DialButton = new DialButton("Decay",0.888,0.0,1.0)
	    dial4.x = 110
	    dial4.y = 50
	    addChild(dial4)
	    dial4.onChange = function(value:Number):void {
		bassline.decay.decay[0] = 1.0 - Math.pow(1.0 - (0.5 + value /4),8)
	    }

	    var dialMod:DialButton = new DialButton("Mod",0.2,0.0,1.0)
	    dialMod.x = 135
	    dialMod.y = 50
	    addChild(dialMod)
	    dialMod.onChange = function(value:Number):void {
		bassline.envMod.inputC[0] = value
	    }	    

	    var dialAcc:DialButton = new DialButton("Acc",0.5,0.2,4.0)
	    dialAcc.x = 160
	    dialAcc.y = 50
	    addChild(dialAcc)
	    dialAcc.onChange = function(value:Number):void {
		bassline.accentStrength.inputC[0] = value
	    }

	    var dialVol:DialButton = new DialButton("Vol",0.5,0.0,1.0)
	    dialVol.x = 185
	    dialVol.y = 50
	    addChild(dialVol)
	    dialVol.onChange = function(value:Number):void {
		bassline.volume.inputC[0] = value
	    }


	    vumeter.x = 10
	    vumeter.y = 75
	    addChild(vumeter)

	    
	    var rbutton:ToggleButton = new ToggleButton("RAND",false,0x909090,0xf0f0f0)
	    knobs.pop()
	    rbutton.x = 210
	    rbutton.y = 50
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
