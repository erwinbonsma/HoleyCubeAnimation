/* Holey Puzzle POV-Ray Animation
 *
 * Scene 1: Assemble Level 1 puzzle
 *
 * Copyright (C) 2021  Erwin Bonsma
 */
 
#include "Globals.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..73
// Frames: 0..1752

// Order parts by increasing weight
#declare InitialPartPosition = array[NumParts];

// Orient parts consistently
#declare InitialPartRotation = array[NumParts];

// Part 1: I I
#declare InitialPartPosition[P_I_I - 1] = <0, 0, 0>;
#declare InitialPartRotation[P_I_I - 1] = transform {
	rotate x * 90
}
#declare InitialPartPosition[P_IxI - 1] = <0, -2, 0>;
#declare InitialPartRotation[P_IxI - 1] = transform {
	rotate x * 90
}

// Part 2: I H
#declare InitialPartPosition[P_I_H - 1] = <0, -4, 0>;
#declare InitialPartPosition[P_IxH - 1] = <0, -6, 0>;
#declare InitialPartRotation[P_IxH - 1] = transform {
	rotate z * 180
}

// Part 3: H H
#declare InitialPartPosition[P_H_H - 1] = <4, 0, 0>;
#declare InitialPartPosition[P_HxH - 1] = <4, -2, 0>;
#declare InitialPartRotation[P_HxH - 1] = transform {
	rotate x * 90
}

// Part 4: I X
#declare InitialPartPosition[P_I_X - 1] = <4, -4, 0>;
#declare InitialPartRotation[P_I_X - 1] = transform {
	rotate z * 180
}
#declare InitialPartPosition[P_IxX - 1] = <4, -6, 0>;
#declare InitialPartRotation[P_IxX - 1] = transform {
	rotate z * 180
}

// Part 5: H X
#declare InitialPartPosition[P_H_X - 1] = <8, 0, 0>;
#declare InitialPartRotation[P_H_X - 1] = transform {
	rotate z * 180
}
#declare InitialPartPosition[P_HxX - 1] = <8, -2, 0>;

// Part 6: X X
#declare InitialPartPosition[P_X_X - 1] = <8, -4, 0>;
#declare InitialPartPosition[P_XxX - 1] = <8, -6, 0>;

#declare AssemblyOrder = AssemblyOrderL1;


#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = InitialPartPosition[I] + <-4, 3, 10>;
	#ifdef (InitialPartRotation[I])
		#declare PartRotation[I] = InitialPartRotation[I];
	#else
		#declare PartRotation[I] = transform {}
	#end
#end

//--------------------------------------
// Move camera

// Camera initially shows nothing
#declare CameraPosition = <0, 12, -30>;
#declare CameraLookAt = <-18, 0, 9>;

// Let camera show part stacks
#local CameraT0 = 4;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <0, 0, 10>, f_sramp(0, CameraT0, clock)
);

// Then slowly change camera so that exploded parts are shown
#local CameraT1 = 11;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <0, 0, 4>, f_sramp(CameraT0, CameraT1, clock)
);
#declare CameraPosition = LerpVector(
	CameraPosition, <-27.6, 18, -30>, f_sramp(CameraT0, CameraT1, clock)
);

//--------------------------------------
// Move to exploded pre-assembly

#declare MoveSpeed = 2;

#declare ClockStart = CameraT0;
#declare MaxNow = ClockStart;

#for (I, 0, NumParts - 1)
  // Move parts in parallel, with delay of two clock ticks
	#declare Now = ClockStart + I * 2;

	#declare PartNum = AssemblyOrder[I];
	#declare DeltaV = PositionForPart(PartNum, 3) - PartPosition[PartNum];
	#declare DeltaT = ClockTicksForMove(DeltaV);

	#declare Now0 = Now;
	TimedMove(<PartNum + 1, 0, 0>, DeltaV, DeltaT)
	#declare Now = Now0;
	TimedRotateToTransform(<PartNum + 1, 0, 0>, RotationForPart(PartNum), DeltaT)

	#declare MaxNow = max(Now, MaxNow);
#end

// When parts are nearly in place, move camera to center the puzzle
#local CameraT2 = ceil(MaxNow) - 3;
#local CameraT3 = CameraT2 + 4;
#declare CameraLookAt = LerpVector(
	CameraLookAt, <0, 0, 0>, f_sramp(CameraT2, CameraT3, clock)
);

// Wait for a bit before starting assembly
#declare Now = ceil(MaxNow) + 3;

//--------------------------------------
// Assemble both puzzle halves

#declare MoveSpeed = 1;

// Assemble first half
Move(<P_HxX, 0, 0>, z * 2)
#declare Now = Now - 2;
Move(<P_IxH, 0, 0>, -x * 2)
Move(<P_HxX, P_IxH, 0>, -y * 2)

Move(<P_HxH, 0, 0>, z * 2)
#declare Now = Now - 2;
Move(<P_I_X, 0, 0>, -x * 2)

Move6(<P_HxX, P_IxH, P_IxI>, <P_HxH, P_I_X, 0>, -z * 2)
#declare Now = Now - 2;
Move(<P_X_X, 0, 0>, z * 2)

Move(<P_HxH, P_I_X, 0>, y * 2)

// Assemble second half
Move(<P_XxX, 0, 0>, -z * 2)
#declare Now = Now - 2;
Move(<P_I_H, 0, 0>, x * 2)
Move(<P_XxX, P_I_H, 0>, -y * 2)

Move(<P_H_X, 0, 0>, -z * 2)
#declare Now = Now - 2;
Move6(<P_XxX, P_I_H, P_IxX>, <P_I_I, 0, 0>, z * 2)

Move(<P_H_H, P_I_I, 0>, y * 2)
Move(<P_I_I, 0, 0>, x * 2)

// Assemble both halves
#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, -x * 2)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, x * 2)

// Zoom into puzzle
#local CameraT4 = Now0;
#local CameraT5 = Now;
#declare CameraPosition = LerpVector(
	CameraPosition, CameraPosition * 0.5, f_sramp(CameraT4, CameraT5, clock)
);

// Rotate assembled puzzle

RotatePuzzle(<0, 360, 0>, 8)
RotatePuzzle(<360, 0, 0>, 8)

#include "Scene.inc"

PuzzleL1()

#debug concat(vstr(3, CameraPosition, ", ", 1, 3), "\n")

