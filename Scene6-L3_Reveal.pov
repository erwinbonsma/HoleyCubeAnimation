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

// Match Anim05 end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75> * 0.45;

#declare CameraLookAt_End = <-D3, 0, -D3>;
#declare CameraPosition_End = <-83, 54, -75> * 2.2;

#local Now0 = Now;
MoveVector(CameraPosition, CameraPosition_End, 30)
#declare Now = Now0;
MoveVector(CameraLookAt, CameraLookAt_End, 30)

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
