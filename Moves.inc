//----------------------------------------------------------------------------
// Animation

#include "vectors.inc"
#include "quaternions.inc"

#ifndef (PauseEnabled)
	#declare PauseEnabled = 1;
#end
#ifndef (PauseMultiplier)
	#declare PauseMultiplier = 1;
#end
#ifndef (PauseDuration)
	#declare PauseDuration = 0.0;
#end
#ifndef (MoveSpeed)
	#declare MoveSpeed = 1.0;
#end

// Initial/default value. Temporarily changed by PartialMove macro.
#declare DelayPause = 0;
#declare DelayedPause = 0;

// Tracks the progress of the move animation. It increases as more moves are parsed.
#declare Now = 0;

// The number of moves/rotations parsed sofar. After parsing all moves it equals the total
// number of moves, irrespective of the clock value
#declare NumMoves = 0;

// The number of moves/rotations completed sofar. Its value depends on the clock value.
#declare NumMovesHandled = 0;

// The progress of the current move/rotation.
#declare NumMovesHandledFraction = 0;

// The progress of the last/current move. A value from 0 to 1.
#declare MoveFraction = 0;
// The progress of the last/current rotation. A value from 0 to 1.
#declare RotateFraction = 0;

#macro ClockFraction(Min, Max)
	(max(0, min(Max-Min, clock-Min)) / (Max-Min))
#end

//----------------------------------------------------------------------------
// Quaternion calculations

#macro QuaternionFromTransform(T)
	#local M = array[4];
	#for (I, 0, 3)
		#local M[I] = <0, 0, 0>;
	#end

	VectorsFromTransform(T, M[0], M[1], M[2], M[3])

	QFromMatrix(M)
#end

#macro MatrixFromQuaternion(Q)
	#local M = QToMatrix(Q);

	matrix <
		M[0].x, M[0].y, M[0].z,
		M[1].x, M[1].y, M[1].z,
		M[2].x, M[2].y, M[2].z,
		M[3].x, M[3].y, M[3].z
	>
#end

#macro QuaternionToString(Q)
	#local M = QToMatrix(Q);
	concat(
		#for (I, 0, 3)
			"<",
			vstr(3, M[I], ", ", 3, 3)
			">"
		#end
	)
#end

//----------------------------------------------------------------------------

#macro FractionMovePart(PartNum, Delta)
	#if (PartNum > 0)
		#declare PartPosition[PartNum - 1] = PartPosition[PartNum - 1] + Delta;
	#end // if
#end

#macro FractionRotatePart(PartNum, VRotate, VCenter)
	#if (PartNum > 0)
		#ifndef (PartRotation[PartNum - 1])
			#declare PartRotation[PartNum - 1] = transform { translate 0 }
		#end

		#declare PartRotation[PartNum - 1] =
			transform {
				transform { PartRotation[PartNum - 1] }
				translate -VCenter
				rotate VRotate
				translate VCenter
			}
	#end // if
#end

#macro FractionRotatePartToTransform(PartNum, Transform, Fraction)
	#if (PartNum > 0)
		#ifndef (PartRotation[PartNum - 1])
			#declare PartRotation[PartNum - 1] = transform { translate 0 }
		#end

		#local QT0 = QuaternionFromTransform(PartRotation[PartNum - 1]);
		#local QT1 = QuaternionFromTransform(Transform);
		#debug concat("QT0: ", QuaternionToString(QT0), "\n")
		#debug concat("QT1: ", QuaternionToString(QT1), "\n")

		#if (Qsc(QDiff(QT0, QT1)) > 0)
			#local QT = QLinear(QT0, QT1, Fraction);
			#debug concat("Fraction = ", str(Fraction, 0, 3), "\n")
			#debug concat("QT:  ", QuaternionToString(QT), "\n")

			#declare PartRotation[PartNum - 1] = transform {
				MatrixFromQuaternion(QT)
			}
		#end
	#end // if
#end

#macro SetPartTransform(PartNum, Transform)
	#if (PartNum > 0)
		#declare PartRotation[PartNum - 1] = transform { Transform };
	#end
#end

