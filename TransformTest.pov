//Persistence of Vision Ray Tracer Scene Description File

#include "colors.inc"

#include "Anim.inc"

camera {
	orthographic
	location < 3, 2, -5> * 2
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
	rotate <-90, 0, 0>
	translate <-5, 1, 1>
}

#declare Transform2 = transform {
  rotate <0, 0, 0>
	translate <5, 2, 3>
}

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


