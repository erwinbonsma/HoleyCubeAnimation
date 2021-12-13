#include "PathCrossing.inc"

//--------------------------------------
// Planning parameters

// The minimum clock ticks between two parts arriving for a given L2 part
#declare MinArrivalDelay = 2;

// The minimum clock ticks between two parts departing from a given L1 stack
#declare MinDepartureDelay = 2;

#declare MinPathSeparation = 4;

#declare GatherMoveSpeed = 2;

#declare PathsFilename = "PathsL2.csv";

//--------------------------------------
// Planning inputs

#declare PartSrcPosition = array[NumPartsL2];
#declare PartSrcRotation = array[NumPartsL2];

InitStartingPlacementL2_Z0(PartSrcPosition, PartSrcRotation)

#declare PartDstPosition = array[NumPartsL2];
#declare PartDstRotation = array[NumPartsL2];

InitAssemblyPlacementL2(PartDstPosition, PartDstRotation, 3, 9)

//--------------------------------------
// Planning state

#declare ArrivalTime = array[NumPartsL2];
#declare DepartureTime = array[NumPartsL2];

// Index is the order in which path was planned, value is L1 part index
//
// Note: As planning is based on arrival time, later paths may actually depart
// earlier. However, this can only occur for different types of part. For parts of
// the same type, their relative path order matches their departures, which therefore
// determines the order in their stack
#declare PathOrder = array[NumPartsL2];

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

#macro SourcePosZOffset(IndexInStack)
	(IndexInStack * 2 + 9)
#end

#macro MinPartsDepartedAtTime(Time)
	#local MinNumDeparted = NumParts;

	#for (PartType, 0, NumParts - 1)
		#local NumDeparted = 0;
		#for (I, 0, NumParts - 1)
			#local PartIndex = PartType + I * NumParts;
			#if (defined(DepartureTime[PartIndex]))
				#if (DepartureTime[PartIndex] < Time)
					#local NumDeparted = NumDeparted + 1;
				#end
			#end
		#end

		#local MinNumDeparted = min(MinNumDeparted, NumDeparted);
	#end

	(MinNumDeparted)
#end

#macro PlanMove(PartTypeL2, PartTypeL1, Departure, I, J)
	#local PartIndex = PartTypeL2 * NumParts + PartTypeL1;

	// Plan the move of this part
	#declare PartSrcPosition[PartIndex] =
		PartSrcPosition[PartIndex] + SourcePosZOffset(NumDeparted[PartTypeL1]) * z;

	#declare NumArrived[PartTypeL2] = NumArrived[PartTypeL2] + 1;
	#declare LastArrival[PartTypeL2] = Now;
	#declare ArrivalTime[PartIndex] = Now;

	#declare NumDeparted[PartTypeL1] = NumDeparted[PartTypeL1] + 1;
	#declare LastDeparture[PartTypeL1] = Departure;
	#declare DepartureTime[PartIndex] = Departure;

	#declare PathOrder[NumPathsTotal] = PartIndex;
	#declare NumPathsTotal = NumPathsTotal + 1;

	#debug concat(
		str(PartIndex, 0, 0),
		", Arrival = ", str(Now, 0, 0),
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

#macro WriteL2PathFile()
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

					#local SrcPos = (
						PartSrcPosition[PartIndex] +
						SourcePosZOffset(NumDeparted[PartTypeL1]) * z
					);
					#local DeltaV = PartDstPosition[PartIndex] - SrcPos;
					#local DeltaT = vlength(DeltaV) / GatherMoveSpeed;
					#local Departure = Now - DeltaT;
					#local MinPartsDeparted = MinPartsDepartedAtTime(Departure);

//					#debug concat(
//						"Now = ", str(Now, 0, 0),
//						", Departure = ", str(Departure, 0, 3),
//						", MinPartsDeparted = ", str(MinPartsDeparted, 0, 0)
//						"\n"
//					)

					#local SubLayerRestriction = false; // Default
					#local IsBulky = defined(Part_L2_AttachPoint[PartIndex]);

					// For the first L2 layer there is an additional restriction:
					// - For PartType < 8, the first placed part must be without connector
					// - For PartType >= 8, the first placed part must be with connector
					// This is done to facilitate placing the parts of the initial L1 puzzle
					// into the part stacks. Note, as it happens this restriction was almost
					// adhered without being enforced, so it does not impact scheduling much.
					#if (LayerL2 = 0 & NumDeparted[PartTypeL1] = 0)
						#local SubLayerRestriction = (
							(PartTypeL1 < 8 & IsBulky) |
							(PartTypeL1 >= 8 & !IsBulky)
						);
					#end

					// For the middle L2 layer there are some additional restrictions:
					// - In the first L1 layer the parts with connector should be placed first.
					// - In the third L1 layer these parts should be placed last.
					// This is done to avoid possible collisions of these bulky parts with
					// the other parts in the same L1 layer.
					#if (LayerL2 = 1)
						#local NumInL1Layer = mod(NumArrived[PartTypeL2], 4);

						#local SubLayerRestriction = (
							NumInL1Layer < 2 & (
								(LayerL1 = 0 & !IsBulky) |
								(LayerL1 = 2 & IsBulky)
							)
						);
					#end

					#if (
						!SubLayerRestriction &
						LastArrival[PartTypeL2] <= Now - MinArrivalDelay &
						!defined(DepartureTime[PartIndex]) &
						LastDeparture[PartTypeL1] <= Departure - MinDepartureDelay &
						NumDeparted[PartTypeL1] <= MinPartsDeparted + 2
					)
						// Found a part that can move
