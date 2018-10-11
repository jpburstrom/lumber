SynthDef(\lumberIn, {

	var snd;

	if (Library.at(\lumber, \server).name == \bela) {
		snd = SoundIn.ar(\in.kr(0));
	} {
		snd = SinOsc.ar(440) * 0.1; //test tone
	};
	//Do stuff;

	Out.ar(\out.kr, snd);

}).add(\lumber);

SynthDef(\lumberOut, {

	var snd = In.ar(\in.kr, 1);

	//Do stuff;

	Out.ar(\out.kr, snd);

}).add;



SynthDef("inputMapperBipolar", {
	//Inbus = source bus
	var sig = In.kr(\inbus.kr(0)).poll,
		fadetime = \fadetime.kr(1),
		env = Env.asr(fadetime, 1, fadetime, \lin).kr(Done.freeSelf, \gate.kr(1));
	var	x = [0] ++ \times.kr([0.3, 0.4, 0.3]).max(1e-06).integrate,
		y = \levels.kr([-1, -0.33, 0.33, 1]),
		curves = \curves.kr([0, 0, 0]);

	//"Envelope" with 4 points
	//Like IEnvGen, but possible to change envelope while running
	sig = y[0] + 3.collect({ |i|
		//XXX Quick fix before figuring out whether bipolar sources should output
		//-1 to 1 or if times should be between -1 and 1 or if times should be called
		//"x" instead
		sig.range(0,1).lincurve(x[i], x[i+1], 0, y[i+1] - y[i], curves[i], \minmax);
	}).sum.lagud(\lagU.kr(0), \lagD.kr(0));

	//Outbus = destination bus
	Out.kr(\outbus.kr(0), sig * env);
}).add(\lumber);


SynthDef("inputMapper", {
	//Inbus = source bus
	var sig = In.kr(\inbus.kr(0)),
		fadetime = \fadetime.kr(1),
		env = Env.asr(fadetime, 1, fadetime, \lin).kr(Done.freeSelf, \gate.kr(1)),
		x = [0] ++ \times.kr([0.3, 0.4, 0.3]).max(1e-06).integrate,
		y = \levels.kr([0, 0.3, 0.7, 1]),
		curves = \curves.kr([0, 0, 0]);

	//"Envelope" with 4 points
	//Like IEnvGen, but possible to change envelope while running
	sig = y[0] + 3.collect({ |i|
		sig.lincurve(x[i], x[i+1], 0, y[i+1] - y[i], curves[i], \minmax);
	}).sum.lagud(\lagU.kr(0), \lagD.kr(0));

	//Output its existence to a bus. \controlBusDiv synth takes care of scaling the output
	Out.kr(\countbus.kr(0), env);
	//Outbus = destination bus
	Out.kr(\outbus.kr(0), sig * env);
}).add(\lumber);

//Single bus multiplier
//Used before destination synths to
//scale down output from several mapping synths
SynthDef(\controlBusDiv, { |bus=0, divisorBus|
	ReplaceOut.kr(bus, In.kr(bus) / In.kr(divisorBus).max(1));
}).add(\lumber);
SynthDef(\audioBusDiv, { |bus=0, divisorBus|
	ReplaceOut.ar(bus, In.ar(bus) / In.kr(divisorBus).max(1));
}).add(\lumber);


//Play a default value on a bus, if no inputMapper synth is playing
SynthDef(\controlBusValue, { |bus=0, divisorBus, value|
	var sig = LinXFade2.kr(value, In.kr(bus),
		(In.kr(divisorBus).min(1) * 2) - 1);
	ReplaceOut.kr(bus, sig);
}).add(\lumber);