#include "Scene.inc"
#include "Parts.inc"
#include "Anim.inc"

// Order parts by increasing weight
#declare InitialPartPosition = array[NumParts];

// Orient parts consistently
#declare InitialPartRotation = array[NumParts];

// Part 1: I I
#declare InitialPartPosition[0] = <0, 0, 0>;
#declare InitialPartRotation[0] = transform {
	rotate x * 90
}
#declare InitialPartPosition[5] = <0, -2, 0>;

// Part 2: I H
#declare InitialPartPosition[1] = <0, -4, 0>;
#declare InitialPartRotation[1] = transform {
	rotate x * 90
}
#declare InitialPartPosition[3] = <0, -6, 0>;
#declare InitialPartRotation[3] = transform {
	rotate y * 180
}

// Part 3: H H
#declare InitialPartPosition[9] = <4, 0, 0>;
#declare InitialPartRotation[9] = transform {
	rotate x * 90
}
#declare InitialPartPosition[8] = <4, -2, 0>;
#declare InitialPartRotation[8] = transform {
	rotate x * 90
}

// Part 4: I X
#declare InitialPartPosition[2] = <4, -4, 0>;
#declare InitialPartRotation[2] = transform {
	rotate x * 90
	rotate y * 180
}
#declare InitialPartPosition[6] = <4, -6, 0>;
#declare InitialPartRotation[6] = transform {
	rotate x * 90
	rotate y * 180
}

// Part 5: H X
#declare InitialPartPosition[7] = <8, 0, 0>;
#declare InitialPartRotation[7] = transform {
	rotate y * 180
}
#declare InitialPartPosition[10] = <8, -2, 0>;
#declare InitialPartRotation[10] = transform {
	rotate x * 90
}

// Part 6: X X
#declare InitialPartPosition[4] = <8, -4, 0>;
#declare InitialPartPosition[11] = <8, -6, 0>;

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

// Show parts
//camera {
//	perspective
//	location z * -50
//	right x * 1
//	up y * 3/4
//	angle 20
//	look_at < 0.0, 0.0, 0.0>
//	rotate x * 30
//	rotate y * 10
//	translate z * 8
//}

// Animate to exploded assembly
camera {
	perspective
	location z * -50
	right x * 1
	up y * 3/4
	angle 20
	look_at < 0.0, 0.0, 0.0>
	translate <-3, 1, 0>
	rotate x * 30
	rotate y * 40
}


//union {
//	#for (I, 0, NumParts - 1)
//		object {
//			Part(I)
//			pigment { color rgb PartColor[I] }
//			transform {
//				InitialPartTransform[I]
//			}
//		}
//	#end
//	translate <-5, 3, 10>
//	//rotate y * 45
//}
//
//#for (I, 0, NumParts - 1)
//	object {
//		Part(I)
//		pigment { color rgb PartColor[I] }
//		TransformForPart(I, 3)
//	}
//#end

#declare PartPosition = array[NumParts];
#declare PartRotation = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartPosition[I] = InitialPartPosition[I] + <-5, 3, 10>;
	#ifdef (InitialPartRotation[I])
		#declare PartRotation[I] = InitialPartRotation[I];
	#else
		#declare PartRotation[I] = transform {}
	#end
#end

#declare MoveSpeed = 1;

// Move to exploded pre-assembly
#for (I, 0, NumParts - 1)
	#if (clock > Now)
		#declare PartNum = AssemblyOrder[I];
		#declare MoveV = PositionForPart(PartNum, 3) - PartPosition[PartNum];
		#declare MoveDist = vlength(MoveV);
		#declare T = ramp(Now, Now + MoveDist / MoveSpeed, clock);

		#declare PartPosition[PartNum] = PartPosition[PartNum] + T * MoveV;
		#declare PartRotation[PartNum] = transform {
			LerpRotation(PartRotation[PartNum], RotationForPart(PartNum), T)
		};
	#end

	#declare Now = Now + 4;
#end

#for (I, 0, NumParts - 1)
	object {
		Part(I)
		pigment { color rgb PartColor[I] }
		transform { PartRotation[I] }
		translate PartPosition[I]
	}
#end
