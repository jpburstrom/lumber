var wrap = { |key, func, meta|
	meta ?? { meta = () };
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}, metadata: meta.put(\source, true)).add(\lumber);
};


// var isBela = Library.at(\lumber, \server).name == \bela;
var isBela = false; //FIXME

wrap.('activity', {
	var sig;
	if (isBela) {
		sig = MPU.accelKr;
	} {
		sig = \MouseX.asClass.perform(\kr);
	};
	// sig = Latch.kr(sig, Impulse.kr(10));
	sig = GestureRT.kr(sig);
	// sig.poll(1, \activity);
}, (label: "Activity"));

wrap.('intensity', {
	var sig;
	if (isBela) {
		sig = MPU.accelKr;
	} {
		sig = \MouseY.asClass.perform(\kr);
	};
	// sig = Latch.kr(sig, Impulse.kr(10));
	sig = GestureRT.kr(sig);
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

wrap.(\lfo1, {
	SinOsc.kr(\freq.kr(1));
}, (
	specs: (
		\freq: [0.125, 20, \exp],
		\depth: [0, 1, \lin, 0.01]
	),
	\outputSpec: \bipolar.asSpec,
	label: "LFO 1",
	group: \lfo,
	inputs: #[freq],
	destination: true
));