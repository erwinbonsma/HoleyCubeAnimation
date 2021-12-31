/* Holey Puzzle POV-Ray Animation
 *
 * Scene 7: Reveal Level 3
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..??
// Frames: 0..???

#local D2 = 3;
#local D3 = 21;

//--------------------------------------
// Create L2 puzzle

DefineCompoundParts_L2()

#declare CompoundPuzzle_L2 = union {
	#for (I, 0, NumParts - 1)
		object {
			CompoundPart_L2[I]

			transform { RotationForL2Part(I) }
			translate PositionForPart(I, D2)
		}
	#end

	// Let orientation of zoomed in part match that from previous scene
	rotate <90, 90, 0>
}

//--------------------------------------
// Animate camera (throughout animation)

// Match Scene 5 camera end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-230, 50, 100> * 0.2;

#local CameraT0 = 0;
#local CameraT1 = 30;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <-D3, 0, -D3>, f_ramp(CameraT0, CameraT1, clock)
);
//#declare CameraPosition = LerpVector(
//	CameraPosition, <-83 * 1.2, 54 * 0.3, -75 / 1.2> * 2.2, f_ramp(CameraT0, CameraT1, clock)
//);
#declare CameraPosition = LerpVector(
	CameraPosition, <-230, 50, 100> * 0.8, f_ramp(CameraT0, CameraT1, clock)
);

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (I, 0, NumParts - 1)
	object {
		CompoundPuzzle_L2

		transform { RotationForPart(I) }
		translate PositionForPart(I, D3)
		translate <-D3, 0, -D3>
	}
#end

#for (X, 0, 1)
	#for (Y, 0, 1)
		#for (Z, 0, 1)
			box {
				<-1, -1, -1>, <1, 1, 1>
				scale 4.5

				translate <1 - 2*X, 1 - 2*Y, 1 - 2*Z> * D3
				translate <-D3, 0, -D3>

				pigment { color White }
			}
		#end
	#end
#end
