/* Holey Puzzle POV-Ray Animation
 *
 * Scene 3: Prepare Level 2 assembly
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"
#include "Beat.inc"
#include "PathsL2.inc"

// Clock: 0..180
// Frames: 0..4320

#local D2 = 9;

//--------------------------------------
// Coordinate to beat of sound track

#local BeatLoStart = 14;
#local BeatMeStart1 = 43;
#local BeatMeEnd1 = 70;
#local BeatMeStart2 = 128;
#local BeatHiStart = 157;

#local AmpD = 0.2;
#declare f_beatamp = function(time) {
	f_ramp(BeatLoStart - AmpD, BeatLoStart + AmpD, time)
	+ f_ramp(BeatMeStart1 - AmpD, BeatMeStart1 + AmpD, time)
	- f_ramp(BeatMeEnd1 - AmpD, BeatMeEnd1 + AmpD, time)
	+ f_ramp(BeatMeStart2 - AmpD, BeatMeStart2 + AmpD, time)
	+ f_ramp(BeatHiStart - AmpD, BeatHiStart + AmpD, time)
}

#declare f_beatmul_L1 = function(time) {
	f_beatmul(f_beat(time), BeatAmpL1 * f_beatamp(time))
}

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

#declare MoveSpeed = GatherMoveSpeed;

// Carry out the moves
#for (I, 0, NumPartsL2 - 1)
	#local PartIndex = PathOrder[I];
	#local PartType = mod(PartIndex, NumParts);
	#local PartTypeL2 = div(PartIndex, NumParts);

	#local DepTime = DepartureTime[PartIndex] - FirstDeparture;
	#if (DepTime < clock)
		// Base timing on original planned path
		#local DeltaV = PartDstPosition[PartIndex] - PartPosition[PartIndex];
		#local DeltaT = ClockTicksForMove(DeltaV);

		#if (false)
			#debug concat(
				"PartIndex = ", str(PartIndex, 0, 0),
				", DepTime = ", str(DepTime, 0, 3),
				", ArrTime = ", str(DepTime + DeltaT, 0, 3),
				", Now = ", str(Now, 0, 3),
				", DeltaT = ", str(DeltaT, 0, 3),
				"\n"
			)
		#end

		// However, move the part first forward until it is aligned with top of the
		// currently biggest stack. From there, move it to its destination position.
		// This avoids that the part crosses through another stack.
		#local StartZ = SourcePosZOffset(MinPartsDepartedAtTime(
			DepartureTime[PartIndex] + 0.1
		));
		#local DeltaZ = PartPosition[PartIndex].z - StartZ;
		#if (false)
			#debug concat(
				"I = ", str(I, 0, 0),
				", PartIndex = ", str(PartIndex, 0, 0),
				", PartType = ", str(PartType, 0, 0),
				", DepTime = ", str(DepTime, 0, 3),
				", StartZ = ", str(StartZ, 0, 0),
				", DeltaZ = ", str(DeltaZ, 0, 0),
				"\n"
			)
		#end

		#if (DeltaZ > 0)
			#local DeltaT0 = ClockTicksForMove(DeltaZ * z);
			#declare Now = DepTime;
			TimedMove(<PartIndex + 1, 0, 0>, DeltaZ * -z, DeltaT0)

			// Start main movement before Z movement is fully finished
			#local DeltaT0 = DeltaT0 - 0.2;

			#local DepTime = DepTime + DeltaT0;
			#local DeltaT = DeltaT - DeltaT0;
		#end

		// Tweak destination position to match the beat
		#local PartL2Pos = PositionForPart(PartTypeL2, D2);
		#local DstPosWithBeat = (
			PartDstPosition[PartIndex] - PartL2Pos
		) * f_beatmul_L1(DepTime + DeltaT) + PartL2Pos;
		#local DeltaV = DstPosWithBeat - PartPosition[PartIndex];

		#declare Now = DepTime;
		TimedMove(<PartIndex + 1, 0, 0>, DeltaV, DeltaT)
		#if (clock >= Now)
			#declare PartPositioned[PartIndex] = true;
		#end

		// Delay rotation a bit, and also let it finish before path is in final position
		#local RotDelay = 1;
		#declare Now = DepTime + RotDelay;
		#declare DeltaT = DeltaT - 2 * RotDelay;
		TimedRotateToTransform(<PartIndex + 1, 0, 0>, PartDstRotation[PartIndex], DeltaT)
	#end
#end

//--------------------------------------
// Animate camera (throughout animation)

// Match Scene 2 camera end position
#declare CameraLookAt = <0, 2, 2>;
#declare CameraPosition = <-55.2, 36, -58>;

#local CameraT0 = 0;
#local CameraT1 = 15;
#local CameraT2 = 25;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <0, 0, 0>, f_ramp(CameraT0, CameraT1, clock)
);
#declare CameraPosition = LerpVector(
	CameraPosition, <-83, 54, -75>, f_ramp(CameraT0, CameraT2, clock)
);

#include "Scene.inc"

//--------------------------------------
// Place objects

#local BeatMul1 = f_beatmul_L1(clock);

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
				) * BeatMul1 + PartL2Pos;
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