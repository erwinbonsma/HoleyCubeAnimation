#include "colors.inc"

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
				<-1/2, -1/2, -1/6>, <-1/6, 1/2, 1/6>
			}
			box {
				<1/6, -1/2, -1/6>, <1/2, 1/2, 1/6>
			}
			box {
				<-1/2, -1/6, -1/6>, <1/2, 1/6, 1/6>
			}
			translate z * (2 * I - 1) / 3
		}
	#end
}


#declare PartConnector = array[NumParts][2];

#declare PartConnector[0][0] = 0;
#declare PartConnector[0][1] = 0;
#declare PartConnector[1][0] = 0;
#declare PartConnector[1][1] = 1;
#declare PartConnector[2][0] = 2 + 3;
#declare PartConnector[2][1] = 0;
#declare PartConnector[3][0] = 1;
#declare PartConnector[3][1] = 0 + 3;

#declare PartConnector[4][0] = 2;
#declare PartConnector[4][1] = 2;
#declare PartConnector[5][0] = 0 + 3;
#declare PartConnector[5][1] = 0;
#declare PartConnector[6][0] = 2;
#declare PartConnector[6][1] = 0;
#declare PartConnector[7][0] = 2;
#declare PartConnector[7][1] = 1 + 3;

#declare PartConnector[8][0] = 1;
#declare PartConnector[8][1] = 1 + 3;
#declare PartConnector[9][0] = 1;
#declare PartConnector[9][1] = 1;
#declare PartConnector[10][0] = 1;
#declare PartConnector[10][1] = 2;
#declare PartConnector[11][0] = 2;
#declare PartConnector[11][1] = 2 + 3;

#macro hex2rgb(hexString)
	#macro hex2dec (hexChar)
		#local V = asc(strupr(hexChar));
		(V > 64 ? V - 55 : V - 48)
	#end

	<
		16*hex2dec(substr(hexString, 1, 1))+hex2dec(substr(hexString, 2, 1)),
		16*hex2dec(substr(hexString, 3, 1))+hex2dec(substr(hexString, 4, 1)),
		16*hex2dec(substr(hexString, 5, 1))+hex2dec(substr(hexString, 6, 1))
	> / 255
#end

#declare PartColor = array[NumParts];

#declare PartColor[0] = hex2rgb("1d2b53");
#declare PartColor[1] = hex2rgb("7e2553");
#declare PartColor[2] = hex2rgb("008751");
#declare PartColor[3] = hex2rgb("ab5236");

#declare PartColor[4] = hex2rgb("ff004d");
#declare PartColor[5] = hex2rgb("ffc300"); // hex2rgb("ffa300");
#declare PartColor[6] = hex2rgb("ff8000"); // hex2rgb("ffec27");
#declare PartColor[7] = hex2rgb("00e436");

#declare PartColor[8] = hex2rgb("29adff");
#declare PartColor[9] = <1, 0, 0.1>;
#declare PartColor[10] = hex2rgb("ff77a8");
#declare PartColor[11] = hex2rgb("065ab5");


#macro OrientationForRod(N, D)
	transform {
		translate <0, -1 + 2 * mod(N, 2), -1 + 2 * mod(div(N, 2), 2)> * D

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

//#debug concat("V =", vstr(3, PartColor[4], ", ", 0, 2), "\n")

//#for (K, 0, 11)
//	union {
		#for (J, 0, 11)
			union {
				#for (I, 0, NumParts - 1)
					object {
						Part(I)
						pigment { color rgb PartColor[I] }
						OrientationForRod(I, 1)
					}
				#end
				OrientationForRod(J, 3)
			}
		#end
//		OrientationForRod(K, 9)
//	}
//#end
