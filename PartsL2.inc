/* Holey Puzzle POV-Ray Animation
 *
 * Include file that defines the Level 2 puzzle parts
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

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
#declare PartRotation_L2[4] = <-90, 0, 0>;
#declare PartRotation_L2[6] = <0, 180, 0>;
#declare PartRotation_L2[7] = <180, 0, 0>;
#declare PartRotation_L2[8] = <90, 0, 0>;
#declare PartRotation_L2[9] = <-90, 0, 180>;
#declare PartRotation_L2[10] = <180, 0, 180>;
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

#macro MappingToString(Mapping)
	#local S = "";
	#for (I, 0, NumParts - 1)
		#if (I > 0)
			#local S = concat(S, ", ");
		#end
		#local S = concat(S, str(Mapping[I], 0, 0));
	#end
	S
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

#macro InitPartsMapping(Mapping, Twisted)
	#for (I, 0, NumParts - 1)
		#declare Mapping[I] = I;
		#declare Twisted[I] = 0;
	#end
#end

#macro UpdateMappingForPartTransform(N, Mapping, Twisted)
	#local PartRotations = array[3] {
		<0, 0, 0>, <90, 0, 90>, <0, -90, -90>
	}

	RotatePartsMapping(Mapping, Twisted, x * XRotationForPart(N))
	RotatePartsMapping(Mapping, Twisted, PartRotations[div(N, 4)])
#end

#macro UpdateMappingForInversePartTransform(N, Mapping, Twisted)
	#local InvPartRotations = array[3] {
		<0, 0, 0>, <-90, -90, 0>, <90, 0, 90>
	}

	RotatePartsMapping(Mapping, Twisted, InvPartRotations[div(N, 4)])
	RotatePartsMapping(Mapping, Twisted, -x * XRotationForPart(N))
#end

//--------------------------------------
// Create L2 parts

#declare Part_L2 = array[NumPartsL2];
#declare Part_L2_AttachPoint = array[NumPartsL2];
#declare Part_L2_Twist = array[NumPartsL2];

#for (I, 0, NumParts - 1)
	#local PartsMapping = array[NumParts]
	#local Twisted = array[NumParts]

//	#debug concat("Part ", str(I,0,0), "\n")
	InitPartsMapping(PartsMapping, Twisted)
	UpdateMappingForInversePartTransform(I, PartsMapping, Twisted)
	#ifdef (PartRotation_L2[I])
		RotatePartsMapping(PartsMapping, Twisted, PartRotation_L2[I])
	#end

	#for (J, 0, NumParts - 1)
		#local PartType = PartsMapping[J];
		#local Index = I * NumParts + PartType;
		#declare Part_L2[Index] = Part_L1(PartType)
//		#debug concat("I=", str(I,0,0), ", J=", str(J,0,0), ", T=", str(PartType,0,0), "\n")
	#end

	#for (J, 0, 1)
		#for (H, 0, 1)
			#local AP = AttachPointForL2Connector(I, J, H);
//			#debug concat("I=", str(I,0,0), ", J=", str(J,0,0), ", H=", str(H,0,0), ", AP=", str(AP,0,0), "\n")
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

				// Move object so that its origin is at its actual center
				//
				// This leads to more-contained rotations, which looks more natural but also
				// reduces chance of path collisions when moving parts to exploded layout.
				translate 1.5 * <0, Twist, 1 - Twist>
			}
		#end
	#end
#end

//--------------------------------------
// Place L2 parts

// The order (in puzzle position) how the parts should be moved to their exploded
// position. The order is from front to back, so that puzzle parts do not need to
// move across parts already placed.
#declare AssemblyOrderL2 = array[NumParts] { 0, 1, 6, 4, 9, 8, 11, 10, 7, 2, 3, 5 };

// Places the L2 parts in a start grid. Note, the Z position is not yet set.
// This should be done later, based on the order in which the parts move into the
// exploded configuration.
#macro InitStartingPlacementL2_Z0(PartPosition, PartRotation)
	#for (I, 0, NumPartsL2 - 1)
		#declare PartRotation[I] = transform {
			#ifdef (Part_L2_Twist[I])
				rotate x * 90 * (Part_L2_Twist[I] - 1)
			#end
			rotate z * 90
		}

		#local PartTypeL2 = div(I, NumParts);
		#local PartType = mod(I, NumParts);
		#local XOffset = 0;

		#ifdef (Part_L2_Twist[I])
			// Compensate for the center shift so that L1 parts still line-up
			#local XOffset = 1.5;
		#end

		#declare PartPosition[I] = <
			div(PartType, 4) * 5 - 6.5 + XOffset,
			mod(PartType, 4) * -4 + 6,
			0
		>;
	#end
#end

#macro RotationForL2Part(PartTypeL2)
	transform {
		// Undo the normal rotation to place the L2 part correctly. This way all L1
		// cubes will in principle be oriented the same in the assembled puzzle. This
		// (together with PartRotation_LW) ensures that 1) an equal number L1 parts of
		// each type (four) have a big L2 connector attached to it. (Otherwise only a
		// subset of parts would have connectors attached.)
		transform { RotationForPart(PartTypeL2) inverse }

		// Rotate L1 cube such that 1) holds (see above) and that 2) all L1 cubes
		// within an L2 cube face are nevertheless oriented differently.
		#ifdef (PartRotation_L2[PartTypeL2])
			rotate PartRotation_L2[PartTypeL2]
		#end

		// Rotate L2 part so that they all assemble into an L2 cube.
		//
		// Note: the placement of the L2 connectors to the L1 parts is aware of and
		// takes into account the above transforms so that this assembly works.
		transform { RotationForPart(PartTypeL2) }
	}
#end

#macro TransformForL1PartInL2Part(PartTypeL2, PartTypeL1, D1)
	#local PartIndex = PartTypeL2 * NumParts + PartTypeL1;
	transform {
		#ifdef (Part_L2_Twist[PartIndex])
			// Compensate for center shift of bulky parts
			#local T = Part_L2_Twist[PartIndex];
			translate -1.5 * <0, T, 1 - T>
		#end

		transform { RotationForPart(PartTypeL1) }
		translate PositionForPart(PartTypeL1, D1)
	}
#end

#macro InitAssemblyPlacementL2(PartPosition, PartRotation, D1, D2)
	#for (I, 0, NumParts - 1)
		#local L2_Transform = transform {
			RotationForL2Part(I)

			translate PositionForPart(I, D2)
		}

		#for (J, 0, NumParts - 1)
			#local L1_Transform = TransformForL1PartInL2Part(I, J, D1)
			#local Combined = transform {
				transform { L1_Transform }
				transform { L2_Transform }
			}

			#local PartIndex = I * NumParts + J;
			#declare PartPosition[PartIndex] = VectorTransform(<0, 0, 0>, Combined);
			#declare PartRotation[PartIndex] = transform {
				transform { Combined }
				translate -PartPosition[PartIndex]
			}
		#end
	#end
#end

//--------------------------------------
// Define L2 compound parts

#macro DefineCompoundParts_L2()
	#declare CompoundPart_L2 = array[NumParts];

	#for (I, 0, NumParts - 1)
		#declare CompoundPart_L2[I] = union {
			#for (J, 0, NumParts - 1)
				#local PartIndex = I * NumParts + J;
				object {
					Part_L2[PartIndex]

					TransformForL1PartInL2Part(I, J, 1)
				}
			#end
		}
	#end
#end