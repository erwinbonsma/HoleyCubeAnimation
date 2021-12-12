#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

//--------------------------------------
// Planning parameters

// The minimum clock ticks between two parts arriving for a given L2 part
#declare MinArrivalDelay = 2;

// The minimum clock ticks between two parts departing from a given L1 stack
#declare MinDepartureDelay = 2;

#declare MoveSpeed = 2;

#declare PathsFilename = "Anim03_Paths.csv";

//--------------------------------------
// Planning ioputs

#declare PartSrcPosition = array[NumPartsL2];
#declare PartSrcRotation = array[NumPartsL2];

InitStartingPlacementL2(PartSrcPosition, PartSrcRotation)

// Let all parts depart from the top of their stack3
#local Z0 = PartSrcPosition[0].z;
#for (I, 0, NumPartsL2 - 1)
	#declare PartSrcPosition[I] = <PartSrcPosition[I].x, PartSrcPosition[I].y, Z0>;
#end

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
	#write (PATHS_FILE, concat(
		str(PartIndex, 0, 0), ",", str(Departure, 0, 5), "\n"
	))
#end

#macro WritePathFile()
	#fopen PATHS_FILE PathsFilename write

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

					#local DeltaV = PartDstPosition[PartIndex] - PartSrcPosition[PartIndex];
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
#end

#macro ReadPathFile()
	#local NumLines = 0;

	#if (file_exists(PathsFilename))
		#fopen PATHS_FILE PathsFilename read

		#while (defined(PATHS_FILE))
			#read (PATHS_FILE,PartIndex,DepTime)

			#ifdef (DepartureTime[PartIndex])
				#warning concat("Duplicate entry for Part ", str(PartIndex, 0, 0), "\n")
			#else
				#declare DepartureTime[PartIndex] = DepTime;
			#end

			#local NumLines = NumLines + 1;
		#end
	#end

	(NumLines)
#end

#if (ReadPathFile() = NumPartsL2)
	#debug "Cached paths read from file\n"
#else
	#debug "Generating paths...\n"
	WritePathFile()
#end

//--------------------------------------
// Move to fully exploded layout

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2(PartPosition, PartRotation)

#for (I, 0, NumParts - 1)
	#declare NumDeparted[I] = 0;
#end

#local FirstDeparture = 0;

#for (I, 0, NumPartsL2 - 1)
	#if (DepartureTime[I] < FirstDeparture)
		#local FirstDeparture = DepartureTime[I];
	#end
#end

#local MoveStart = floor(FirstDeparture);

#for (I, 0, NumPartsL2 - 1)
	#declare DeltaV = PartDstPosition[I] - PartPosition[I];
	#declare DeltaT = ClockTicksForMove(DeltaV);

	#declare Now = DepartureTime[I] - MoveStart;
	#declare Now0 = Now;
	TimedMove(<I + 1, 0, 0>, DeltaV, DeltaT)
	#declare Now = Now0;
	TimedRotateToTransform(<I + 1, 0, 0>, PartDstRotation[I], DeltaT)
#end

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim02 end position
#declare CameraLookAt = <0, -6, 14>;
#declare CameraPosition = <-75.9, 49.5, -68.5>;

#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (I, 0, NumPartsL2 - 1)
	object {
		Part_L2[I]
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end
