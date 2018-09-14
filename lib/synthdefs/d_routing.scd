"routing synthdefs".postln;
SynthDef(\lumberOut, {

	var snd = In.ar(\in.kr, 1);

	//Do stuff;

	Out.ar(\out.kr, snd);

}).add;