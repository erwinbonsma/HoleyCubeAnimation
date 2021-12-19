#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"
#include "Beat.inc"
#include "PathsL2.inc"

// Clock: 0..190
// Frames: 0..4560

#local D2 = 9;

// Time when L1 beat multiplier starts phading out.
// Also time when L2 beat multiplier starts phade in.
#local BeatStartT = 187;

// Time when L1 beat multiplier is fully phaded out.
// Also time when L2 beat multiplier phade in finished.
#local BeatEndT = 190;

#declare f_beatmul_L1 = function(time) {
	f_beatmul(f_beat(time), BeatAmpL1 * (1 - f_ramp(BeatStartT, BeatEndT, time)))
}
#declare f_beatmul_L2 = function(time) {
	f_beatmul(f_beat(time), BeatAmpL2 * f_ramp(BeatStartT, BeatEndT, time))
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
MoveVector(CameraLookAt, CameraLookAt_End, 15)
#declare Now = 0;
MoveVector(CameraPosition, CameraPosition_End, 25)


#include "Scene.inc"

//--------------------------------------
// Place objects

#local BeatMul1 = f_beatmul_L1(clock);
#local BeatMul2 = f_beatmul_L2(clock);

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
				) * BeatMul1 + PartL2Pos * BeatMul2;
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