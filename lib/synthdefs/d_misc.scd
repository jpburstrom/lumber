//Single bus multiplier
//Used before destination synths to
//scale down output from several mapping synths
SynthDef(\controlBusDiv, { |bus=0, divisorBus|
	ReplaceOut.kr(bus, In.kr(bus) / In.kr(divisorBus).max(1));
}).add;
SynthDef(\audioBusDiv, { |bus=0, divisorBus|
	ReplaceOut.ar(bus, In.ar(bus) / In.kr(divisorBus).max(1));
}).add;


SynthDef("inputMapper", {
	//Inbus = source bus
	var sig = In.kr(\inbus.kr(0)),
		fadetime = \fadetime.kr(0.1),
		env = Env.asr(fadetime, 1, fadetime, \lin).kr(Done.freeSelf, \gate.kr(1)),
		x = [0] ++ \times.kr([0.3, 0.4, 0.3]).integrate,
		y = \levels.kr([0, 0.3, 0.7, 1]),
		curves = \curves.kr([0, 0, 0]);

	//"Envelope" with 4 points
	//Like IEnvGen, but possible to change envelope while running
	sig = y[0] + 3.collect({ |i|
		sig.lincurve(x[i], x[i+1], 0, y[i+1] - y[i], curves[i], \minmax);
	}).sum.lagud(\lagU.kr(0), \lagD.kr(0));

	Out.kr(\countbus.kr(0), env);
	//Outbus = destination bus
	Out.kr(\outbus.kr(0), sig * env);
}).add;


SynthDef(\bypass, {

}).add;

SynthDef(\ping, {
	Out.ar(\out.kr(0), SinOsc.ar * \amp.kr(0.1) * Env.perc(0, \release.kr(1)).ar(2))
}).add;