#macro _Move(What, V, Clock_MoveDone)
	#if (Now < clock)	
		#declare MoveFraction = 1;
		#if (clock < Clock_MoveDone)
			#local Min = Now;
			#local Max = Clock_MoveDone;
			#local Time = Max - Min;
			#local Dist = vlength(V);
			#local RelTime = clock - Min;

			// Move acceleration
			#local Accel = 8 * (Dist / Time);
			#local AccelTime = (Accel*Time - sqrt(Accel*Accel*Time*Time - 4*Accel*Dist))
			                   / (2*Accel);
			#local MaxVelocity = AccelTime * Accel;

			// Acceleration
			#local T = min(AccelTime, RelTime);
			#local Delta = 0.5 * Accel * T * T;

			// Steady move at max velocity
			#local T = max(0, min(Time - 2 * AccelTime, RelTime - AccelTime));
			#local Delta = Delta + MaxVelocity * T;
			
			// Deceleration
			#local T = max(0, RelTime + AccelTime - Time);
			#local Delta = Delta + MaxVelocity * T - 0.5 * Accel * T * T;

			#declare MoveFraction = Delta / Dist;
			#declare NumMovesHandledFraction = MoveFraction;
		#end
		FractionMovePart(What.x, V * MoveFraction)
		FractionMovePart(What.y, V * MoveFraction)
		FractionMovePart(What.z, V * MoveFraction)
	#end // if
		
	#declare Now = Clock_MoveDone;
#end

#macro _Rotate(What, VRotate, VCenter, Clock_MoveDone)
	#if (Now < clock)
		#declare RotateFraction = 1;
		#if (clock < Clock_MoveDone)
			#declare RotateFraction = (clock - Now) / (Clock_MoveDone - Now);
			#declare NumMovesHandledFraction = RotateFraction;
		#end
		FractionRotatePart(What.x, VRotate * RotateFraction, VCenter)
		FractionRotatePart(What.y, VRotate * RotateFraction, VCenter)
		FractionRotatePart(What.z, VRotate * RotateFraction, VCenter)
	#end // if

	#declare Now = Clock_RotateDone;
#end

#macro _RotateToTransform(What, Transform, Clock_MoveDone)
	#if (Now < clock)
		#if (clock < Clock_MoveDone)
			#local TransformFraction = (clock - Now) / (Clock_MoveDone - Now);
			#declare NumMovesHandledFraction = TransformFraction;

			FractionRotatePartToTransform(What.x, Transform, TransformFraction)
			FractionRotatePartToTransform(What.y, Transform, TransformFraction)
			FractionRotatePartToTransform(What.z, Transform, TransformFraction)
		#else
			// For performance, set to target transform directly
			SetPartTransform(What.x, Transform)
			SetPartTransform(What.y, Transform)
			SetPartTransform(What.z, Transform)
		#end
	#end

	#declare Now = Clock_TransformDone;
#end

#macro EndMovePause()
	#if (PauseEnabled)
		#declare DelayedPause = DelayedPause + PauseDuration;
		#if (! DelayPause) 
			#declare Now = Now + DelayedPause;
			#declare DelayedPause = 0;
		#end
	#end
#end

#macro DisablePause()
	#declare PauseEnabled = 0;
#end

#macro EnablePause()
	#declare PauseEnabled = 1;
#end

#macro EndMove()
	#declare NumMoves = NumMoves + 1;
	#if (Now <= clock)
//		#debug concat("clock = ", str(clock, 0, 3), "\n")
//		#debug concat("Now = ", str(Now, 0, 3), "\n")
		#declare NumMovesHandled = NumMovesHandled + 1;
	#end
	
	// Optional pause
	EndMovePause()
#end

#macro ClockTicksForMove(V)
	(vlength(V) / MoveSpeed)
#end

// This move should blend into the next. I.e. no pause at the end of this move, 
// but an extra pause at the end of the next one.
#macro PartialMove(What, V)
  #declare DelayPause = 1;
  Move(What, V) 
  #declare DelayPause = 0;
#end

#macro TimedMove(What, V, TotalDuration)
	#local Clock_MoveDone = Now + TotalDuration - PauseDuration;

	_Move(What, V, Clock_MoveDone)
	
	EndMove()
#end

#macro TimedMove6(What1, What2, V, TotalDuration)
	#local StartMove = Now;
	#local Clock_MoveDone = Now + TotalDuration - PauseDuration;

	_Move(What1, V, Clock_MoveDone)
	#declare Now = StartMove;
	_Move(What2, V, Clock_MoveDone)

	EndMove()
#end

#macro Move(What, V)
	TimedMove(What, V, ClockTicksForMove(V))
#end

