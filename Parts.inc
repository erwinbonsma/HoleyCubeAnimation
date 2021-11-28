// Defines basic puzzle parts (shape and colors) and their assembly
#include "vectors.inc"

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
#declare PartConnector[1][0] = 0 + 3;
#declare PartConnector[1][1] = 1 + 3;
#declare PartConnector[2][0] = 2;
#declare PartConnector[2][1] = 0 + 3;
#declare PartConnector[3][0] = 1;
#declare PartConnector[3][1] = 0 + 3;

#declare PartConnector[4][0] = 2;
#declare PartConnector[4][1] = 2;
#declare PartConnector[5][0] = 0;
#declare PartConnector[5][1] = 0 + 3;
#declare PartConnector[6][0] = 2 + 3;
#declare PartConnector[6][1] = 0 + 3;
#declare PartConnector[7][0] = 2;
#declare PartConnector[7][1] = 1 + 3;

#declare PartConnector[8][0] = 1;
#declare PartConnector[8][1] = 1 + 3;
#declare PartConnector[9][0] = 1 + 3;
#declare PartConnector[9][1] = 1 + 3;
#declare PartConnector[10][0] = 1 + 3;
#declare PartConnector[10][1] = 2 + 3;
#declare PartConnector[11][0] = 2;
#declare PartConnector[11][1] = 2 + 3;

// Friendly names for the parts (with index +1 offset), for use in move definition
#declare P_I_I =  1;
#declare P_IxI =  6;
#declare P_I_H =  2;
#declare P_IxH =  4;
#declare P_H_H = 10;
#declare P_HxH =  9;
#declare P_I_X =  3;
#declare P_IxX =  7;
#declare P_H_X =  8;
#declare P_HxX = 11;
#declare P_X_X =  5;
#declare P_XxX = 12;


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

// Colors, inspired by PICO-8 palette
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

#macro RotationForPart(N)
	transform {
		#switch(mod(N, 4))
			#case (1)
				rotate x * 90
			#break
			#case (2)
				rotate x * -90
			#break
			#case (3)
				rotate x * 180
			#break
		#end

		#for (I, 0, div(N, 4) - 1)
			rotate x * 90
			rotate z * 90
		#end
	}
#end

#macro _CorePositionForPart(N)
	<0, -1, -1>
#end

#macro PositionForPart(N, D)
	VectorTransform(_CorePositionForPart(N) * D, RotationForPart(N))
#end

// Transforms part N (0..11) so that it is oriented correctly.
// Distance D specifies how much the parts are separated.
// For D=1 the puzzle is assembled. For higher values, it provides an exploded view.
#macro TransformForPart(N, D)
	transform {
		translate _CorePositionForPart(N) * D
		RotationForPart(N)
	}
#end

// Rotation for L2 parts so that:
// - in (nearly) all sides of the L2 cube, all four center cubes are oriented 
//   differently
// - each part-type has a big connector to it attached four times
#declare PartRotation_L2 = array[12];
#declare PartRotation_L2[0] = <90, 0, 0>;
#declare PartRotation_L2[1] = <0, 0, 180>;
#declare PartRotation_L2[2] = <180, 0, 0>;
//#declare PartRotation_L2[3] = <180, 0, 0>;
#declare PartRotation_L2[4] = <90, 0, 0>;
#declare PartRotation_L2[6] = <0, 180, 0>;
#declare PartRotation_L2[7] = <180, 0, 0>;
#declare PartRotation_L2[8] = <90, 0, 0>;
#declare PartRotation_L2[9] = <90, 0, 0>;
#declare PartRotation_L2[10] = <180, 0, 0>;
//#declare PartRotation_L2[11] = <0, 180, 0>;

#macro Part_L1(N)
	union {
		difference {
			box {
				<-0.5, -0.5, -0.5>, <0.5, 0.5, 0.5>
			}

//			// TEMP: Add markers to sides of box for checking orientation
//			#local R = 1/6;
//			cylinder {
//				<0, 0, -0.4>, <0, 0, -0.51>, R
//			}
//			box {
//				<-R, -0.4, -R>, <R, -0.51, R>
//			}
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
