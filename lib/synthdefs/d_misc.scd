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
		env = Env.asr(fadetime, 1, fadetime, \lin).kr(Done.freeSelf, \gate.kr(1));

	sig = IEnvGen.kr(
		Env(\levels.kr([0, 0.3, 0.7, 1]),
			\times.kr([0.3, 0.4, 0.3]),
			\curves.kr([0, 0, 0])), sig).lagud(\lagU.kr(0), \lagD.kr(0));

	Out.kr(\countbus.kr(0), env);
	//Outbus = destination bus
	Out.kr(\outbus.kr(0), sig * env);
}).add;


SynthDef(\bypass, {

}).add;

SynthDef(\ping, {
	Out.ar(\out.kr(0), SinOsc.ar * \amp.kr(0.1) * Env.perc(0, \release.kr(1)).ar(2))
}).add;
