#declare TotalParts = 1;

#include "Globals.inc"
#include "Moves.inc"

#declare PartRotation = array[1]

#macro Test(QT0, QT1, Fraction)
	#debug concat("QT0: ", QuaternionToString(QT0), "\n")
	#debug concat("QT1: ", QuaternionToString(QT1), "\n")

	#if (Qsc(QDiff(QT0, QT1)) > 0)
		#local QT = QLinear(QT0, QT1, Fraction);
		#debug concat("Fraction = ", str(Fraction, 0, 3), "\n")
		#debug concat("QT:  ", QuaternionToString(QT), "\n")

		transform {
			MatrixFromQuaternion(QT)
		}
	#end
#end

#declare CameraPosition = <-10, 5, -20>;
#include "Scene.inc"

//object {
//	cylinder {
//		<-1, 0, 0>, <1, 0, 0>, 0.5
//	}
//	transform {
//		Test(
//			QFromMatrix(array[4] { <1, 0, 0>, <-0, 1, 0>, <0, -0, 1>, <0, 0, 0>}),
//			QFromMatrix(array[4] { <0, 1, 0>, <-1, 0, 0>, <0, 0, 1>, <0, 0, 0>}),
//			0.512
//		)
//	}
//
//	pigment { color Red }
//}

//union {
//	cylinder {
//		<-10, 0, 0>, <10, 0, 0>, 0.1
//	}
//	cylinder {
//		<0, -10, 0>, <0, 10, 0>, 0.1
//	}
//	cylinder {
//		<0, 0, -10>, <0, 0, 10>, 0.1
//	}
//	pigment { color White }
//}

#declare TestObject = union {
	cylinder { <0, -0.5, 0>, <0, 0.5, 0>, 0.2 }
	box { <-0.1, 0.4, 0>, <0.1, 0.5, -0.3> }
	pigment { color White }
	rotate z * -90
}

#for (I, 0, 3)
	#local T = transform {
		rotate x * 90 * I
		rotate z * 90
		rotate x * 90
		rotate z * 90
	}

	#local M = array[4]
	TransformToMatrix(T, M)
	#debug concat(MatrixToString(M), "\n")

	#local T1 = transform {
		matrix <
			M[0].x, M[0].y, M[0].z,
			M[1].x, M[1].y, M[1].z,
			M[2].x, M[2].y, M[2].z,
			M[3].x, M[3].y, M[3].z
		>
	}

	#local Q = QFromMatrix(M);
	#local T2 = transform {
		MatrixFromQuaternion(Q)
	}

	object {
		TestObject
		transform { T }
		translate <I * 2, 2, 0>
	}

	object {
		TestObject
		transform { T1 }
		translate <I * 2, 0, 0>
	}

	object {
		TestObject
		transform { T2 }
		translate <I * 2, -2, 0>
	}
#end
