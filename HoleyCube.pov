#include "colors.inc"

#include "Parts.inc"

global_settings {
	ambient_light rgb <0.666667, 0.666667, 0.666667>
	irid_wavelength rgb <0.999767, 0.147190, 0.000000>
	assumed_gamma 1.0	
}


camera {
	perspective 
	location z * -50
	right x * 1
	up y * 3/4
	angle 20
	look_at < 0.0, 0.0, 0.0>
	rotate x * 30
	rotate y * 45
}

light_source {
	<-38, 80, -20>
	rgb <1.000000, 1.000000, 1.000000> * 1.0
}



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

//#debug concat("V =", vstr(3, PartColor[4], ", ", 0, 2), "\n")

////#for (K, 0, 11)
////	union {
//		#for (J, 0, 11)
//			union {
				#for (I, 0, NumParts - 1)
					object {
						Part(I)
						pigment { color rgb PartColor[I] }
						TransformForPart(I, 3)
					}
				#end
//				OrientationForRod(J, 3)
//			}
//		#end
////		OrientationForRod(K, 9)
////	}
////#end
