#include "Anim.inc"

#declare Eps = 0.00001;
#version 3.8;

#macro VectorTimeString(V, T)
	concat(
		"<", vstr(3, V, ", ", 0, 3), "> @ ", str(T, 0, 4)
	)
#end

// Macro that calculates the minimum distance between two objects, A and B,
// travelling along a straight line.
//
// Object A starts at VA0 at t = TA0 and arrives at VA1 at t = VA1.
// Object B starts at VB0 at t = TB0 and arrives at VB1 at t = VB1.
//
// The distance is only considered when both objects travel. When the objects
// do not move, assume they are placed infinitely far away.
#macro MinDist(VA0_, TA0, VA1_, TA1, VB0_, TB0, VB1_, TB1, optional T)
	#local DMax = 1000;
	#local DMin = DMax;

	#local TMin = max(TA0, TB0);
	#local TMax = min(TA1, TB1);
	#local TRel = -1;

	#ifdef (Verbose)
		#debug concat(
			"A0 = ", VectorTimeString(VA0_, TA0), ", ",
			"A1 = ", VectorTimeString(VA1_, TA1), ", ",
			"B0 = ", VectorTimeString(VB0_, TB0), ", ",
			"B1 = ", VectorTimeString(VB1_, TB1), "\n"
		)
	#end

	#if (TMax >= TMin)
		// Adjust positions for TMin and TMax
		#local VA0 = LerpVector(VA0_, VA1_, f_ramp(TA0, TA1, TMin));
		#local VB0 = LerpVector(VB0_, VB1_, f_ramp(TB0, TB1, TMin));
		#local VA1 = LerpVector(VA0_, VA1_, f_ramp(TA0, TA1, TMax));
		#local VB1 = LerpVector(VB0_, VB1_, f_ramp(TB0, TB1, TMax));

		// Check distance at T = TMin
		#local D0 = vlength(VA0 - VB0);
		#if (D0 < DMin)
			#local DMin = D0;
			#local TRel = 0;
			#ifdef (local.T)
				#declare T = TMin;
			#end
		#end

		// Check distance at T = TMax
		#local D1 = vlength(VA1 - VB1);
		#if (D1 < DMin)
			#local DMin = D1;
			#local TRel = 1;
			#ifdef (local.T)
				#declare T = TMax;
			#end
		#end

		// Check if there a minimun inside this range.
		// For simplicity map time so that TMin = 0 and TMax = 1.
		//
		// For coordinate X, the distance DX(T) is:
		// DX(T) = VA(T) - VB(T)
		//       = VA0.x + (VA1.x - VA0.x) * T
		//         - VB0.x + (VB1.x - VB0.x) * T
		//       = VA0.x - VB0.x + (VA1.x + VB0.x - VA0.x - VB1.x) * T
		//       = BX + AX * T
		// Similar for DY(T) and DZ(T) with respectively BY/AY and BZ/AZ
		#local B = VA0 - VB0;
		#local A = VA1 - VB1 - B;

		// D(T) = sqrt(DX(T)^2 + DY(T)^2 + DZ(T)^2)
		//
		// This is minimal when DS(T) = DX(T)^2 + DY(T)^2 + DZ(T)^2 is minimal.
		//
		// This occurs when DS(T)/DT = 0
		//
		// DX(T)^2 / DT = (BX + AX * T) ^ 2 / DT = (BX^2 + 2 AX BX T + AX^2 T^2) / DT
		//              = 2 AX BX + 2 AX^2 T
		//
		// Solve:
		// 0 = 2 AX BX + 2 AX^2 T + 2 AY BY + 2 AY^2 T + 2 AZ BZ + 2 AZ^2 T
		//   = AX BX + AY BY + AZ BZ + (AX^2 + AY^2 + AZ^2) T
		#local VDOTA = vdot(A, A);
		#if (VDOTA > Eps)
			#local TX = -vdot(A, B) / vdot(A, A);
			#if (TX > 0 & TX < 1)
				// Re-normalize
				#local TX = TMin + (TMax - TMin) * TX;

				#local VAX = LerpVector(VA0, VA1, f_ramp(TMin, TMax, TX));
				#local VBX = LerpVector(VB0, VB1, f_ramp(TMin, TMax, TX));
				#declare DMin = vlength(VAX - VBX);
				#ifdef (local.T)
					#declare T = TX;
				#end

				// Sanity check that distance is a local minimum
				#local Dbefore = vlength(
					LerpVector(VA0, VA1, f_ramp(TMin, TMax, TX - 0.01)) -
					LerpVector(VB0, VB1, f_ramp(TMin, TMax, TX - 0.01))
				);
				#local Dafter = vlength(
					LerpVector(VA0, VA1, f_ramp(TMin, TMax, TX + 0.01)) -
					LerpVector(VB0, VB1, f_ramp(TMin, TMax, TX + 0.01))
				);

				#if (Dbefore < DMin | Dafter < DMin)
					#error concat(
						"Error in DistMin: ",
						str(Dbefore, 0, 4), " > ",
						str(DMin, 0, 4), " < ",
						str(Dafter, 0, 4), "\n"
					)
				#end
			#end
		#end
	#end

	#if (DMin < 1000 & defined(Verbose))
		#debug concat(
			"MinDist = ", str(DMin, 0, 4),
			" TRel = ", str(TRel, 0, 4),
			" Time = ", str(T, 0, 4),
			"\n"
		)
	#end

	DMin
#end

// Same times
#macro Test1(VA0, VA1, VB0, VB1, ExpectedD, ExpectedT)
	#local T = -1;
	#local D = MinDist(VA0, 0, VA1, 1, VB0, 0, VB1, 1, T);

	#debug concat(
		"VA0 = <", vstr(3, VA0, ", ", 0, 3), ">, ",
		"VA1 = <", vstr(3, VA1, ", ", 0, 3), ">, ",
		"VB0 = <", vstr(3, VB0, ", ", 0, 3), ">, ",
		"VB1 = <", vstr(3, VB1, ", ", 0, 3), ">: ",
		"D = ", str(D, 0, 3), ", "
		"T = ", str(T, 0, 3), " "
	)
	#if (abs(D - ExpectedD) > 0.001)
		#debug concat(
			"Distance mismatch: expected ", str(ExpectedD, 0, 3), "\n"
		)
		ASSERT_FAILURE
	#elseif (abs(T - ExpectedT) > 0.001)
		#debug concat(
			"Time mismatch: expected ", str(ExpectedT, 0, 3), "\n"
		)
		ASSERT_FAILURE
	#else
		#debug "OK!\n"
	#end
#end

#ifdef (RunPathCrossingTests)
	// Crossing lines in Z plane
	Test1(<0, 0, 0>, <10, 10, 0>, <0, 10, 0>, <10, 0, 0>, 0, 0.5)

	// Same, but constant Z seperation
	Test1(<0, 0, 0>, <10, 10, 0>, <0, 10, 2>, <10, 0, 2>, 2, 0.5)

	// Diverging lines
	Test1(<0, 1, 0>, <10, 10, 0>, <0, -1, 0>, <10, -1, 0>, 2, 0)

	// Converging lines
	Test1(<0, 10, 0>, <10, 1, 0>, <0, -10, 0>, <10, -2, 0>, 3, 1)

	// Crossing lines in 3D
	Test1(<0, 0, 0>, <10, 10, 10>, <8, 0, 0>, <2, 10, 10>, 0, 0.5)

	// Similar, but one line remains in Y = 0 plane
	Test1(<0, 0, 0>, <10, 10, 10>, <8, 0, 0>, <2, 0, 10>, 4.24, 0.36)
#end
