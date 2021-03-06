/* Holey Puzzle POV-Ray Animation
 *
 * Include file with generic animation utilities
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#ifndef (ANIM_INCLUDED)
#declare ANIM_INCLUDED = 1;

// Pre-condition: t1 > t0
// Returns 0 if tnow < t0
// Returns 1 if tnow > t1
// Otherwise returns lineair interpolation between boundary points
#declare f_ramp = function(t0, t1, tx) { (min(t1, max(t0, tx)) - t0) / (t1 - t0) }

// Smooth ramp
#declare f_sramp = function(t0, t1, tx) { (1 - cos(pi * f_ramp(t0, t1, tx))) / 2 }

#macro LerpVector(V0, V1, Fraction)
	(V0 * (1 - Fraction) + V1 * Fraction)
#end

#end // #ifndef (ANIM_INCLUDED)