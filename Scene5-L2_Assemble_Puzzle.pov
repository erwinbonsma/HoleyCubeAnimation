/* Holey Puzzle POV-Ray Animation
 *
 * Scene 5: Assemble Level 2 puzzle
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..27
// Frames: 0..648

//--------------------------------------
// Coordinate to beat of sound track

// End clock ticks of previous animation, where beat started
#declare BeatTimeOffset = 180 + 35;
#include "Beat.inc"

#local BeatAmp = 2;
#local AmpD = 0.5;
#local BeatT1 = 13;

#declare f_beatmul_L2 = function(time) {
	f_beatmul(
		f_beat(time),
		BeatAmpL2 * BeatAmp * (1 - f_ramp(BeatT1 - AmpD, BeatT1 + AmpD, time))
	)
}

#declare BeatMovementCenter = array[NumParts];

//--------------------------------------
// Initial placement of compound L2 parts

#local D2 = 9;

DefineCompoundParts_L2()

#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];

#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = PositionForPart(I, D2);
	#declare PartRotation[I] = RotationForL2Part(I);
#end

//--------------------------------------
// Assemble both puzzle halves

#declare MoveSpeed = 1;

// Assemble first half
FastMove(<P_XxX, 0, 0>, -z * 2 * 3)
#declare Now = Now - 3;
FastMove(<P_I_H, 0, 0>, x * 2 * 3)
FastMove(<P_XxX, P_I_H, 0>, -y * 2 * 3)

FastMove(<P_H_X, 0, 0>, -z * 2 * 3)
#declare Now = Now - 3;
FastMove6(<P_XxX, P_I_H, P_IxX>, <P_I_I, 0, 0>, z * 2 * 3)

FastMove(<P_H_H, P_I_I, 0>, y * 2 * 3)
FastMove(<P_I_I, 0, 0>, x * 2 * 3)

// Assemble second half
#declare Now = 0;

FastMove(<P_HxX, 0, 0>, z * 2 * 3)
#declare Now = Now - 3;
FastMove(<P_IxH, 0, 0>, -x * 2 * 3)
FastMove(<P_HxX, P_IxH, 0>, -y * 2 * 3)

FastMove(<P_HxH, 0, 0>, z * 2 * 3)
#declare Now = Now - 3;
FastMove(<P_I_X, 0, 0>, -x * 2 * 3)

FastMove6(<P_HxX, P_IxH, P_IxI>, <P_HxH, P_I_X, 0>, -z * 2 * 3)
#declare Now = Now - 3;
FastMove(<P_X_X, 0, 0>, z * 2 * 3)

FastMove(<P_HxH, P_I_X, 0>, y * 2 * 3)

// Assemble both halves
#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, -x * 2 * 3)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, x * 2 * 3)

//--------------------------------------
// Align movement centers just before parts are connected

// Connections at t = 3
#declare BeatMovementCenter[P_XxX - 1] = LerpVector(
	<0, 0, 0>, <0, 0, -3>, f_ramp(0, 1.5, clock)
);
#declare BeatMovementCenter[P_I_H - 1] = LerpVector(
	<0, 0, 0>, <3, 0, 0>, f_ramp(0, 1.5, clock)
);
#declare BeatMovementCenter[P_HxX - 1] = LerpVector(
	<0, 0, 0>, <0, 0, 3>, f_ramp(0, 1.5, clock)
);
#declare BeatMovementCenter[P_IxH - 1] = LerpVector(
	<0, 0, 0>, <-3, 0, 0>, f_ramp(0, 1.5, clock)
);

// Connections at t = 6
#declare BeatMovementCenter[P_IxX - 1] = LerpVector(
	<0, 0, 0>, <0, 3, 0>, f_ramp(3, 4.5, clock)
);
#declare BeatMovementCenter[P_IxI - 1] = LerpVector(
	<0, 0, 0>, <0, 3, 0>, f_ramp(3, 4.5, clock)
);

// Connections at t = 9
#declare BeatMovementCenter[P_H_X - 1] = LerpVector(
	<0, 0, 0>, <0, 3, -6>, f_ramp(6, 7.5, clock)
);
#declare BeatMovementCenter[P_HxH - 1] = LerpVector(
	<0, 0, 0>, <0, 0,  3>, f_ramp(6, 7.5, clock)
);
#declare BeatMovementCenter[P_I_X - 1] = LerpVector(
	<0, 0, 0>, <-3, 0, 0>, f_ramp(6, 7.5, clock)
);

// Connections at t = 12
#declare BeatMovementCenter[P_H_H - 1] = LerpVector(
	<0, 0, 0>, <0, 6, -3>, f_ramp(9, 10.5, clock)
);
#declare BeatMovementCenter[P_X_X - 1] = LerpVector(
	<0, 0, 0>, <0, 3, 6>, f_ramp(9, 10.5, clock)
);

// Connections at t = 15
#declare BeatMovementCenter[P_I_I - 1] = LerpVector(
	<0, 0, 0>, <0, 3, 6>, f_ramp(12, 13.5, clock)
);
#declare BeatMovementCenter[P_HxH - 1] = LerpVector(
	BeatMovementCenter[P_HxH - 1], <0, 6,  3>, f_ramp(6, 7.5, clock)
);
#declare BeatMovementCenter[P_I_X - 1] = LerpVector(
	BeatMovementCenter[P_I_X - 1], <-3, 6, 0>, f_ramp(6, 7.5, clock)
);

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim04 end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#local CameraT0 = 15;
#local CameraT1 = 27;
#declare CameraPosition = LerpVector(
	CameraPosition, CameraPosition * 0.45, f_ramp(CameraT0, CameraT1, clock)
);

#include "Scene.inc"

//--------------------------------------
// Place objects

#local BeatMul2 = f_beatmul_L2(clock);

#for (I, 0, NumParts - 1)
	object {
		CompoundPart_L2[I]

		transform { PartRotation[I] }
		translate (
			(PartPosition[I] + BeatMovementCenter[I]) * BeatMul2 - BeatMovementCenter[I]
		)
	}
#end