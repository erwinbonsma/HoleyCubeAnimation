/* Holey Puzzle POV-Ray Animation
 *
 * Scene 7: Reveal Level 3
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "PartsL3.inc"
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

//--------------------------------------
// Animate camera (throughout animation)

// Match Scene 6 camera end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-51, 11, 22>;
#declare CameraLookAtEnd = <-D3, 0, -D3>;
#declare CameraPositionEnd = <-185, 40, 80>;

#local CameraT0 = 0;
#local CameraT1 = 30;
#declare CameraLookAt = LerpVector(
	CameraLookAt, CameraLookAtEnd, f_sramp(CameraT0, CameraT1, clock)
);
#declare CameraPosition = LerpVector(
	CameraPosition, CameraPositionEnd, f_sramp(CameraT0, CameraT1, clock)
);

#declare DetailAreaLightActivation = 1;

#local CreditsT0 = 30;
#local CreditsT1 = 35;
#declare Brightness = 1 - 0.6 * f_sramp(CreditsT0, CreditsT1, clock);

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (N, 0, NumParts - 1)
	union {
		object { CompoundPuzzle_L2 }

		#for (I, 0, 1)
			object {
				PartConnector_L3[N][I]

				translate x * (-1 + 2 * I) * D3
			}
		#end

		pigment { color rgb PartColor[N] }

		transform { RotationForPart(N) }
		translate PositionForPart(N, D3)
		translate <-D3, 0, -D3>
	}
#end

//--------------------------------------
// Credits

#local CreditsT0 = 30;
#local CreditsT1 = 35;

#macro CenterText(Text, Y, Size)
	#local TextObject = text {
		ttf "GillSans.ttc" Text
		0.0001, 0

		scale Size
		hollow
	}
	#local Min = min_extent(TextObject);
	#local Max = max_extent(TextObject);

	object {
		TextObject

		no_shadow
		texture {
			pigment {
				color rgbt <0.9, 0.9, 0.9, 1 - f_sramp(CreditsT0, CreditsT1, clock)>
			}
			finish {
				diffuse 0
				ambient 1
			}
		}

		translate <(Min.x - Max.x) / 2, Y, -40>
	}
#end

#if (clock > CreditsT0)
	union {
		CenterText("Puzzle", 17, 6)
		CenterText("\"Twelve Straight/Twisted\"", 13, 4)
		CenterText("by Yukio Hirose", 9, 4)

		CenterText("Music", 1, 6)
		CenterText("\"Armageddon\"", -3, 4)
		CenterText("by Synapsis", -7, 4)

		CenterText("Animation", -15, 6)
		CenterText("by Erwin Bonsma", -19, 4)

		#local D = sqrt(
			CameraPositionEnd.x * CameraPositionEnd.x +
			CameraPositionEnd.z * CameraPositionEnd.z
		);
		#local Alpha = degrees(atan2(CameraPositionEnd.y, D));
		#local Beta = degrees(atan2(CameraPositionEnd.x, CameraPositionEnd.z));
		rotate <Alpha, 60, 0>

		translate <-D3, 0, -D3>
	}
#end

