#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

//--------------------------------------
// Planning parameters

// The minimum clock ticks between two parts arriving for a given L2 part
#declare MinArrivalDelay = 2;

#declare MinDepartureDelay = 2;

//--------------------------------------
// Planning ioputs

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2(PartPosition, PartRotation)

#declare PartDstPosition = array[NumPartsL2];
#declare PartDstRotation = array[NumPartsL2];

InitAssemblyPlacementL2(PartDstPosition, PartDstRotation, 3, 9)

//--------------------------------------
// Planning state

#declare ArrivalTime = array[NumPartsL2];
#declare DepartureTime = array[NumPartsL2];

#declare NumArrived = array[NumParts]; // Index is L2 part type
#declare NumDeparted = array[NumParts]; // Index is L1 part type
#declare LastArrival = array[NumParts]; // Index is L2 part type
#declare LastDeparture = array[NumParts]; // Index is L1 part type

#for (I, 0, NumParts - 1)
	#declare NumArrived[I] = 0;
	#declare NumDeparted[I] = 0;

	#declare LastArrival[I] = -1000;
	#declare LastDeparture[I] = -1000;
#end


//--------------------------------------
// Create the mappings for each part

#declare Mapping = array[NumParts][NumParts]

#for (I, 0, NumParts - 1)
	#local TmpTwisted = array[NumParts]
	#local TmpMapping = array[NumParts];

	InitPartsMapping(TmpMapping, TmpTwisted)
	UpdateMappingForInversePartTransform(I, TmpMapping, TmpTwisted)
	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(TmpMapping, TmpTwisted, PartRotation_L2[I])
	#end
	UpdateMappingForPartTransform(I, TmpMapping, TmpTwisted)

	#for (J, 0, NumParts - 1)
		#declare Mapping[I][J] = TmpMapping[J];
	#end
#end

//--------------------------------------
// Plan the paths

#macro PlanMove(PartTypeL2, PartTypeL1, Departure, I, J)
	#local PartIndex = PartTypeL2 * NumParts + PartTypeL1;

	// Plan this part
	#declare NumArrived[PartTypeL2] = NumArrived[PartTypeL2] + 1;
	#declare LastArrival[PartTypeL2] = Now;
	#declare ArrivalTime[PartIndex] = Now;

	#declare NumDeparted[PartTypeL1] = NumDeparted[PartTypeL1] + 1;
	#declare LastDeparture[PartTypeL1] = Departure;
	#declare DepartureTime[PartIndex] = Departure;

	#declare NumPathsTotal = NumPathsTotal + 1;

	#debug concat(
		"Arrival = ", str(Now, 0, 0),
		", I/Type = ", str(I, 2, 0), "/", str(PartTypeL2, 2, 0),
		", J/Type = ", str(J, 2, 0), "/", str(PartTypeL1, 1, 0),
		", Departure = ", str(Departure, 0, 3),
		", Total = ", str(NumPathsTotal, 0, 0),
		"\n"
	)
#end

#declare Now = 0;
#declare NumPathsTotal = 0;

#while (NumPathsTotal < NumPartsL2)

	// Consider four L2 parts
	#local LayerL2 = div(NumPathsTotal, NumParts * 4);
	#for (I, LayerL2 * 4, LayerL2 * 4 + 3)
		#local PartTypeL2 = AssemblyOrderL2[I];

		#if (NumArrived[PartTypeL2] < NumParts)
			// Some L1 parts still need to be planned for this L2 part.

			// Consider four L1 parts
			#local LayerL1 = div(NumArrived[PartTypeL2], 4);

			#for (J, LayerL1 * 4, LayerL1 * 4 + 3)
				#local PartTypeL1 = Mapping[PartTypeL2][AssemblyOrderL1[J]];
				#local PartIndex = PartTypeL2 * NumParts + PartTypeL1;

				#local DeltaV = PartDstPosition[PartIndex] - PartPosition[PartIndex];
				#local DeltaT = ClockTicksForMove(DeltaV);
				#local Departure = Now - DeltaT;

				#if (
					LastArrival[PartTypeL2] <= Now - MinArrivalDelay &
					NumDeparted[PartTypeL1] = I &
					LastDeparture[PartTypeL1] <= Departure - MinDepartureDelay
				)
					// Found a part that can move

					// TODO: Check if it collides with any paths

					PlanMove(PartTypeL2, PartTypeL1, Departure, I, J)
					#break
				#end
			#end
		#end
	#end

	#declare Now = Now + 1;
	#if (Now > 500)
		#break
	#end
#end
