/* Holey Puzzle POV-Ray Animation
 *
 * Scene 4: Assemble Level 2 puzzle parts
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..35
// Frames: 0..840

//--------------------------------------
// Coordinate to beat of sound track

// End clock ticks of previous animation, where beat started
#declare BeatTimeOffset = 180;
#include "Beat.inc"

// Switch from hi to medium beat when part assembly starts
#local BeatT0 = 14;

#local f_beatamp = function(time) {
	1 - f_ramp(BeatT0 - 0.5, BeatT0 + 0.5, time) + 2
}

// Time when L1 beat multiplier starts phading out.
// Also time when L2 beat multiplier starts phade in.
#local BeatSwitchStart = 5;

// Time when L1 beat multiplier is fully phaded out.
// Also time when L2 beat multiplier phade in finished.
#local BeatSwitchEnd = 17;

#declare f_beatmul_L1 = function(time) {
	f_beatmul(
		f_beat(time),
		BeatAmpL1 * f_beatamp(time) * (1 - f_ramp(BeatSwitchStart, BeatSwitchEnd, time)))
}
#declare f_beatmul_L2 = function(time) {
	f_beatmul(
		f_beat(time),
		BeatAmpL2 * f_beatamp(time) * f_ramp(BeatSwitchStart, BeatSwitchEnd, time))
}

//--------------------------------------

#local D1 = 3;
#local D2 = 9;

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitAssemblyPlacementL2(PartPosition, PartRotation, D1, D2)

//--------------------------------------
// Rotate puzzle

#declare RotStart = 2;
#declare RotEnd = 20;
#declare PuzzleTransform = transform {
	rotate LerpVector(<0, 0, 0>, <0, 360, 0>, f_sramp(RotStart, RotEnd, clock))
}

#declare Now = RotEnd + 1;

//--------------------------------------
// Assemble L2 parts

#declare P1_I_I = P_I_I;
#declare P1_IxI = P_IxI;
#declare P1_I_H = P_I_H;
#declare P1_IxH = P_IxH;

#declare P1_I_X = P_I_X;
#declare P1_IxX = P_IxX;
#declare P1_H_H = P_H_H;
#declare P1_HxH = P_HxH;

#declare P1_H_X = P_H_X;
#declare P1_HxX = P_HxX;
#declare P1_X_X = P_X_X;
#declare P1_XxX = P_XxX;

#local AssemblyStart = Now;

#for (I, 0, NumParts - 1)
	#local L2_Rotation = transform {
		transform { RotationForPart(I) inverse }

		#ifdef (PartRotation_L2[I])
			rotate PartRotation_L2[I]
		#end

		transform { RotationForPart(I) }
	}

	#local VX = VectorTransform(x, L2_Rotation);
	#local VY = VectorTransform(y, L2_Rotation);
	#local VZ = VectorTransform(z, L2_Rotation);

	// Assemble first half
	#declare Now = AssemblyStart;

	Move(<P1_XxX, 0, 0>, -VZ * 2)
	#declare Now = Now - 2;
	Move(<P1_I_H, 0, 0>, VX * 2)
	Move(<P1_XxX, P1_I_H, 0>, -VY * 2)

	Move(<P1_H_X, 0, 0>, -VZ * 2)
	#declare Now = Now - 2;
	Move6(<P1_XxX, P1_I_H, P1_IxX>, <P1_I_I, 0, 0>, VZ * 2)

	Move(<P1_H_H, P1_I_I, 0>, VY * 2)
	Move(<P1_I_I, 0, 0>, VX * 2)

	// Assemble second half
	#declare Now = AssemblyStart;

	Move(<P1_HxX, 0, 0>, VZ * 2)
	#declare Now = Now - 2;
	Move(<P1_IxH, 0, 0>, -VX * 2)
	Move(<P1_HxX, P1_IxH, 0>, -VY * 2)

	Move(<P1_HxH, 0, 0>, VZ * 2)
	#declare Now = Now - 2;
	Move(<P1_I_X, 0, 0>, -VX * 2)

	Move6(<P1_HxX, P1_IxH, P1_IxI>, <P1_HxH, P1_I_X, 0>, -VZ * 2)
	#declare Now = Now - 2;
	Move(<P1_X_X, 0, 0>, VZ * 2)

	Move(<P1_HxH, P1_I_X, 0>, VY * 2)

	// Assemble both halves
	#declare Now0 = Now;
	SlowMove6(<P1_XxX, P1_I_H, P1_H_X>, <P1_IxX, P1_I_I, P1_H_H>, -VX * 2)
	#declare Now = Now0;
	SlowMove6(<P1_X_X, P1_IxH, P1_HxX>, <P1_I_X, P1_IxI, P1_HxH>, VX * 2)

	#declare P1_I_I = P1_I_I + NumParts;
	#declare P1_IxI = P1_IxI + NumParts;
	#declare P1_I_H = P1_I_H + NumParts;
	#declare P1_IxH = P1_IxH + NumParts;

	#declare P1_I_X = P1_I_X + NumParts;
	#declare P1_IxX = P1_IxX + NumParts;
	#declare P1_H_H = P1_H_H + NumParts;
	#declare P1_HxH = P1_HxH + NumParts;

	#declare P1_H_X = P1_H_X + NumParts;
	#declare P1_HxX = P1_HxX + NumParts;
	#declare P1_X_X = P1_X_X + NumParts;
	#declare P1_XxX = P1_XxX + NumParts;
#end

#debug concat("Move Done =", str(Now, 0, 0), "\n")

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim03 end position

#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#include "Scene.inc"

//--------------------------------------
// Place objects

#local BeatMul1 = f_beatmul_L1(clock);
#local BeatMul2 = f_beatmul_L2(clock);

union {
	#for (I, 0, NumPartsL2 - 1)
		#local PartTypeL1 = mod(I, NumParts);
		#local PartTypeL2 = div(I, NumParts);

		#local PartL2Pos = PositionForPart(PartTypeL2, D2);
		#declare PartPosition[I] = (
			PartPosition[I] - PartL2Pos
		) * BeatMul1 + PartL2Pos * BeatMul2;

		#if (true)
		object {
			Part_L2[I]
			transform { PartRotation[I] }
			translate PartPosition[I]
		}
		#end
	#end
	transform { PuzzleTransform }
}
