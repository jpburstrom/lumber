SynthDef(\bypass, {

}).add(\lumber);

SynthDef(\ping, {
	Out.ar(\out.kr(0), SinOsc.ar * \amp.kr(0.1) * Env.perc(0, \release.kr(1)).ar(2))
}).add(\lumber);
