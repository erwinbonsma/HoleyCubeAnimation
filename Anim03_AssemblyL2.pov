#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2(PartPosition, PartRotation)

#declare PartDstPosition = array[NumPartsL2];
#declare PartDstRotation = array[NumPartsL2];

InitAssemblyPlacementL2(PartDstPosition, PartDstRotation, 3, 9)

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
