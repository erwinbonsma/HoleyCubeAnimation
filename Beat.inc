#ifndef (BeatTimeOffset)
	#declare BeatTimeOffset = 0;
#end

#declare BPM = 134 * 0.5;

#declare f_beat = function(time) { mod((time + BeatTimeOffset) * BPM / 60, 1) }
#declare Beat = f_beat(clock);

