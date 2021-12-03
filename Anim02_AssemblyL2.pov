#include "Globals.inc"
#include "PartsL2.inc"
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

#for (I, 0, -11)
	#local PartsMapping = array[NumParts] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
	#local Twisted = array[NumParts] {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	#local InvPartRotation = InvPartRotations[div(I, 4)];

	RotatePartsMapping(PartsMapping, Twisted, InvPartRotation)
	RotatePartsMapping(PartsMapping, Twisted, -x * XRotationForPart(I))

	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(PartsMapping, Twisted, PartRotation_L2[I])
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

					rotate x * 90 * (div(PartConnector[I][J], 3) + J * 2)
					translate x * (-1 + 2 * J)
					scale 3

					pigment {
						color PartColor[
							PartsMapping[AttachPointForL2Connector(I, J, H)]
						]
					}
				}
			#end
		#end

		transform { RotationForPart(I) }

		translate PositionForPart(I, 9)
	}
#end

#for (I, 0, NumParts - 1)
	union {
		#for (J, 0, NumParts - 1)
			object {
				Part_L2[I * NumParts + J]

				transform { RotationForPart(J) }
				translate PositionForPart(J, 1)
			}
		#end

		// Undo the normal rotation to place the L2 part correctly. This way all L1 cubes
		// will in principle be oriented the same in the assembled puzzle. This (together
		// with PartRotation_LW) ensures that 1) an equal number L1 parts of each type
		// (four) have a big L2 connector attached to it. (Otherwise only a subset of
		// parts would have connectors attached.)
		transform { RotationForPart(I) inverse }

		// Rotate L1 cube such that 1) holds (see above) and that 2) all L1 cubes
		// within an L2 cube face are nevertheless oriented differently.
		#ifdef (PartRotation_L2[I])
			rotate PartRotation_L2[I]
		#end

		// Rotate L2 part so that they all assemble into an L2 cube.
		//
		// Note: the placement of the L2 connectors to the L1 parts is aware of and takes
		// into account the above transforms so that this assembly works.
		transform { RotationForPart(I) }

		translate PositionForPart(I, 9)
	}
#end
