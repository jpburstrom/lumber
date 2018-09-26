Ndef(\sensor, { LFNoise2.kr(1).range(0, 1) });

Ndef(\mapper, { \freq.asSpec.map(\in.kr(0)).poll });

Ndef(\mapper).set(\in, Ndef(\sensor))

Monitor

(
{ |name, spec|

	spec = (spec ? name).asSpec;
	SynthDef("%SpecMapper".format(name), {
		ReplaceOut.kr(\out.kr(0), spec.map(\inval.kr(0).lincurve(\inMin.kr(0), \inMax.kr(1), 0, 1, \curve.kr(0))));
	})
}.value(\lumberFreqTest, [220, 880, \exp]).add
)
)

//Two buses, one for sensor and one for mapper
a = Bus.control;
b = Bus.control;

//Our sensor output
{ LFNoise2.kr(1).range(0, 1) }.play(outbus:a)

//Our mapper
Synth(\lumberFreqTestSpecMapper, [\inval, a.asMap, \out, b, \inMin, 0.0], addAction: \addToTail)



{ SinOsc.ar(10880-\freq.kr(440)) * 0.1 }.play(addAction:\addToTail, args:[\freq, b.asMap])