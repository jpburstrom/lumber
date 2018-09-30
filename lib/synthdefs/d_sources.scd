var wrap = { |key, func|
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}).add;
};


wrap.('activity', {
	var sig = MPU.accelKr;
	// sig = Latch.kr(sig, Impulse.kr(10));
	sig = GestureRT.kr(sig);
	sig.poll(1, \activity);
});

wrap.('intensity', {
	var sig = MPU.accelKr;
	// sig = Latch.kr(sig, Impulse.kr(10));
	sig = GestureRT.kr(sig);
	sig.poll(1, \intensity);
});

wrap.('orientation', {
	DC.kr(0);
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

