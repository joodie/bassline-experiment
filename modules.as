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
    public var note4:Vector.<Number> = buffer()
    public var note5:Vector.<Number> = buffer()
    public var note6:Vector.<Number> = buffer()
    public var note7:Vector.<Number> = buffer()
    public var note8:Vector.<Number> = buffer()
    public var note9:Vector.<Number> = buffer()
    public var note10:Vector.<Number> = buffer()
    public var note11:Vector.<Number> = buffer()
    public var note12:Vector.<Number> = buffer()
    public var note13:Vector.<Number> = buffer()
    public var note14:Vector.<Number> = buffer()
    public var note15:Vector.<Number> = buffer()

    public var triggerOut:Vector.<Number> = buffer()
    public var step:uint = 0;
    private var trigHigh:Boolean = true
    private var lastNote:Number = 0.0
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    if (trigger[i] > 0.5) {
		if (!trigHigh) {
		    if (++step > 15) step -= 16
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
		case 4: 
		  this.output[i] = this.note4[0]
		break
		case 5: 
		  this.output[i] = this.note5[0]
		break
		case 6: 
		  this.output[i] = this.note6[0]
		break
		case 7: 
		  this.output[i] = this.note7[0]
		break
		case 8: 
		  this.output[i] = this.note8[0]
		break
		case 9: 
		  this.output[i] = this.note9[0]
		break
		case 10: 
		  this.output[i] = this.note10[0]
		break
		case 11: 
		  this.output[i] = this.note11[0]
		break
		case 12: 
		  this.output[i] = this.note12[0]
		break
		case 13: 
		  this.output[i] = this.note13[0]
		break
		case 14: 
		  this.output[i] = this.note14[0]
		break
		case 15: 
		  this.output[i] = this.note15[0]
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
	for (var i:uint = 0; i < frames; i++) {
	    var f:Number =  Math.min(0.5,frequency[i])
	    var qq:Number = Math.min(0.95,q[i])
	    var fb:Number = qq + qq / (1.0 - f)
	    buf0 = buf0 + f * (input[i] - buf0 + fb * (buf0 - buf1))
	    output[i] = buf1 = buf1 + f * (buf0 - buf1)
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

class InterpolateAA {
    public var input:Vector.<Number> = buffer()
    public var output:Vector.<Number> = buffer()
    public var onoff:Vector.<Number> = buffer()
    public var frequency:Vector.<Number> = buffer()
    private var buffer:Number = 0.0
    public function run(frames:uint):void {
	for (var i:uint = 0; i < frames; i++) {
	    if (onoff[i] > 0.5) {
		var diff:Number = input[i] - buffer
		buffer = output[i] = buffer + diff * 20 * frequency[0] / SAMPLE_RATE
	    }
	    else {
		buffer = output[i] = input[i]
	    }
	}
    }    
}

class Bassline {
    public var osc:Oscillator = new Oscillator()
    public var seq:Sequencer = new Sequencer()
    public var accent:Sequencer = new Sequencer()
    public var accentDecay:Decay = new Decay()
    public var accentAmp:MultiplyAA = new MultiplyAA()
    public var accentStrength:MultiplyCA = new MultiplyCA()
    public var glider:InterpolateAA = new InterpolateAA()
    public var accentAdd:AddAA = new AddAA()
    public var slide:Sequencer = new Sequencer()

    public var decay:Decay = new Decay()
    public var filter:SimpleResonantFilter = new SimpleResonantFilter()
    public var interpolateF:Interpolate = new Interpolate()
    public var interpolateQ:Interpolate = new Interpolate()
    public var amp:MultiplyAA = new MultiplyAA()
    public var envMod:MultiplyCA = new MultiplyCA()
    public var envModAdd:AddAA = new AddAA()
    public var volume:MultiplyCA = new MultiplyCA()
    public function Bassline() {
	filter.input = osc.output
	filter.q = interpolateQ.output
	decay.trigger = seq.triggerOut
	glider.input = seq.output
	slide.trigger = clock.output
	glider.onoff = slide.output
	osc.frequency = glider.output

	seq.trigger = clock.output
	
	accent.trigger = clock.output
	accentAmp.input1 = accent.output
	accentAmp.input2 = clock.output
	accentDecay.trigger = accentAmp.output
	accentDecay.decay[0] = 0.999
	accentStrength.inputA = accentDecay.output
	
	envMod.inputA = accentStrength.output
	envModAdd.input1 = envMod.output
	envModAdd.input2 = interpolateF.output
	filter.frequency = envModAdd.output
	
	accentAdd.input1 = accentStrength.output
	accentAdd.input2 = decay.output
	amp.input1 = accentAdd.output
	amp.input2 = filter.output
	
	volume.inputA = amp.output
    }
    public function run(frames:uint):void {
	// order is important here, as always

	// sequencer parts first
	seq.run(frames)
	slide.run(frames)
	accent.run(frames)

	// glider/oscillator
	glider.run(frames)
	osc.run(frames)

	// decay & accent (both used in envmod)
	decay.run(frames)
	accentAmp.run(frames)
	accentDecay.run(frames)
	accentStrength.run(frames)
	accentAdd.run(frames)

	// envmod
	envMod.run(frames)
	envModAdd.run(frames)

	// lowpass filter
	interpolateF.run(frames)
	interpolateQ.run(frames)
	filter.run(frames)

	// amplitude / volume
	amp.run(frames)
	volume.run(frames)
    }
}


class Drums {
    
}
