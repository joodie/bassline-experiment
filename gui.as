import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.display.SimpleButton;
import flash.events.*

var buttonTextFormat:TextFormat = new TextFormat()
buttonTextFormat.font = "Verdana"
buttonTextFormat.color = 0xffffff
buttonTextFormat.size = 5
buttonTextFormat.bold = true

class ToggleButton extends Sprite {
    public var onState:Shape
    public var offState:Shape
    public var onOff:Function
    public var onOn:Function
    private var state:Boolean

    public function ToggleButton(text:String,startState:Boolean,upcolor:uint,downcolor:uint,bgcolor:uint = 0xd0d0d0,bgalpha:Number=0.5) {
	buttonMode = true
        useHandCursor  = true

	if (bgalpha > 0.0) {
	    with (graphics) {
		beginFill(bgcolor,bgalpha)
		moveTo(2,0)
		lineTo(18,0)
		curveTo(20,0,20,2)
		lineTo(20,18)
		curveTo(20,20,18,20)
		lineTo(2,20)
		curveTo(0,20,0,18)
		lineTo(0,2)
		curveTo(0,0,2,0)
		endFill()
	    }
	}

	onState = createShape(10,0, downcolor)
	offState = createShape(10,0, upcolor)
	onState.y = offState.y = 2
	onState.x = offState.x = 5
	var label:TextField = new TextField()
	label.selectable = false
	label.defaultTextFormat = buttonTextFormat
	label.width = 20
	label.autoSize = TextFieldAutoSize.CENTER
	label.text = text
	label.y = 10
	label.x = 1.5
	addChild(label)
	state = startState



	addEventListener(MouseEvent.CLICK, function():void { 
		state = !state
		updateState()
		if (state && onOn != null) onOn()
		if (!state && onOff != null) onOff()
	    })

	updateState()
	addChild(onState)
	addChild(offState)
	
    }

    private function updateState():void {
	if (state) {
	    onState.visible=true
	    offState.visible=false
	}
	else {
	    onState.visible=false
	    offState.visible=true
	}
    }

    private function createShape(size:Number,edgeColor:uint,fillColor:uint):Shape {
	var sp:Shape = new Shape()
	with (sp.graphics) {
	    beginFill(fillColor)
	    drawCircle(size/2,size/2,size/2)
	    endFill()
	    lineStyle(size/10,edgeColor)
	    drawCircle(size/2,size/2,size/2)
	    lineStyle(undefined)
	    beginFill(0,0.3)
	    drawCircle(size/2,size/2,size/3)
	    endFill()
	    lineStyle(size/10,0xffffe0,0.3)
	    moveTo(size*.80,size*.5)
	    curveTo(size*.80,size*.80,size*.5,size*.80)
	}
	return sp
    }
}

class DialButton extends Sprite {
    public var shape:Shape = new Shape()
    public var onChange:Function
    private var value:Number
    private var min:Number
    private var max:Number
    private var color:uint

    public function DialButton(startValue:Number,min:Number,max:Number,color:uint) {
	this.min = min
	this.max = max
	buttonMode = false
	value = startValue
	with (shape.graphics) {
	    clear()
	    rotation = 0
	    lineStyle(1,0)
	    beginFill(color)
	    drawCircle(0,0,5)
	    endFill()
	    moveTo(0,-5)
	    lineTo(0,-1)
	}
	shape.x = 5
	shape.y = 5
	updateDisplay()
	addChild(shape)


	var y:int = 0
	var drag:Function = function (event:MouseEvent):void {
	    value = Math.min(max,Math.max(min,min + ((y - event.stageY) * (max - min) / 50)))
	    if (onChange != null) onChange(value)
	    updateDisplay()
	}



	function upevent(event:MouseEvent):void { 
	    root.removeEventListener(MouseEvent.MOUSE_MOVE,drag)
	    root.removeEventListener(MouseEvent.MOUSE_UP,upevent)
	}


	addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void { 
		y = event.stageY
		root.addEventListener(MouseEvent.MOUSE_MOVE,drag)
		root.addEventListener(MouseEvent.MOUSE_UP, upevent)
	    })

    }

    private function updateDisplay():void {
	shape.rotation = (value-min)* (320/(max - min)) - 160
    }
}