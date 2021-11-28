#include "Scene.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare CameraPosition = <-23, 15, -25> * 1.2;

#include "Scene.inc"

#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = PositionForPart(I, 3);	#declare PartRotation[I] = RotationForPart(I);
#end

ShowPuzzleL1()

