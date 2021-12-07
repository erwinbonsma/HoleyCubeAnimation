#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2()

#declare PartDstPosition = array[NumPartsL2];
#declare PartDstRotation = array[NumPartsL2];

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

		translate PositionForPart(I, 9)
	}

	#for (J, 0, NumParts - 1)
		#local PartIndex = I * NumParts + J;
		#local L1_Transform = transform {
			#ifdef (Part_L2_Twist[PartIndex])
				// Compensate for center shift of bulky parts
				#local T = Part_L2_Twist[PartIndex];
				translate -1.5 * <0, T, 1 - T>
			#end
			transform { RotationForPart(J) }
			translate PositionForPart(J, 3)
		}
		#local Combined = transform {
			transform { L1_Transform }
			transform { L2_Transform }
		}

		#declare PartDstPosition[PartIndex] = VectorTransform(<0, 0, 0>, Combined);
		#declare PartDstRotation[PartIndex] = transform {
			transform { Combined }
			translate -PartDstPosition[PartIndex]
		}
	#end
#end

//--------------------------------------
// Move to fully exploded layout

#declare MoveSpeed = 2;
#declare ClockStart = Now + 20;

#for (I, 0, NumParts - 1)
	#local Mapping = array[NumParts]
	#local Twisted = array[NumParts]

	#local PartIndexL2 = AssemblyOrderL2[I];

	InitPartsMapping(Mapping, Twisted)
	UpdateMappingForInversePartTransform(PartIndexL2, Mapping, Twisted)
	#ifdef (PartRotation_L2[PartIndexL2])
		RotatePartsMapping(Mapping, Twisted, PartRotation_L2[PartIndexL2])
	#end
	UpdateMappingForPartTransform(PartIndexL2, Mapping, Twisted)

	#debug concat(
		str(I, 0, 0), " ",
		str(PartIndexL2, 0, 0), " ",
		": ",
		MappingToString(Mapping),
		"\n"
	)

	#for (J, 0, NumParts - 1)
		#local PartIndex = Mapping[AssemblyOrderL1[J]] + PartIndexL2 * NumParts;

		#declare DeltaV = PartDstPosition[PartIndex] - PartPosition[PartIndex];
		#declare DeltaT = ClockTicksForMove(DeltaV);

		#declare Now = ClockStart + (I * NumParts + J) * 2 - DeltaT;
		#declare Now0 = Now;
		TimedMove(<PartIndex + 1, 0, 0>, DeltaV, DeltaT)
		#declare Now = Now0;
		TimedRotateToTransform(<PartIndex + 1, 0, 0>, PartDstRotation[PartIndex], DeltaT)
	#end
#end

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim02 end position
#declare CameraLookAt = <0, -6, 14>;
#declare CameraPosition = <-75.9, 49.5, -68.5>;

#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#include "Scene.inc"

//PuzzleL2()

#for (I, 0, NumPartsL2 - 1)
	object {
		Part_L2[I]
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end
