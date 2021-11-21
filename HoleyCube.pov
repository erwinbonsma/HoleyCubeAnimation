#include "colors.inc"

global_settings {
	ambient_light rgb <0.666667, 0.666667, 0.666667>
	irid_wavelength rgb <0.999767, 0.147190, 0.000000>
	assumed_gamma 1.0	
}


camera {
	perspective 
	location z * -40
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


#declare NumParts = 12;

#declare Connector = array[3];

#declare Connector[0] = union {
	box {
		<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
		translate z * -1/3
	}
	box {
		<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
		translate z * 1/3
	}
}
#declare Connector[1] = union {
	box {
		<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
		translate z * -1/3
	}
	box {
		<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
		translate z * 1/3
	}
	box {
		<-1/6, -1/6, -1/2>, <1/6. 1/6, 1/2>
	}
}
#declare Connector[2] = union {
	#for (I, 0, 1)
		union {
			box {
				<-1/2, -1/6, -1/2>, <-1/6, 1/6, 1/2>
			}
			box {
				<1/6, -1/6, -1/2>, <1/2, 1/6, 1/2>
			}
			box {
				<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
			}
			translate y * (2 * I - 1) / 3 
		}
	#end
}


#declare PartConnector = array[NumParts][2];

#declare PartConnector[0][0] = 0;
#declare PartConnector[0][1] = 0;
#declare PartConnector[1][0] = 0 + 3;
#declare PartConnector[1][1] = 1 + 3;
#declare PartConnector[2][0] = 1;
#declare PartConnector[2][1] = 0 + 3;
#declare PartConnector[3][0] = 2 + 3;
#declare PartConnector[3][1] = 0 + 3;

#declare PartConnector[4][0] = 2 + 3;
#declare PartConnector[4][1] = 2 + 3;
#declare PartConnector[5][0] = 0;
#declare PartConnector[5][1] = 0 + 3;
#declare PartConnector[6][0] = 2 + 3;
#declare PartConnector[6][1] = 1 + 3;
#declare PartConnector[7][0] = 2;
#declare PartConnector[7][1] = 0 + 3;

#declare PartConnector[8][0] = 1;
#declare PartConnector[8][1] = 1 + 3;
#declare PartConnector[9][0] = 1 + 3;
#declare PartConnector[9][1] = 1 + 3;
#declare PartConnector[10][0] = 2 + 3;
#declare PartConnector[10][1] = 2;
#declare PartConnector[11][0] = 1 + 3;
#declare PartConnector[11][1] = 2;



#macro OrientationForRod(N)
	transform {
		translate <0, -3, -3>
		rotate x * 90 * mod(N, 4)
		#for (I, 0, div(N, 4) - 1)
			rotate x * 90
			rotate z * 90 
		#end
	}
#end

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

#for (I, 0, NumParts - 1)
	object {
		Part(I)
		pigment { color Red }
		OrientationForRod(I)
	}
#end
