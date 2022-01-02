/* Holey Puzzle POV-Ray Animation
 *
 * Include file that defines the Level 3 puzzle parts
 *
 * Copyright (C) 2022  Erwin Bonsma
 */

#include "Parts.inc"

#declare ConnectorAttachment_L3 = union {
	box { <-1.5, -0.5, -0.5>, <1.5, 0.5, 0.5> }
	box { <-0.5, -1.5, -0.5>, <0.5, 1.5, 0.5> }
	box { <-0.5, -0.5, -1.5>, <0.5, 0.5, 1.5> }
}

#declare PartConnector_L3 = array[NumParts][2];

#for (N, 0, NumParts - 1)
	#for (I, 0, 1)
		#declare PartConnector_L3[N][I] = union {
			object {
				Connector[mod(PartConnector[N][I], 3)]
				scale 9
			}

			union {
				object {
					ConnectorAttachment_L3
					translate <6 * (1 - 2 * I), 0, 3>
				}
				object {
					ConnectorAttachment_L3
					translate <6 * (1 - 2 * I), 0, -3>
				}
			}

			rotate x * 90 * div(PartConnector[N][I], 3)
		}
	#end
#end
