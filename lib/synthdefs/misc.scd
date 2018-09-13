SynthDef(\bypass, {

}).add;

SynthDef(\ping, {
	Out.ar(\outbus.kr(0), SinOsc.ar * \amp.kr(0.1) * Env.perc(0, \release.kr(1)).ar(2))
}).add;