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

// Clock: 0..42
// Frames: 0..1008

#local D2 = 9;

//--------------------------------------
// Initial placement of compound L2 parts

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
Move(<P_XxX, 0, 0>, -z * 2 * 3)
#declare Now = Now - 6;
Move(<P_I_H, 0, 0>, x * 2 * 3)
Move(<P_XxX, P_I_H, 0>, -y * 2 * 3)

Move(<P_H_X, 0, 0>, -z * 2 * 3)
#declare Now = Now - 6;
Move6(<P_XxX, P_I_H, P_IxX>, <P_I_I, 0, 0>, z * 2 * 3)

Move(<P_H_H, P_I_I, 0>, y * 2 * 3)
Move(<P_I_I, 0, 0>, x * 2 * 3)

// Assemble second half
#declare Now = 0;

Move(<P_HxX, 0, 0>, z * 2 * 3)
#declare Now = Now - 6;
Move(<P_IxH, 0, 0>, -x * 2 * 3)
Move(<P_HxX, P_IxH, 0>, -y * 2 * 3)

Move(<P_HxH, 0, 0>, z * 2 * 3)
#declare Now = Now - 6;
Move(<P_I_X, 0, 0>, -x * 2 * 3)

Move6(<P_HxX, P_IxH, P_IxI>, <P_HxH, P_I_X, 0>, -z * 2 * 3)
#declare Now = Now - 6;
Move(<P_X_X, 0, 0>, z * 2 * 3)

Move(<P_HxH, P_I_X, 0>, y * 2 * 3)

// Assemble both halves
#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, -x * 2 * 3)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, x * 2 * 3)

//--------------------------------------
// Animate camera (throughout animation)

// Match Anim04 end position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-83, 54, -75>;

#local CameraT0 = 30;
#local CameraT1 = 42;
#declare CameraPosition = LerpVector(
	CameraPosition, CameraPosition * 0.45, f_ramp(CameraT0, CameraT1, clock)
);

#include "Scene.inc"

//--------------------------------------
// Place objects

#for (I, 0, NumParts - 1)
	object {
		CompoundPart_L2[I]

		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end