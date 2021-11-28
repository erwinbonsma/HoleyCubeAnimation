#include "Scene.inc"
#include "Parts.inc"
#include "Moves.inc"
#include "Anim.inc"

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

// Part 2: I H
#declare InitialPartPosition[P_I_H - 1] = <0, -4, 0>;
#declare InitialPartRotation[P_I_H - 1] = transform {
	rotate x * 90
}
#declare InitialPartPosition[P_IxH - 1] = <0, -6, 0>;
#declare InitialPartRotation[P_IxH - 1] = transform {
	rotate y * 180
}

// Part 3: H H
#declare InitialPartPosition[P_H_H - 1] = <4, 0, 0>;
#declare InitialPartRotation[P_H_H - 1] = transform {
	rotate x * 90
}
#declare InitialPartPosition[P_HxH - 1] = <4, -2, 0>;
#declare InitialPartRotation[P_HxH - 1] = transform {
	rotate x * 90
}

// Part 4: I X
#declare InitialPartPosition[P_I_X - 1] = <4, -4, 0>;
#declare InitialPartRotation[P_I_X - 1] = transform {
	rotate x * 90
	rotate y * 180
}
#declare InitialPartPosition[P_IxX - 1] = <4, -6, 0>;
#declare InitialPartRotation[P_IxX - 1] = transform {
	rotate x * 90
	rotate y * 180
}

// Part 5: H X
#declare InitialPartPosition[P_H_X - 1] = <8, 0, 0>;
#declare InitialPartRotation[P_H_X - 1] = transform {
	rotate y * 180
}
#declare InitialPartPosition[P_HxX - 1] = <8, -2, 0>;
#declare InitialPartRotation[P_HxX - 1] = transform {
	rotate x * 90
}

// Part 6: X X
#declare InitialPartPosition[P_X_X - 1] = <8, -4, 0>;
#declare InitialPartPosition[P_XxX - 1] = <8, -6, 0>;

#declare AssemblyOrder = array[NumParts];

#declare AssemblyOrder[0] = 6;
#declare AssemblyOrder[1] = 0;
#declare AssemblyOrder[2] = 1;
#declare AssemblyOrder[3] = 4;

#declare AssemblyOrder[4] = 9;
#declare AssemblyOrder[5] = 8;
#declare AssemblyOrder[6] = 11;
#declare AssemblyOrder[7] = 10;

#declare AssemblyOrder[8] = 7;
#declare AssemblyOrder[9] = 2;
#declare AssemblyOrder[10] = 3;
#declare AssemblyOrder[11] = 5;

#macro Part(N)
	union {
		box {
			<-0.5, -0.5, -0.5>, <0.5, 0.5, 0.5>
		}
		#for (I, 0, 1)
			object {
				Connector[mod(PartConnector[N][I], 3)]
				rotate x * 90 * div(PartConnector[N][I], 3)
				translate x * (-1 + 2 * I)
			}
		#end
	}
#end

#declare CameraPosition = <0, 12, -30>;
#declare CameraLookAt = <-15, 0, 10>;

MoveVector(CameraLookAt, <0, 0, 10>, 4)

#declare Now0 = Now;
MoveVector(CameraLookAt, <0, 0, 4>, 7)
#declare Now = Now0;
MoveVector(CameraPosition, <-23, 15, -25> * 1.2, 7)
#declare Now = Now0;

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

ResetPuzzleTransform()

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

#declare Now = MaxNow - 3;
MoveVector(CameraLookAt, <0, 0, 0>, 4)

#declare Now = Now + 2;

//--------------------------------------
// Assemble both puzzle

#declare MoveSpeed = 1;

// Assemble first half
Move(<P_XxX, 0, 0>, -z * 2)
Move(<P_I_H, 0, 0>, x * 2)
Move(<P_XxX, P_I_H, 0>, -y * 2)

Move(<P_H_X, 0, 0>, -z * 4)
#declare Now = Now - 2;
Move(<P_H_H, 0, 0>, -z * 2)

Move6(<P_XxX, P_I_H, P_H_X>, <P_IxX, 0, 0>, -y * 2)

Move(<P_I_I, 0, 0>, x * 2)

// Assemble second half
Move(<P_HxX, 0, 0>, z * 2)
Move(<P_IxH, 0, 0>, -x * 2)
Move(<P_HxX, P_IxH, 0>, -y * 2)

Move(<P_HxH, 0, 0>, z * 2)
#declare Now = Now - 2;
Move(<P_I_X, 0, 0>, -x * 2)

#declare Now = Now - 1;
Move(<P_X_X, 0, 0>, z * 4)

Move(<P_HxH, P_I_X, 0>, y * 2)


// Assemble both halves
#declare Now0 = Now;
Move6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, <0, 2, 2>)
#declare D = Now - Now0;
#declare Now = Now0;
TimedMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, <0, 0, -2>, D)

#declare Now = Now0;
MoveVector(CameraPosition, CameraPosition * 0.7, D)

#declare Now0 = Now;
SlowMove6(<P_XxX, P_I_H, P_H_X>, <P_IxX, P_I_I, P_H_H>, -x * 2)
#declare Now = Now0;
SlowMove6(<P_X_X, P_IxH, P_HxX>, <P_I_X, P_IxI, P_HxH>, x * 2)

// Rotate assembled puzzle

RotatePuzzle(<0, 360, 0>, 8)
RotatePuzzle(<360, 0, 0>, 8)

// Place camera based on position and look at vector

#declare CameraV = CameraPosition - CameraLookAt;
#declare CameraD = vlength(CameraV);
#declare CameraD2 = sqrt(pow(CameraD, 2) - pow(CameraV.y, 2));

camera {
	perspective
	location <0, 0, -CameraD>
	right x * 1
	up y * 9/16
	angle 30
	look_at <0, 0, 0>

	rotate x * degrees(asin(CameraV.y / CameraD))
	rotate y * -degrees(asin(CameraV.x / CameraD2))

	translate  CameraLookAt
}

// Show puzzle parts

#for (I, 0, NumParts - 1)
	object {
		Part(I)
		pigment { color rgb PartColor[I] }
		transform { PartRotation[I] }
		translate PartPosition[I]
		transform { PuzzleTransformForPart(I) }
	}
#end

//sphere {
//	<0, 0, 0>, 1.5
//	pigment { color White }
//}
