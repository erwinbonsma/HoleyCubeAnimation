#include "Globals.inc"
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
	#local PartsMapping = array[NumParts] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};

	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(PartsMapping, -PartRotation_L2[I])
	#end

	union {
		object {
			PuzzleL1()
// TODO: Reinstroduce
// - Equal connector distribution undone by this transform
// - Maximum veriation in L1 cube orientations per L2 cube face
//			transform {
//				RotationForPart(I)
//				inverse
//			}
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
						color PartColor[PartsMapping[
							AttachPointForL2Connector(I, J, H)
						]]
					}
				}
			#end
		#end

		transform { RotationForPart(I) }

		translate PositionForPart(I, 7)
	}
#end
