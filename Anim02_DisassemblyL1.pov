#include "Globals.inc"
#include "PartsL2.inc"
#include "Moves.inc"
#include "Anim.inc"

//#declare CameraPosition = <-23, 15, -25> * 1.2 * 1.3;
//#declare CameraPosition = <-32, 20, -100>;

#declare CameraLookAt = <0, 0, 0>;
#declare CameraPosition = <-13.8, 9, -15> * 5.5; // Matches Anim01 end position
//#declare CameraPosition = <0, 0, -20>;

#declare CameraLookAt = CameraLookAt + z * 14 - y * 6;
#declare CameraPosition = CameraPosition + z * 14;

#include "Scene.inc"

#declare PartPosition = array[NumPartsL2];
#declare PartRotation = array[NumPartsL2];

#declare NumBulky = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare NumBulky[I] = 0;
#end

#for (I, 0, NumPartsL2 - 1)
	#local PartType = mod(I, NumParts);

	#declare PartRotation[I] = transform {
		#ifdef (Part_L2_Twist[I])
			rotate x * 90 * (Part_L2_Twist[I] - 1)
		#end
		rotate z * 90
	}
	#declare PartPosition[I] = <
		div(PartType, 4) * 5 - 6.5 - 10,
		mod(PartType, 4) * -4 + 6,
		div(I, NumParts) * 2 + 8
	>;
#end

#declare RestorePosition = array[NumParts];
#declare RestoreRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#ifdef (Part_L2_Twist[I])
		#local PartIndex = I + NumParts;
	#else
		#local PartIndex = I;
	#end

	// Remember the restore position
	#declare RestorePosition[I] = PartPosition[PartIndex];
	#declare RestoreRotation[I] = PartRotation[PartIndex];

	#declare PartPosition[PartIndex] = PositionForPart(I, 1);
	#declare PartRotation[PartIndex] = RotationForPart(I);
#end

//#for (I, 0, NumParts - 1)
//	box {
//		<-1, -1, -1>, <1, 1, 1>
//		scale 1.5
//
//		translate PositionForPart(I, 9)
//
//		pigment { color PartColor[I] }
//	}
//#end

// Add offset to pieces that are not placed in first layer
#declare P_H_H = P_H_H + 12;
#declare P_HxH = P_HxH + 12;
#declare P_HxX = P_HxX + 12;
#declare P_XxX = P_XxX + 12;

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

#declare RestoreOrder = array[NumParts] {
	5, 3, 2, 7, 10 + 12, 11 + 12, 8 + 12, 9 + 12, 4, 1, 0, 6
};

#declare ClockStart = Now;
#declare MaxNow = Now;

#for (I, 0, NumParts - 1)
  // Move parts in parallel, with delay of 2 clock ticks
	#declare Now = ClockStart + I * 2;

	#declare PartNum = RestoreOrder[I];
	#declare PartType = mod(PartNum, NumParts);
	#declare DeltaV = RestorePosition[PartType] - PartPosition[PartNum];
	#declare DeltaT = ClockTicksForMove(DeltaV);

	#declare Now0 = Now;
	TimedMove(<PartNum + 1, 0, 0>, DeltaV, DeltaT)
	#declare Now = Now0;
	TimedRotateToTransform(<PartNum + 1, 0, 0>, RestoreRotation[PartType], DeltaT)

	#if (PartNum > NumParts)
		// Make room for the part to be plaed in the second layer
		#declare Now0 = Now0 + DeltaT;
		#declare Now = Now0 - 4;
		Move(<PartNum - 11, 0, 0>, x * 2)

		#declare Now = Now0 + 2;
		Move(<PartNum - 11, 0, 0>, -x * 2)
	#end

	#declare MaxNow = max(Now, MaxNow);
#end

#for (I, 0, NumPartsL2 - 1)
	object {
		Part_L2[I]
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end