#macro SlowMove(What, V)
	#local PrevMoveSpeed = MoveSpeed;
	#declare MoveSpeed = 0.5;
	
	Move(What, V)
	
	#declare MoveSpeed = PrevMoveSpeed;
#end

#macro FastMove(What, V)
	#local PrevMoveSpeed = MoveSpeed;
	#declare MoveSpeed = 2;
	
	Move(What, V)
	
	#declare MoveSpeed = PrevMoveSpeed;
#end

#macro Move6(What1, What2, V)
	TimedMove6(What1, What2, V, ClockTicksForMove(V))
#end

#macro SlowMove6(What1, What2, V)
	#local PrevMoveSpeed = MoveSpeed;
	#declare MoveSpeed = 0.5;

	Move6(What1, What2, V)

	#declare MoveSpeed = PrevMoveSpeed;
#end

#macro Move9(What1, What2, What3, V)
	#local StartMove = Now;
	#local Clock_MoveDone = Now + ClockTicksForMove(V) - PauseDuration;

	_Move(What1, V, Clock_MoveDone)
	#declare Now = StartMove;
	_Move(What2, V, Clock_MoveDone)
	#declare Now = StartMove;
	_Move(What3, V, Clock_MoveDone)

	EndMove()
#end

#macro ClockTicksForRotation(V)
	(vlength(V) / 22.5)
#end

#macro TimedRotate(What, VRotate, VCenter, TotalDuration)
	#local Clock_RotateDone = Now + TotalDuration - PauseDuration;

	_Rotate(What, VRotate, VCenter, Clock_RotateDone)

	EndMove()
#end

#macro Rotate(What, VRotate, VCenter)
	TimedRotate(What, VRotate, VCenter, ClockTicksForRotation(VRotate))
#end

#macro TimedRotateToTransform(What, Transform, TotalDuration)
	#local Clock_TransformDone = Now + TotalDuration - PauseDuration;

	#debug concat(
		"TimedRotateToTransform(",
		str(What.x, 0, 0),
		", ",
		str(TotalDuration, 0, 3),
		")\n"
	)

	_RotateToTransform(What, Transform, Clock_TransformDone)

	EndMove()
#end

//------------------
// Hiding parts

#declare _IsPartHidden = array[TotalParts]
#macro HidePart(PartNum)
	#if (Now < clock)
		#ifdef(_IsPartHidden[PartNum - 1])
			#debug concat("Part already hidden!")
		#end
		#declare _IsPartHidden[PartNum - 1] = 1;
	#end
#end

#macro ShowPart(PartNum)
	#if (Now < clock)
		#ifndef(_IsPartHidden[PartNum - 1])
			#debug concat("Part not hidden!")
		#end
		#undef _IsPartHidden[PartNum - 1]
	#end
#end

#macro ShowIfPartVisible(PartNum, PartObject)
  #ifndef(_IsPartHidden[PartNum])
    PartObject
  #end
#end

//------------------
// Puzzle transformations

#macro ResetPuzzleTransform() 
	#declare _PuzzleTransform = transform { translate 0 }
#end

ResetPuzzleTransform()

#macro RotatePuzzle(V_Rotate, Duration)
	#if (Now < clock)
		#local RotateFraction = ClockFraction(Now, Now+Duration);

		#declare _PuzzleTransform = 
			transform {
				transform { _PuzzleTransform }
				rotate RotateFraction * V_Rotate
			}
	#end

	#declare Now = Now + Duration;
#end

#declare _PartPuzzleTransform = array[TotalParts]
// Release part from puzzle. It is not affected by subsequent puzzle transforms
#macro ReleasePartFromPuzzle(PartNum)
	#if (Now < clock)
		#ifdef(_PartPuzzleTransform[PartNum - 1])
			#debug concat("Part already released!")
		#end
		#declare _PartPuzzleTransform[PartNum - 1] = _PuzzleTransform;
	#end
#end

// Add part to puzzle (again). It is again affected by subsequent puzzle transforms
#macro AddPartToPuzzle(PartNum)
	#if (Now < clock)
		#ifndef(_PartPuzzleTransform[PartNum - 1])
			#debug concat("Part already added!")
		#end
		#undef _PartPuzzleTransform[PartNum - 1]
	#end
#end

#macro PuzzleTransformForPart(PartNum)
	#ifdef (_PartPuzzleTransform[I])
		transform { _PartPuzzleTransform[I] }
	#else
		transform { _PuzzleTransform }
	#end
#end

/* EOF */