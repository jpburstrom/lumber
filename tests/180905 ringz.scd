Formlet

{ Resonz.ar(WhiteNoise.ar(0.5), 2000, 0.00001) }.play

Ringz.ar(in: 0.0, freq: 440.0, decaytime: 1.0, mul: 1.0, add: 0.0)

{ Ringz.ar(SinOsc.ar(800) * 0.00005 * Env.linen(0, 10, 0).ar, 1000, 1) }.play

FreqScope()

(
Ndef(\ringzTest, {

	var notes = (48, 49.1..72).midicps;

	var snd = LFPulse.ar(Demand.ar(Impulse.ar(1), 0, Dseq(notes, inf)));
	// var snd = Pulse.ar(notes[0], LFNoise2.ar(2));

	var out = DC.ar;

	notes.do { |freq|
		out = out + (Resonz.ar(snd, freq, 0.0002) );
	};

	SelectX.ar(MouseX.kr, [snd, out]).dup

}).mold.play;
)
