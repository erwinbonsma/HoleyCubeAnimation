#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

//#declare CameraPosition = <-23, 15, -25> * 1.2 * 1.3;
#declare CameraPosition = <-32, 20, -100>;
#declare CameraLookAt = <6, -6, 0>;


#include "Scene.inc"

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

#declare NumBulky = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare NumBulky[I] = 0;
#end

#for (I, 0, NumPartsL2 - 1)
	#local PartType = mod(I, NumParts);

	#declare PartRotation[I] = transform {
		#ifdef (Part_L2_Twist[I])
			rotate x * 90 * (Part_L2_Twist[I] - 1)
		#end
		rotate z * 90
	}
	#declare PartPosition[I] = <
		div(PartType, 4) * 5, mod(PartType, 4) * -4, div(I, NumParts) * 2
	>;
#end

PuzzleL2()