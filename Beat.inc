#ifndef (BeatClockOffset)
	#declare BeatClockOffset = 0;
#end

#declare BPM = 134 * 0.5;

#declare BeatAt = function(Clock) { mod((Clock + BeatClockOffset) * BPM / 60, 1) }
#declare Beat = BeatAt(clock);

