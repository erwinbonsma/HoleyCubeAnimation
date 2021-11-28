#include "Scene.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare CameraPosition = <-23, 15, -25> * 1.2 * 2;

#include "Scene.inc"

#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = PositionForPart(I, 1);	#declare PartRotation[I] = RotationForPart(I);
#end

#for (I, 0, NumParts - 1)
	union {
		union {
			ShowPuzzleL1()
			transform {
				RotationForPart(I)
				inverse
			}
			#ifdef (PartRotation_L2[I])
				transform {
					rotate PartRotation_L2[I]
				}
			#end
		}

		union {
			#for (J, 0, 1)
				object {
					Connector[mod(PartConnector[I][J], 3)]
					rotate x * 90 * div(PartConnector[I][J], 3)
					translate x * (-1 + 2 * J)
				}
			#end
			pigment { color PartColor[I] }

			scale 3
		}

		transform { RotationForPart(I) }

		translate PositionForPart(I, 7)
	}
#end
