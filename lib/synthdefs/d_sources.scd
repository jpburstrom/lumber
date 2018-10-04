var wrap = { |key, func|
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}).add(\lumber);
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
	DC.kr(1);
});

wrap.('softpot_l', {
	DC.kr(0);
});

wrap.('softpot_s', {
	DC.kr(0);
});

wrap.('expression', {
	DC.kr(0);
});

