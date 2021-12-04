#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare CameraPosition = <-23, 15, -25> * 1.2 * 1.3;

#include "Scene.inc"

//#for (I, 0, NumParts - 1)
//	union {
//		#for (J, 0, NumParts - 1)
//			object {
//				Part_L2[I * NumParts + J]
//
//				transform { RotationForPart(J) }
//				translate PositionForPart(J, 1)
//			}
//		#end
//
//		// Undo the normal rotation to place the L2 part correctly. This way all L1 cubes
//		// will in principle be oriented the same in the assembled puzzle. This (together
//		// with PartRotation_LW) ensures that 1) an equal number L1 parts of each type
//		// (four) have a big L2 connector attached to it. (Otherwise only a subset of
//		// parts would have connectors attached.)
//		transform { RotationForPart(I) inverse }
//
//		// Rotate L1 cube such that 1) holds (see above) and that 2) all L1 cubes
//		// within an L2 cube face are nevertheless oriented differently.
//		#ifdef (PartRotation_L2[I])
//			rotate PartRotation_L2[I]
//		#end
//
//		// Rotate L2 part so that they all assemble into an L2 cube.
//		//
//		// Note: the placement of the L2 connectors to the L1 parts is aware of and takes
//		// into account the above transforms so that this assembly works.
//		transform { RotationForPart(I) }
//
//		translate PositionForPart(I, 9)
//	}
//#end


#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

#for (I, 0, NumParts - 1)
	#local L2_Transform = transform {
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

		translate PositionForPart(I, 3)
	}

	#for (J, 0, NumParts - 1)
		#local PartIndex = I * NumParts + J;
		#local L1_Transform = transform {
			transform { RotationForPart(J) }
			translate PositionForPart(J, 1)
		}
		#local Combined = transform {
			transform { L1_Transform }
			transform { L2_Transform }
		}

		#declare PartPosition[PartIndex] = VectorTransform(<0, 0, 0>, Combined);
		#declare PartRotation[PartIndex] = transform {
			transform { Combined }
			translate -PartPosition[PartIndex]
		}
	#end
#end

PuzzleL2()
