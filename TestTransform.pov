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

object {
	cylinder {
		<-1, 0, 0>, <1, 0, 0>, 0.5
	}
	transform {
		Test(
			QFromMatrix(array[4] { <1, 0, 0>, <-0, 1, 0>, <0, -0, 1>, <0, 0, 0>}),
			QFromMatrix(array[4] { <0, 1, 0>, <-1, 0, 0>, <0, 0, 1>, <0, 0, 0>}),
			0.512
		)
	}

	pigment { color Red }
}

union {
	cylinder {
		<-10, 0, 0>, <10, 0, 0>, 0.1
	}
	cylinder {
		<0, -10, 0>, <0, 10, 0>, 0.1
	}
	cylinder {
		<0, 0, -10>, <0, 0, 10>, 0.1
	}
	pigment { color White }
}
