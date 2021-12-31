/* Holey Puzzle POV-Ray Animation
 *
 * Scene 6: Show off assembled L2 puzzle
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..30
// Frames: 0..720

//--------------------------------------
// Coordinate to beat of sound track

// End clock ticks of previous animation, where beat started
#declare BeatTimeOffset = 180 + 35 + 27;
#include "Beat.inc"

#local AmpD = 0.5;
#local BeatAmp = 2;
#local BeatT0 = 2;
#local BeatT1 = 29.5;

#declare f_beatmul_L2 = function(time) {
	f_beatmul(
		f_beat(time),
		0.05 * (
			f_sramp(BeatT0 - AmpD, BeatT0 + AmpD, time) -
			f_sramp(BeatT1 - AmpD, BeatT1 + AmpD, time)
		)
	)
}

//--------------------------------------
// Create L2 puzzle

#local D2 = 3;

DefineCompoundParts_L2()

#declare CompoundPuzzle_L2 = union {
	#for (I, 0, NumParts - 1)
		object {
			CompoundPart_L2[I]

			transform { RotationForL2Part(I) }
			translate PositionForPart(I, D2)
		}
	#end
}

//--------------------------------------
// Rotate puzzle

#declare Rot1Start = 3;
#declare Rot1End = 27;
#declare Rot2Start = 15;
#declare Rot2End = 27;

#declare PuzzleTransform = transform {
	rotate x * 360 * f_sramp(Rot2Start, Rot2End, clock)
	rotate y * 360 * f_sramp(Rot1Start, Rot1End, clock)

	scale f_beatmul_L2(clock)
}

//--------------------------------------
// Place camera

// Match Scene 5 camera end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75> * 0.45;

#include "Scene.inc"

//--------------------------------------
// Place objects

object {
	CompoundPuzzle_L2
	transform { PuzzleTransform }
}