//						#debug concat(
//							"Departure = ", str(Departure, 0, 4),
//							", Now = ", str(Now, 0, 4),
//							", DeltaT = ", str(DeltaT, 0, 4),
//							", DeltaV = <", vstr(3, DeltaV, ", ", 0, 4),
//							">\n"
//						)

						// Check if this path collides with already planned paths
						#local CollisionTime = 0;
						#local Collision = false;
						#for (H, 0, NumPathsTotal - 1)
							#local Dist = MinDist(
								SrcPos,
								Departure,
								PartDstPosition[PartIndex],
								Now,
								PartSrcPosition[PathOrder[H]],
								DepartureTime[PathOrder[H]],
								PartDstPosition[PathOrder[H]],
								ArrivalTime[PathOrder[H]],
								CollisionTime
							);

							#if (Dist < MinPathSeparation)
								#debug concat(
									"Collision detected: ",
									str(PartIndex, 0, 0),
									" - ",
									str(PathOrder[H], 0, 0),
									" at ",
									str(CollisionTime, 0, 3),
									"\n"
								)
								#local Collision = true;
								#break
							#end
						#end

						#if (!Collision)
							PlanMove(PartTypeL2, PartTypeL1, Departure, I, J)
							#break
						#end
					#end
				#end
			#end
		#end

		#declare Now = Now + 1;
		#if (Now > 250)
			#break
		#end
	#end

	// Schedule moves of remaining parts in far future (to enable rendering state
	// where planning got stuck)
	#for (I, 0, NumPartsL2 - 1)
		#ifndef (DepartureTime[I])
			#local PartTypeL1 = mod(I, NumParts);
			#local PartTypeL2 = div(I, NumParts);
			PlanMove(PartTypeL2, PartTypeL1, 1000, -1, -1)
		#end
	#end
#end

#macro ReadL2PathFile()
	#local NumPaths = 0;

	#if (file_exists(PathsFilename))
		#fopen PATHS_FILE PathsFilename read

		#while (defined(PATHS_FILE))
			#read (PATHS_FILE,PartIndex,DepTime)

			#if (defined(PartIndex) & defined(DepTime))
				#ifdef (DepartureTime[PartIndex])
					#warning concat("Duplicate entry for Part ", str(PartIndex, 0, 0), "\n")
				#else
					#declare DepartureTime[PartIndex] = DepTime;
					#declare PathOrder[NumPaths] = PartIndex;
				#end

				#local NumPaths = NumPaths + 1;
			#end
		#end
	#end

	(NumPaths)
#end

#if (ReadL2PathFile() = NumPartsL2)
	#debug "Cached L2 paths read from file\n"
#else
	#debug "Generating L2 paths...\n"
	WriteL2PathFile()
#end

//--------------------------------------
// Order stacks based on move order

#declare PartsAtStack = array[NumParts][NumParts];

#for (I, 0, NumParts - 1)
	#declare NumDeparted[I] = 0;
#end

#for (I, 0, NumPartsL2 - 1)
	#local PartIndex = PathOrder[I];
	#local PartType = mod(PartIndex, NumParts);

	#declare PartsAtStack[PartType][NumDeparted[PartType]] = PartIndex;
	#declare NumDeparted[PartType] = NumDeparted[PartType] + 1;
#end

#macro InitStartingPlacementL2(PartPosition, PartRotation)
	InitStartingPlacementL2_Z0(PartPosition, PartRotation)

	#for (I, 0, NumParts - 1)
		#for (J, 0, NumParts - 1)
			#local PartIndex = PartsAtStack[I][J];
	
			#declare PartPosition[PartIndex] = <
				PartPosition[PartIndex].x,
				PartPosition[PartIndex].y,
				SourcePosZOffset(J)
			>;
		#end
	#end
#end
