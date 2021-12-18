#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"
#include "Beat.inc"
#include "PathsL2.inc"

// Clock: 0..190
// Frames: 0..4750

#local D2 = 9;
#declare BeatMultiplier = function(beat) { 1 - 0.01 * sin(2 * pi * beat) }

//--------------------------------------
// Move to fully exploded layout

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];
#declare PartPositioned = array[NumPartsL2];

InitStartingPlacementL2(PartPosition, PartRotation)

#local FirstDeparture = 0;
#for (I, 0, NumPartsL2 - 1)
	#local FirstDeparture = min(FirstDeparture, DepartureTime[I]);
#end
#local FirstDeparture = floor(FirstDeparture);

// Carry out the moves
#for (I, 0, NumPartsL2 - 1)
	#local PartIndex = PathOrder[I];
	#local PartType = mod(PartIndex, NumParts);
	#local PartTypeL2 = div(PartIndex, NumParts);

	#local DepTime = DepartureTime[PartIndex] - FirstDeparture;
	#if (DepTime < clock)
		#local DeltaV = PartDstPosition[PartIndex] - PartPosition[PartIndex];
		#local DeltaT = ClockTicksForMove(DeltaV);

		// Tweak destination position to match the beat
		#local PartL2Pos = PositionForPart(PartTypeL2, D2);
		#local DestPosWithBeat = (
			PartDstPosition[PartIndex] - PartL2Pos
		) * BeatMultiplier(BeatAt(DepTime + DeltaT)) + PartL2Pos;
		#local DeltaV = DestPosWithBeat - PartPosition[PartIndex];

		#declare Now = DepTime;
		TimedMove(<PartIndex + 1, 0, 0>, DeltaV, DeltaT)
		#if (clock >= Now)
			#declare PartPositioned[PartIndex] = true;
		#end

		#declare Now = DepTime;
		TimedRotateToTransform(<PartIndex + 1, 0, 0>, PartDstRotation[PartIndex], DeltaT)
	#end
#end

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim02 end position
#declare CameraLookAt = <0, 2, 2>;
#declare CameraPosition = <-55.2, 36, -58>;

#declare CameraLookAt_End = <0, 0, 0>;
#declare CameraPosition_End = <-83, 54, -75>;

#declare Now0 = Now;
#declare Now = 0;
MoveVector(CameraLookAt, CameraLookAt_End, 30)
#declare Now = 0;
MoveVector(CameraPosition, CameraPosition_End, 50)


#include "Scene.inc"

//--------------------------------------
// Place objects

#local BeatMul = BeatMultiplier(Beat);
#for (I, 0, NumPartsL2 - 1)
	#local PartTypeL1 = mod(I, NumParts);
	#local PartTypeL2 = div(I, NumParts);
	#if (true)
		object {
			Part_L2[I]

			transform { PartRotation[I] }

			#ifdef (PartPositioned[I])
				#local PartL2Pos = PositionForPart(PartTypeL2, D2);
				#declare PartPosition[I] = (
					PartDstPosition[I] - PartL2Pos
				) * BeatMul + PartL2Pos;
			#end

			translate PartPosition[I]
		}
	#end
#end

//union {
//	sphere { <0, 0, 0>, 1}
//	cylinder {
//		z * -10,
//		z * 30, 0.3
//	}
//	pigment { color White }
//}