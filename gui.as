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


function drawRoundedRectangle(graphics:flash.display.Graphics,color:uint,alpha:Number,x1:Number,y1:Number,x2:Number,y2:Number,rounded:Number = 2.0):void {
    with (graphics) {
	lineStyle(1,0)
	beginFill(color,alpha)
	moveTo(x1+rounded,y1)
	lineTo(x2-rounded,y1)
	curveTo(x2,y1,x2,x1+rounded)
	lineTo(x2,y2-rounded)
	curveTo(x2,y2,x2-rounded,y2)
	lineTo(x1+rounded,y2)
	curveTo(x1,y2,x1,y2-rounded)
	lineTo(x1,y1+rounded)
	curveTo(x1,y1,x1+rounded,y1)
	endFill()
    }
}

function drawLabel(sprite:Sprite, text:String, color:uint=0xffffff,bgcolor:uint=0xd0d0d0, bgalpha:Number=0.5):void {
    drawRoundedRectangle(sprite.graphics, bgcolor, bgalpha,0,0,20,20)
    var label:TextField = new TextField()
    label.selectable = false
    label.defaultTextFormat = buttonTextFormat
    label.width = 1
    label.autoSize = TextFieldAutoSize.LEFT
    label.text = text
    label.y = 10
    sprite.addChild(label)
    label.x = (20.0 - label.textWidth) / 2.0 - 1.7
}


class ToggleButton extends Sprite {
    public var onState:Shape
    public var offState:Shape
    public var onOff:Function
    public var onOn:Function
    private var state:Boolean

    public function ToggleButton(text:String,startState:Boolean,upcolor:uint,downcolor:uint,bgcolor:uint = 0xd0d0d0,bgalpha:Number=0.5) {
	buttonMode = true
        useHandCursor  = true
	drawLabel(this, text, 0xffffff,bgcolor, bgalpha)

	onState = createShape(10,0, downcolor)
	offState = createShape(10,0, upcolor)
	onState.y = offState.y = 2
	onState.x = offState.x = 5

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

    public function DialButton(text:String,startValue:Number,min:Number,max:Number,color:uint=0xd0d0d0) {
	this.min = min
	this.max = max
	buttonMode = false
	value = startValue

	drawLabel(this, text)
	
	// shape is the dialing part of the graphics:
	// the value is indicated by rotating shape
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
	shape.x = 10
	shape.y = 7
	updateDisplay()
	addChild(shape)


	var y:Number = 0.0
	function drag(event:MouseEvent):void {
	    var delta:Number = ((event.stageY - y) * (max - min)) / 100
	    
	    value = Math.min(max,Math.max(min,value - delta))
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