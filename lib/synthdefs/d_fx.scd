var fxFactory = { |name, func, meta, doneAction|

	//Default is to free group, freeing all input mappers and stuff
	doneAction ?? { doneAction = Done.freeGroup };

    SynthDef(name, {

        var snd;
        snd = In.ar(\out.kr, 1);
        snd = func.(snd);
		XOut.ar(\out.kr, Env.asr(0.01, 1, 0.01).ar(\doneAction.ir(doneAction), \gate.kr(1)), snd)

	}, metadata: meta !? { meta.put(\destination, true) }).add(\lumber);

};


//EQ bands

fxFactory.(\hiShelfBand, { |snd|
	BHiShelf.ar(snd, \freq.kr(440), \rs.kr(1), \gain.kr(0, 0.1)) ;
}, nil, Done.freeSelf);
fxFactory.(\lowCutBand, { |snd|
	BLowCut.ar(snd, \freq.kr(440), 2) ;
}, nil, Done.freeSelf);

//Source effects
fxFactory.(\peakEqBand, { |snd|
	BPeakEQ.ar(snd, \freq.kr(440), \rq.kr(0.0625), \gain.kr(0, 0.1)) ;
},(
	specs: (
		freq: \eqfreq,
		rq: \peakrq,
		gain: \eqboost
	),
	label: "Peak EQ",
	group: \fx,
	inputs: #[freq, rq, gain]
));

fxFactory.(\gainer, { |snd|
	snd * \gain.kr(0).dbamp;
}, (
	specs: (
		gain: \gain
	),
	label: "Gain",
	group: \fx,
	inputs: #[gain]
));


fxFactory.(\freqshift, { |snd|
	FreqShift.ar(snd, \freq.kr, \phase.kr);
}, (
	specs: (
		freq: \detune,
		phase: \phase
	),
	label: "Freqshift",
	group: \fx,
	inputs: #[freq, phase]
));


fxFactory.(\delay, { |snd|
	DelayC.ar(snd, \shortDelay.asSpec.maxval, \time.kr(0));
}, (
	specs: (
		time: \shortDelay,
	),
	label: "Delay",
	group: \fx,
	inputs: #[time]
));


fxFactory.(\freeze, { |snd|
	var chain, fx;
	var fftsize = 8192;
	var check = \wet.kr(0);
	chain = FFT(LocalBuf(fftsize), snd);
	chain = PV_MagSmooth(chain, check > 0);
	fx = IFFT(chain);

	// fx = fx + AllpassC.ar(snd, 0.2, 0.05, 0.6);
	XFade2.ar(snd, fx, check.linlin(0, 1, -1, 1));

}, (
	specs: (
		\wet: \unipolar,
	),
	label: "Freeze",
	group: \fx,
	inputs: #[wet]
));

fxFactory.(\saturate, { |snd|
	var wet;
	var amount = \amount.kr(0.0);
	wet = snd * \preamp.kr(1);
	//https://ccrma.stanford.edu/software/snd/snd/sndclm.html#contrast-enhancement
	wet = sin((wet * pi * 0.5) + ( amount * sin(wet * pi * 2))) * \postamp.kr(1);
	//if amount < 0.1, start fading to dry signal
	XFade2.ar(snd, wet, amount.linlin(0, 1, -1, 1));
}, (
	specs: (
		\amount: \unipolar,
	),
	label: "Saturate",
	group: \fx,
	inputs: #[amount]
));
