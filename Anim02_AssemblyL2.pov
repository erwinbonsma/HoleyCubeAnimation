#include "Globals.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare CameraPosition = <-23, 15, -25> * 1.2 * 2.5;

#include "Scene.inc"

#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = PositionForPart(I, 1);	#declare PartRotation[I] = RotationForPart(I);
#end

#local InvPartRotations = array[3] {
	<0, 0, 0>, <-90, -90, 0>, <90, 0, 90>
}

#for (I, 0, NumParts - 1)
	#local PartsMapping = array[NumParts] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
	#local InvPartRotation = InvPartRotations[div(I, 4)];

	RotatePartsMapping(PartsMapping, InvPartRotation)
	RotatePartsMapping(PartsMapping, -x * XRotationForPart(I))

	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(PartsMapping, PartRotation_L2[I])
	#end

	union {
		object {
			PuzzleL1()

			rotate InvPartRotation
			rotate -x * XRotationForPart(I)
			#ifdef (PartRotation_L2[I])
				transform {
					rotate PartRotation_L2[I]
				}
			#end
		}

		#for (J, 0, 1)
			#for (H, 0, 1)
				difference {
					object {
						Connector[mod(PartConnector[I][J], 3)]
					}
					plane {
						z * (-1 + H * 2), 0
					}

					rotate x * 90 * div(PartConnector[I][J], 3)
					translate x * (-1 + 2 * J)
					scale 3

					pigment {
						color PartColor[
							PartAtPosition(
								PartsMapping,
								AttachPointForL2Connector(I, J, H)
							)
						]
					}
				}
			#end
		#end

		transform { RotationForPart(I) }

		translate PositionForPart(I, 9)
	}
#end
