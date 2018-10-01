var fxFactory = { |name, func|

    SynthDef(name, {

        var snd;
        snd = In.ar(\out.kr, 1);
        snd = func.(snd);
        XOut.ar(\out.kr, Env.asr(0.01, 1, 0.01).ar(2, \gate.kr(1)), snd)

    }).add;

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
	snd * \db.kr(0).dbamp;
});

SynthDef(\destTest, {

	\testParam.kr.poll;

}).metadata_((
	specs: (
		testParam: \freq,
		another: \amp
	),
	lumber: (
		label: "Test",
		group: \fx,
		inputs: #[testParam, another]
	)
)).add(\lumber);
