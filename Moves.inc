//----------------------------------------------------------------------------
// Animation

#ifndef (PauseEnabled)
	#declare PauseEnabled = 1;
#end
#ifndef (PauseMultiplier)
	#declare PauseMultiplier = 1;
#end
#ifndef (PauseDuration)
	#declare PauseDuration = 0.0;
#end
#ifndef (MoveSpeedup)
	#declare MoveSpeedup = 1.0;
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

#macro FractionMovePart(PartNum, Delta)
	#if (PartNum > 0)
		#declare PartPosition[PartNum - 1] = PartPosition[PartNum - 1] + Delta;
	#end // if
#end

#macro FractionRotatePart(PartNum, VRotate, VCenter)
	#if (PartNum > 0)
		#ifndef (PartTempRotation[PartNum - 1])
			#declare PartTempRotation[PartNum - 1] = transform { translate 0 }
		#end
		#declare PartTempRotation[PartNum - 1] = 
			transform {
				transform { PartTempRotation[PartNum - 1] }
				translate -VCenter
				rotate VRotate
				translate VCenter
			}
	#end // if
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
	(vlength(V) / MoveSpeedup)
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

#macro Move(What, V)
	TimedMove(What, V, ClockTicksForMove(V))
#end

#macro SlowMove(What, V)
	#local PrevMoveSpeedup = MoveSpeedup;
	#declare MoveSpeedup = 0.5;
	
	Move(What, V)
	
	#declare MoveSpeedup = PrevMoveSpeedup;
#end

#macro FastMove(What, V)
	#local PrevMoveSpeedup = MoveSpeedup;
	#declare MoveSpeedup = 2;
	
	Move(What, V)
	
	#declare MoveSpeedup = PrevMoveSpeedup;
#end

#macro Move6(What1, What2, V)
	#local StartMove = Now;
	#local Clock_MoveDone = Now + ClockTicksForMove(V) - PauseDuration;

	_Move(What1, V, Clock_MoveDone)
	#declare Now = StartMove;
	_Move(What2, V, Clock_MoveDone)

	EndMove()
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

//------------------
// Hiding parts

#declare _IsPartHidden = array[NumParts]
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

#declare _PartPuzzleTransform = array[NumParts]
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