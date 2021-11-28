#include "colors.inc"

#local AreaLights = 1;

global_settings {
	ambient_light rgb <0.666667, 0.666667, 0.666667>
	irid_wavelength rgb <0.999767, 0.147190, 0.000000>
	assumed_gamma 1.0
}

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

sky_sphere {
	pigment { color Black }
}
