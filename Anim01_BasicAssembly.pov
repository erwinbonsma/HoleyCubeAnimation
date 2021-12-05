#include "Globals.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..75
// Frames: 0..1875

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

#declare AssemblyOrder = array[NumParts] { 6, 0, 1, 4, 9, 8, 11, 10, 7, 2, 3, 5};


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

#declare CameraPosition = <0, 12, -30>;
#declare CameraLookAt = <-18, 0, 9>;

MoveVector(CameraLookAt, <0, 0, 10>, 4)

#declare Now0 = Now;
MoveVector(CameraLookAt, <0, 0, 4>, 7)
#declare Now = Now0;
MoveVector(CameraPosition, <-23, 15, -25> * 1.2, 7)
#declare Now = ceil(Now0);

//--------------------------------------
// Move to exploded pre-assembly

#declare MoveSpeed = 2;

#declare ClockStart = Now;
#declare MaxNow = Now;

#for (I, 0, NumParts - 1)
  // Move parts in parallel, with delay of 4 clock ticks
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

#declare Now = ceil(MaxNow - 3);
MoveVector(CameraLookAt, <0, 0, 0>, 4)

#declare Now = Now + 2;

//--------------------------------------
// Assemble both puzzle halves

#declare MoveSpeed = 1;

// Assemble first half
Move(<P_XxX, 0, 0>, -z * 2)
#declare Now = Now - 2; 
Move(<P_I_H, 0, 0>, x * 2)
Move(<P_XxX, P_I_H, 0>, -y * 2)

Move(<P_H_X, 0, 0>, -z * 2)
#declare Now = Now - 2;
Move6(<P_XxX, P_I_H, P_IxX>, <P_I_I, 0, 0>, z * 2)

Move(<P_H_H, P_I_I, 0>, y * 2)
Move(<P_I_I, 0, 0>, x * 2)

// Assemble second half
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

// Assemble both halves
#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, -x * 2)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, x * 2)
#declare D = Now - Now0;
#declare Now = Now0;
MoveVector(CameraPosition, CameraPosition * 0.5, D)

// Rotate assembled puzzle

RotatePuzzle(<0, 360, 0>, 8)
RotatePuzzle(<360, 0, 0>, 8)

#include "Scene.inc"

PuzzleL1()

#debug concat(vstr(3, CameraPosition, ", ", 1, 3), "\n")

