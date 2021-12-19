#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"

#local D2 = 9;

//--------------------------------------
// Define L2 compound parts

#declare CompoundPart = array[NumParts];
#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];

#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = PositionForPart(I, D2);
	#declare PartRotation[I] = RotationForL2Part(I);

	#declare CompoundPart[I] = union {
		#for (J, 0, NumParts - 1)
			#local PartIndex = I * NumParts + J;
			object {
				Part_L2[PartIndex]

				TransformForL1PartInL2Part(I, J, 1)
			}
		#end
	}
#end

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim04 end position

#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (I, 0, NumParts - 1)
	object {
		CompoundPart[I]

		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end