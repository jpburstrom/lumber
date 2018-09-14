var fxFactory = { |name, func|

    SynthDef(name, {

        var snd;
        snd = In.ar(\out.kr, 1);
        snd = func.(snd);
        XOut.ar(\out.kr, Env.asr(0.01, 1, 0.01).ar(2, \gate.kr(1)), snd)

    }).add;

};

fxFactory.(\lumberEqBand, { |snd|
	BPeakEQ.ar(snd, \freq.kr(440), \rq.kr(0.0625), \db.kr(0, 0.1)) ;
});
