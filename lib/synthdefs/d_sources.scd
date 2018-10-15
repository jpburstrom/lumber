var isBela = Library.at(\lumber, \isBelaServer);
var wrap = { |key, func, meta|
	meta ?? { meta = () };
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}, metadata: meta.put(\source, true)).add(\lumber);
};


wrap.('activity', {
	var sig;
	if (isBela) {
		sig = MPU.accelKr;
		sig = GestureRT.kr(sig);
	} {
		sig = \MouseX.asClass.perform(\kr);
	};
	sig
	// sig = Latch.kr(sig, Impulse.kr(10));
	// sig.poll(1, \activity);
}, (label: "Activity"));

wrap.('intensity', {
	var sig;
	if (isBela) {
		sig = MPU.accelKr;
		sig = GestureRT.kr(sig);
	} {
		sig = \MouseY.asClass.perform(\kr);
	};
	// sig = Latch.kr(sig, Impulse.kr(10));
	sig
	// sig.poll(1, \intensity);
}, (label: "Intensity"));

wrap.('orientation', {
	LFTri.kr(0.5).range(0, 1);
}, (label: "Orientation"));

wrap.('softpot_l', {
	LFTri.kr(0.3).range(0, 1);
}, (label: "Softpot L"));

wrap.('softpot_s', {
	DC.kr(0);
}, (label: "Softpot S"));

wrap.('expression', {
	DC.kr(0);
}, (label: "Expression"));

wrap.(\lfoSin, {
	SinOsc.kr(\freq.kr(1));
}, (
	specs: (
		\freq: [0.125, 20, \exp],
	),
	outputSpec: \bipolar.asSpec,
	label: "LFO Sin",
	group: \lfo,
	inputs: #[freq],
	destination: true
));

wrap.(\lfoNoise, {
	LFNoise2.kr(\freq.kr(1));
}, (
	specs: (
		\freq: [0.125, 20, \exp],
	),
	outputSpec: \bipolar.asSpec,
	label: "LFO Noise",
	group: \lfo,
	inputs: #[freq],
	destination: true
));