#include "Parts.inc"

#declare NumPartsL2 = NumParts * NumParts;
#declare TotalParts = NumPartsL2;

// Rotation for L2 parts so that:
// - in (nearly) all sides of the L2 cube, all four center cubes are oriented 
//   differently
// - each part-type has a big connector to it attached four times
#declare PartRotation_L2 = array[12];
#declare PartRotation_L2[0] = <90, 0, 0>;
#declare PartRotation_L2[1] = <0, 0, 180>;
#declare PartRotation_L2[2] = <180, 0, 0>;
#declare PartRotation_L2[3] = <90, 180, 0>;
#declare PartRotation_L2[4] = <90, 0, 0>;
#declare PartRotation_L2[6] = <0, 180, 0>;
#declare PartRotation_L2[7] = <180, 0, 0>;
#declare PartRotation_L2[8] = <90, 0, 0>;
#declare PartRotation_L2[9] = <-90, 0, 0>;
#declare PartRotation_L2[10] = <180, 0, 0>;
//#declare PartRotation_L2[11] = <0, 180, 0>;

#macro _RotateMapping(Mapping, Twisted, TransferTable, TwistedTable, Angle)
	#while (Angle < 0)
		#local Angle = Angle + 360;
	#end
	#while (Angle > 0)
		#local TwistedNew = array[NumParts];
		#local MappingNew = array[NumParts];
		#for (I, 0, NumParts - 1)
			#local TwistedNew[I] = mod(Twisted[TransferTable[I]] + TwistedTable[I], 2);
			#local MappingNew[I] = Mapping[TransferTable[I]];
		#end
		#for (I, 0, NumParts - 1)
			#declare Twisted[I] = TwistedNew[I];
			#declare Mapping[I] = MappingNew[I];
		#end
		#local Angle = Angle - 90;
	#end
#end

#macro OutputMapping(Mapping)
	#local S = "";
	#for (I, 0, NumParts - 1)
		#if (I > 0)
			#local S = concat(S, ", ");
		#end
		#local S = concat(S, str(Mapping[I], 0, 0));
	#end
	#debug concat(S, "\n")
#end

// Mapping: From Position to Part
#macro RotatePartsMapping(Mapping, Twisted, RotV)
	// Loops: 0-1-3-2, 6-11-7-9, 4-10-5-8
	#local TransferTableX = array[NumParts] {
		2, 0, 3, 1, 8, 10, 9, 11, 5, 7, 4, 6
	}
	// Loops: 4-6-7-5, 0-9-2-8, 1-11-3-10
	#local TransferTableY = array[NumParts] {
		9, 11, 8, 10, 6, 4, 7, 5, 0, 2, 1, 3
	}
	// Loops: 8-9-11-10, 0-6-1-4, 2-7-3-5
	#local TransferTableZ = array[NumParts] {
		4, 6, 5, 7, 1, 3, 0, 2, 10, 8, 11, 9
	}

	// These tables indicate the positions where the part "twisted" orientation flips
	// as a result of the rotation.
	#local TwistedTableX = array[NumParts] { 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 };
	#local TwistedTableY = array[NumParts] { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 };
	#local TwistedTableZ = array[NumParts] { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 };

	_RotateMapping(Mapping, Twisted, TransferTableX, TwistedTableX, RotV.x)
	_RotateMapping(Mapping, Twisted, TransferTableY, TwistedTableY, RotV.y)
	_RotateMapping(Mapping, Twisted, TransferTableZ, TwistedTableZ, RotV.z)
#end

// Returns the part number of the L1-Cube where to attach the connector for
// L2 part, where:
// - PartNum in [0, 11] - Identifies the L2 part to construct
// - PartEnd in [0, 1] - Identifies the side where to attach the connector
// - ConnectorHalf in [0, 1] - Identifies the connector half
#macro AttachPointForL2Connector(PartNum, PartEnd, ConnectorHalf)
	#local ConnectorAttachPoints = array[8] {
		4, 5, 10, 8, 7, 6, 9, 11
	}

	#local AttachPoint = ConnectorAttachPoints[
		PartEnd * 4 + div(PartConnector[PartNum][PartEnd], 3) * 2 + ConnectorHalf
	];

	AttachPoint
#end

#declare Part_L2 = array[NumPartsL2];
#declare Part_L2_AttachPoint = array[NumPartsL2];
#declare Part_L2_Twist = array[NumPartsL2];

// Create L2 parts
#local InvPartRotations = array[3] {
	<0, 0, 0>, <-90, -90, 0>, <90, 0, 90>
}
#for (I, 0, NumParts - 1)
	#local PartsMapping = array[NumParts] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
	#local Twisted = array[NumParts] {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	#local InvPartRotation = InvPartRotations[div(I, 4)];

	#debug concat("Part ", str(I,0,0), "\n")

	RotatePartsMapping(PartsMapping, Twisted, InvPartRotation)
	RotatePartsMapping(PartsMapping, Twisted, -x * XRotationForPart(I))

	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(PartsMapping, Twisted, PartRotation_L2[I])
	#end

	#for (J, 0, NumParts - 1)
		#local PartType = PartsMapping[J];
		#local Index = I * NumParts + PartType;
		#declare Part_L2[Index] = Part_L1(PartType)
		#debug concat("I=", str(I,0,0), ", J=", str(J,0,0), ", T=", str(PartType,0,0), "\n")
	#end

	#for (J, 0, 1)
		#for (H, 0, 1)
			#local AP = AttachPointForL2Connector(I, J, H);
			#debug concat("I=", str(I,0,0), ", J=", str(J,0,0), ", H=", str(H,0,0), ", AP=", str(AP,0,0), "\n")
			#local PartType = PartsMapping[AP];
			#local Index = I * NumParts + PartType;
			#local Twist = mod(H + Twisted[AP], 2);

			#declare Part_L2_AttachPoint[Index] = AP;
			#declare Part_L2_Twist[Index] = Twist;
			#declare Part_L2[Index] = union {
				object {
					Part_L2[Index]
				}

				// L2 connector
				difference {
					object {
						Connector[mod(PartConnector[I][J], 3)]
					}
					plane { -z, 0 }
					translate z * 1/3
					rotate x * 90 * (2 * Twist - 1)

					scale 3
					translate x * 2
					rotate y * 90

					rotate x * -90 * Twist

					pigment { color PartColor[PartType] }
				}
			}
		#end
	#end
#end