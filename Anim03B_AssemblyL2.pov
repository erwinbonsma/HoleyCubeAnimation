#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2()

// Match Anim02 end position
#declare CameraLookAt = <0, -6, 14>;
#declare CameraPosition = <-75.9, 49.5, -68.5>;

#include "Scene.inc"

#for (I, 0, NumParts - 1)
	#for (J, 0, NumParts - 1)
	#end
#end

#for (I, 0, NumPartsL2 - 1)
	object {
		Part_L2[I]
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end

