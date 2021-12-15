#include "Globals.inc"
#include "PartsL2.inc"
#include "PathsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

// Clock: 0..50
// Frames: 0..1250

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

InitStartingPlacementL2(PartPosition, PartRotation)

#declare RestorePosition = array[NumParts];
#declare RestoreRotation = array[NumParts];
#declare MovingPart = array[NumParts];

#for (I, 0, NumParts - 1)

	#for (J, 0, 4)
		#local PartIndex = PartsAtStack[I][J];

		#ifndef (Part_L2_Twist[PartIndex])
			// Found the first non-bulky part on the stack
			#declare MovingPart[I] = PartIndex;
			#break
		#end
	#end

	// Remember the restore position
	#declare RestorePosition[I] = PartPosition[PartIndex];
	#declare RestoreRotation[I] = PartRotation[PartIndex];

	#declare PartPosition[PartIndex] = PositionForPart(I, 1);
	#declare PartRotation[PartIndex] = RotationForPart(I);
#end

//--------------------------------------
// Move stacks
//
// Let stacks start further away (so they are not directly visible) and move them
// forwards to their final position while the puzzle is being disassembled.

#local StackMoveTStart = 0;
#local StackMoveTEnd = 20;
#local StackDelta = <-10, 0, 10>;
#local Now0 = Now;
#local Z0 = SourcePosZOffset(0);

#for (I, 0, NumPartsL2 - 1)
	#if (PartPosition[I].z >= Z0)
		#declare PartPosition[I] = PartPosition[I] + StackDelta;
		#declare Now = StackMoveTStart;
		TimedMove(<I + 1, 0, 0>, -StackDelta, StackMoveTEnd - StackMoveTStart)
	#end
#end

#declare Now = Now0;

//--------------------------------------
// Match shorthands with actual parts

#declare P_I_I = MovingPart[P_I_I - 1] + 1;
#declare P_IxI = MovingPart[P_IxI - 1] + 1;
#declare P_I_H = MovingPart[P_I_H - 1] + 1;
#declare P_IxH = MovingPart[P_IxH - 1] + 1;

#declare P_I_X = MovingPart[P_I_X - 1] + 1;
#declare P_IxX = MovingPart[P_IxX - 1] + 1;
#declare P_H_H = MovingPart[P_H_H - 1] + 1;
#declare P_HxH = MovingPart[P_HxH - 1] + 1;

#declare P_H_X = MovingPart[P_H_X - 1] + 1;
#declare P_HxX = MovingPart[P_HxX - 1] + 1;
#declare P_X_X = MovingPart[P_X_X - 1] + 1;
#declare P_XxX = MovingPart[P_XxX - 1] + 1;

//--------------------------------------
// Disassemble L1 puzzle

// Disassemble puzzle into two halves
#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, 0, P_H_H>, x * 2)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, -x * 2)

// Disassemble both halves
#declare Now0 = Now;

// Disassemble first half
Move(<P_HxH, P_I_X, 0>, -y * 2)

Move6(<P_HxX, P_IxH, P_IxI>, <P_HxH, P_I_X, 0>, z * 2)
#declare Now = Now - 2;
Move(<P_X_X, 0, 0>, -z * 2)

Move(<P_HxX, P_IxH, 0>, y * 2)

Move(<P_HxH, 0, 0>, -z * 2)
#declare Now = Now - 2;
Move(<P_I_X, 0, 0>, x * 2)
#declare Now = Now - 2;
Move(<P_HxX, 0, 0>, -z * 2)
#declare Now = Now - 2;
Move(<P_IxH, 0, 0>, x * 2)

// Disassemble second half
#declare Now = Now0;
Move(<P_H_H, P_I_I, 0>, -y * 2)

Move(<P_H_X, 0, 0>, z * 2)
#declare Now = Now - 2;
Move6(<P_XxX, P_I_H, P_IxX>, <P_I_I, 0, 0>, -z * 2)

Move(<P_XxX, P_I_H, 0>, y * 2)

Move(<P_XxX, 0, 0>, z * 2)
#declare Now = Now - 2;
Move(<P_I_H, 0, 0>, -x * 2)

#declare Now = Now + 2;

//--------------------------------------
// Move parts to starting grid

#declare MoveSpeed = 2;

// The restore order (order index to part type)
#declare RestoreOrder = array[NumParts] {
	3, 5, 7, 2, 10, 11, 9, 8, 1, 4, 6, 0
};

#declare ClockStart = Now;
#declare MaxNow = Now;
#local Z0 = SourcePosZOffset(0);

#for (I, 0, NumParts - 1)
  // Move parts in parallel, with delay of 2 clock ticks
	#declare Now = ClockStart + I * 2;

	#declare PartIndex = MovingPart[RestoreOrder[I]];
	#declare PartType = mod(PartIndex NumParts);

	// First move to top of stack
	#declare DstPos = <
		RestorePosition[PartType].x,
		RestorePosition[PartType].y,
		Z0
	>;
	#declare DeltaV = DstPos - PartPosition[PartIndex];
	#declare DeltaT = ClockTicksForMove(DeltaV);

	#declare Now0 = Now;
	TimedMove(<PartIndex + 1, 0, 0>, DeltaV, DeltaT)
	#local DeltaZ = RestorePosition[PartType].z - Z0;
	#if (DeltaZ > 0)
		Move(<PartIndex + 1, 0, 0>, z * DeltaZ)
	#end

	#declare Now = Now0;
	TimedRotateToTransform(<PartIndex + 1, 0, 0>, RestoreRotation[PartType], DeltaT)

	#declare Now0 = Now0 + DeltaT;
	#local StackDepth = 0;
	#while (StackDepth * 2 < DeltaZ)
		// Make room for the part to be placed inside the stack
		#declare Now = Now0 - 4;
		#local PartIndex = PartsAtStack[PartType][StackDepth];
		Move(<PartIndex + 1, 0, 0>, x * 2)

		#declare Now = Now0 + 2;
		Move(<PartIndex + 1, 0, 0>, -x * 2)

		#declare Now0 = Now0 + 2;
		#local StackDepth = StackDepth + 1;
	#end

	#declare MaxNow = max(Now, MaxNow);
#end

//--------------------------------------
// Animate camera (throughout animation)

// Starting position
#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-13.8, 9, -15>; // Matches Anim01 end position

#declare CameraLookAt_End = CameraLookAt + z * 2 + y * 2;
#declare CameraPosition_End = CameraPosition * 4 + z * 2;

#declare Now0 = Now;
#declare Now = 1;
MoveVector(CameraLookAt, CameraLookAt_End, Now0)
#declare Now = 1;
MoveVector(CameraPosition, CameraPosition_End, Now0)

//#declare CameraLookAt = CameraLookAt_End;
//#declare CameraPosition = CameraPosition_End;

#include "Scene.inc"

#for (I, 0, NumPartsL2 - 1)
	object {
		Part_L2[I]
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end

#debug concat("CameraLookAt = ", vstr(3, CameraLookAt, ", ", 1, 3), "\n")
#debug concat("CameraPosition = ", vstr(3, CameraPosition, ", ", 1, 3), "\n")
