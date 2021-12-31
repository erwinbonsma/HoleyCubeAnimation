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

// Clock: 0..30
// Frames: 0..720

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

#declare Connector_L3 = union {
	box { <-1.5, -0.5, -0.5>, <1.5, 0.5, 0.5> }
	box { <-0.5, -1.5, -0.5>, <0.5, 1.5, 0.5> }
	box { <-0.5, -0.5, -1.5>, <0.5, 0.5, 1.5> }
}

//--------------------------------------
// Animate camera (throughout animation)

// Match Scene 6 camera end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-51, 11, 22>;

#local CameraT0 = 0;
#local CameraT1 = 30;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <-D3, 0, -D3>, f_sramp(CameraT0, CameraT1, clock)
);
#declare CameraPosition = LerpVector(
	CameraPosition, <-185, 40, 80>, f_sramp(CameraT0, CameraT1, clock)
);

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (N, 0, NumParts - 1)
	union {
		object { CompoundPuzzle_L2 }

		#for (I, 0, 1)
			union {
				object {
					Connector[mod(PartConnector[N][I], 3)]
					scale 9
				}

				union {
					object {
						Connector_L3
						translate <6 * (1 - 2 * I), 0, 3>
					}
					object {
						Connector_L3
						translate <6 * (1 - 2 * I), 0, -3>
					}
				}

				rotate x * 90 * div(PartConnector[N][I], 3)
				translate x * (-1 + 2 * I) * D3
			}
		#end
		pigment { color rgb PartColor[N] }

		transform { RotationForPart(N) }
		translate PositionForPart(N, D3)
		translate <-D3, 0, -D3>
	}
#end

