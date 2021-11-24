#include "Scene.inc"
#include "Parts.inc"
#include "Anim.inc"

// Order parts by increasing weight
#declare InitialPartTransform = array[NumParts];

// Part 1: I I
#declare InitialPartTransform[0] = transform {
	rotate x * 90
	translate <0, 0, 0>
}
#declare InitialPartTransform[5] = transform {
	translate <0, -2, 0>
}

// Part 2: I H
#declare InitialPartTransform[1] = transform {
	rotate x * 90
	translate <0, -4, 0>
}
#declare InitialPartTransform[3] = transform {
	rotate y * 180
	translate <0, -6, 0>
}

// Part 3: H H
#declare InitialPartTransform[9] = transform {
	rotate x * 90
	translate <4, 0, 0>
}
#declare InitialPartTransform[8] = transform {
	rotate x * 90
	translate <4, -2, 0>
}

// Part 4: I X
#declare InitialPartTransform[2] = transform {
	rotate x * 90
	rotate y * 180
	translate <4, -4, 0>
}
#declare InitialPartTransform[6] = transform {
	rotate x * 90
	rotate y * 180
	translate <4, -6, 0>
}

// Part 5: H X
#declare InitialPartTransform[7] = transform {
	rotate y * 180
	translate <8, 0, 0>
}
#declare InitialPartTransform[10] = transform {
	rotate x * 90
	translate <8, -2, 0>
}

// Part 6: X X
#declare InitialPartTransform[4] = transform {
	translate <8, -4, 0>
}
#declare InitialPartTransform[11] = transform {
	translate <8, -6, 0>
}

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

#declare PartTransform = array[NumParts];
#for (I, 0, NumParts - 1)
	#declare PartTransform[I] = transform {
		transform { InitialPartTransform[I] }
		translate <-5, 3, 10>
	};
#end

#declare MoveSpeed = 1;

#for (I, 0, NumParts - 1)
	#declare PartNum = AssemblyOrder[I];
	#declare MoveDist = vlength(
		VectorTransform(<0, 0, 0>, PartTransform[PartNum]) -
		VectorTransform(<0, 0, 0>, TransformForPart(PartNum, 3))
	);

	#if (clock > Now)
		#declare PartTransform[PartNum] = LerpTransform(
			PartTransform[PartNum],
			TransformForPart(PartNum, 3),
			ramp(Now, Now + MoveDist / MoveSpeed, clock)
		);
	#end

	#declare Now = Now + 4;
#end

#for (I, 0, NumParts - 1)
	object {
		Part(I)
		pigment { color rgb PartColor[I] }
		transform { PartTransform[I] }
	}
#end
