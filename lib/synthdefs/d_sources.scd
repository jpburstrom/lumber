var wrap = { |key, func, meta|
	meta ?? { meta = () };
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}, metadata: meta !? (_.put(\source, true))).add(\lumber);
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
});

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
});

wrap.('orientation', {
	LFTri.kr(0.5).range(0, 1);
});

wrap.('softpot_l', {
	LFTri.kr(0.3).range(0, 1);
});

wrap.('softpot_s', {
	DC.kr(0);
});

wrap.('expression', {
	DC.kr(0);
});

wrap.(\lfo1, {
	SinOsc.kr(\freq.kr(1)).range(0,1);
}, (
	specs: (
		\freq: [0.125, 20, \exp]
	),
	label: "LFO1",
	group: \lfo,
	inputs: #[freq],
	destination: true
));