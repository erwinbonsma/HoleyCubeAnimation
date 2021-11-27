#include "vectors.inc"
#include "quaternions.inc"

#declare Now = 0;

#macro MatrixFromTransform(T)
	#local vX = <0, 0, 0>;
	#local vY = <0, 0, 0>;
	#local vZ = <0, 0, 0>;
	#local pT = <0, 0, 0>;

	VectorsFromTransform(T, vX, vY, vZ, pT)

	matrix <
		vX.x, vX.y, vX.z,
		vY.x, vY.y, vY.z,
		vZ.x, vZ.y, vZ.z,
		pT.x, pT.y, pT.z
	>
#end

#macro QuaternionFromTransform(T)
	#local M = array[4];
	#for (I, 0, 3)
		#local M[I] = <0, 0, 0>;
	#end

	VectorsFromTransform(T, M[0], M[1], M[2], M[3])

	QFromMatrix(M)
#end

#macro MatrixFromQuaternion(Q)
	#local M = QToMatrix(Q);

	matrix <
		M[0].x, M[0].y, M[0].z,
		M[1].x, M[1].y, M[1].z,
		M[2].x, M[2].y, M[2].z,
		M[3].x, M[3].y, M[3].z
	>
#end

#macro LerpRotation(T0, T1, fraction)
	#local QT0 = QuaternionFromTransform(T0);
	#local QT1 = QuaternionFromTransform(T1);

	#if (Qsc(QDiff(QT0, QT1)) > 0)
		#local QT = QLinear(QT0, QT1, fraction);

		transform {
			MatrixFromQuaternion(QT)
		}
	#else
		#debug "Quaternions are equal"
		transform {}
	#end
#end

#macro LerpTranslation(T0, T1, fraction)
	#local V0 = VectorTransform(<0, 0, 0>, T0);
	#local V1 = VectorTransform(<0, 0, 0>, T1);
	transform {
		translate V0 * (1 - fraction) + fraction * V1
	}
#end

#macro LerpTransform(T0, T1, fraction)
	transform {
		LerpRotation(T0, T1, fraction)
		LerpTranslation(T0, T1, fraction)
	}
//	transform { MatrixFromQuaternion(QuaternionFromTransform(T1)) }
#end

// Pre-condition: t1 > t0
// Returns 0 if tnow < t0
// Returns 1 if tnow > t1
// Otherwise returns lineair interpolation between boundary points
#declare ramp = function(t0, t1, tnow) { (min(t1, max(t0, tnow)) - t0) / (t1 - t0) }

