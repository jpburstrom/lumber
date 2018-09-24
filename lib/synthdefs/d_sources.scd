var wrap = { |key, func|
	SynthDef(key, {
		var sig;

		sig = SynthDef.wrap(func);

		Out.kr(\out.kr(0), sig);
	}).add;
};


wrap.('activity', {
	DC.kr(0);
});

wrap.('intensity', {
	DC.kr(0);
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