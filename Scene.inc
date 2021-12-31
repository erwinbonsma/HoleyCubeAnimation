/* Holey Puzzle POV-Ray Animation
 *
 * Include file with elements common to all scenes
 *
 * Copyright (C) 2021  Erwin Bonsma
 */

#include "colors.inc"

#local AreaLights = 1;

#ifndef (CameraLookAt)
	#declare CameraLookAt = <0, 0, 0>;
#end
#ifndef (CameraPosition)
	#declare CameraPosition = -z * 40;
#end

light_source {
	-z * 60
	color White * 0.9

	#if (AreaLights)
		area_light
		x * 6, y * 6, 6, 6
		adaptive 1
		circular
	#end

	rotate x * 70
	rotate y * 20
}

light_source {
	-z * 60
	color White * 0.2

	#if (AreaLights)
		area_light
		x * 6, y * 6, 6, 6
		adaptive 1
		circular
	#end

	rotate x * 20
	rotate y * -20
}

#ifdef (DetailAreaLightActivation)
	// Extra lights for use in Scene 7 to add detail to L3 connector parts that
	// are fully in the shadow of the main lights. They are optional, as they slow
	// rendering, and do not significantly improve the other scenes.

	light_source {
		-z * 1000
		color White * 0.04 * DetailAreaLightActivation

		#if (AreaLights)
			area_light
			x * 100, y * 100, 100, 100
			adaptive 1
		#end
	}

	light_source {
		-z * 1000
		color White * 0.02 * DetailAreaLightActivation

		#if (AreaLights)
			area_light
			x * 100, y * 100, 100, 100
			adaptive 1
		#end

		rotate y * 90
	}
#end

sky_sphere {
	pigment { color Black }
}

// Place camera based on position and look at vector

#declare CameraV = CameraPosition - CameraLookAt;
#declare CameraD = vlength(CameraV);
#declare CameraD2 = sqrt(pow(CameraD, 2) - pow(CameraV.y, 2));

camera {
	perspective
	location <0, 0, -CameraD>
	right x * 1
	up y * 9/16
	angle 30
	look_at <0, 0, 0>

	rotate x * degrees(asin(CameraV.y / CameraD))
	rotate y * -degrees(asin(CameraV.x / CameraD2))

	translate  CameraLookAt
}

