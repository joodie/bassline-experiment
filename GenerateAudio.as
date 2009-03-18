
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
	private var samples:Vector.<Number>;

	public function GenerateAudio() {
	    osc.output = buffer()
	    osc.frequency = buffer()
	    var button:CustomSimpleButton = new CustomSimpleButton()
	    addChild(button)
	    button.addEventListener(MouseEvent.MOUSE_DOWN, function():void { playing = true } )
	    button.addEventListener(MouseEvent.MOUSE_UP, function():void { playing = false })
	    sound.addEventListener(SampleDataEvent.SAMPLE_DATA,generateSound)

	    sound.play()
	}

	public function generateSound(event:flash.events.SampleDataEvent):void {
	    osc.frequency[0] = 440.0;
	    osc.run(2048);
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

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;


// shorthand to create new sample vectors
function buffer():Vector.<Number> {
    return new Vector.<Number>(4000,true)
}

class CustomSimpleButton extends SimpleButton {
    private var upColor:uint   = 0xFFCC00;
    private var overColor:uint = 0xCCFF00;
    private var downColor:uint = 0x00CCFF;
    private var size:uint      = 80;

    public function CustomSimpleButton() {
        downState      = new ButtonDisplayState(downColor, size);
        overState      = new ButtonDisplayState(overColor, size);
        upState        = new ButtonDisplayState(upColor, size);
        hitTestState   = new ButtonDisplayState(upColor, size * 2);
        hitTestState.x = -(size / 4);
        hitTestState.y = hitTestState.x;
        useHandCursor  = true;
    }
}

class ButtonDisplayState extends Shape {
    private var bgColor:uint;
    private var size:uint;

    public function ButtonDisplayState(bgColor:uint, size:uint) {
        this.bgColor = bgColor;
        this.size    = size;
        draw();
    }

    private function draw():void {
        graphics.beginFill(bgColor);
        graphics.drawRect(0, 0, size, size);
        graphics.endFill();
    }
}

class Oscillator {
    public var output:Vector.<Number>;
    public var frequency:Vector.<Number>;
    private var phase:Number = 0.0;

    public function run(frames:uint):void {
	var phaseStep:Number = this.frequency[0] / 22050.0;phaseStep;
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

