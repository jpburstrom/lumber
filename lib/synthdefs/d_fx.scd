var fxFactory = { |name, func, meta|

    SynthDef(name, {

        var snd;
        snd = In.ar(\out.kr, 1);
        snd = func.(snd);
		//FIXME: settable fadetime
        XOut.ar(\out.kr, Env.asr(0.01, 1, 0.01).ar(Done.freeGroup, \gate.kr(1)), snd)

	}, metadata: meta !? { meta.put(\destination, true) }).add(\lumber);

};

fxFactory.(\peakEqBand, { |snd|
	BPeakEQ.ar(snd, \freq.kr(440), \rq.kr(0.0625), \db.kr(0, 0.1)) ;
});

fxFactory.(\hiShelfBand, { |snd|
	BHiShelf.ar(snd, \freq.kr(440), \rs.kr(1), \db.kr(0, 0.1)) ;
});
fxFactory.(\lowCutBand, { |snd|
	BLowCut.ar(snd, \freq.kr(440), 2) ;
});

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


fxFactory.(\destTest, {
	SinOsc.ar(\testParam.kr.poll(1, "testParam")) * 0.1 * SinOsc.ar(\another.kr.poll(1, "another"));
},(
	specs: (
		testParam: \freq,
		another: \amp
	),
	label: "Test",
	group: \fx,
	inputs: #[testParam, another]
)).add(\lumber);

fxFactory.(\boogie, {
	SinOsc.ar(\freq.kr.poll(1, "freq")) * \amp.kr(0.1);
},(
	specs: (
		amp: \amp.asSpec.default_(0.1),
		freq: \freq
	),
	label: "Boogie",
	group: \fx,
	inputs: #[amp, freq]
)).add(\lumber);

