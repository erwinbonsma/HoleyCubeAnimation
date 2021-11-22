//Persistence of Vision Ray Tracer Scene Description File

#include "colors.inc"
#include "vectors.inc"

camera {
	orthographic
	location < 3, 5, -5> * 2
	right x * 1
	up y * 3/4
	angle 60
	look_at < 0.0, 0.0, 0.0>
}

light_source {
	< -50, 20, -80>
	rgb <1.000000, 1.000000, 1.000000> * 1.0
}

#declare Object = union {
	cylinder {
		<0, 0, 0>,
		<0, 1, 0>, 0.2
	}
	box {
		<-0.2, 1, -0.2>,
		< 0.6, 1.1, 0.2>
	}
}

#declare Transform1 = transform {
	rotate <-30, 20, -40>
	translate <0, 0, 0>
}

#declare Transform2 = transform {
  rotate <90, 90, 180>
	translate <5, 2, 3>
}

#macro LerpTransform(T0, T1, T)
	#local vX0 = <0, 0, 0>;
	#local vY0 = <0, 0, 0>;
	#local vZ0 = <0, 0, 0>;
	#local pT0 = <0, 0, 0>;

	#local vX1 = <0, 0, 0>;
	#local vY1 = <0, 0, 0>;
	#local vZ1 = <0, 0, 0>;
	#local pT1 = <0, 0, 0>;

	VectorsFromTransform(T0, vX0, vY0, vZ0, pT0)
	VectorsFromTransform(T1, vX1, vY1, vZ1, pT1)

	#local vX = (1 - T) * vX0 + T * vX1;
	#local vY = (1 - T) * vY0 + T * vY1;
	#local vZ = (1 - T) * vZ0 + T * vZ1;
	#local pT = (1 - T) * pT0 + T * pT1;

	TransformFromVectors(vX, vY, vZ, pT)
#end

object {
	Object
	pigment { color Red }
	transform { Transform1 }
}

object {
	Object
	pigment { color Red }
	transform { Transform2 }
}

#for (I, 0.1, 0.9, 0.1)
	object {
		Object
		pigment { color Green }
		LerpTransform(Transform1, Transform2, I)
	}
#end


