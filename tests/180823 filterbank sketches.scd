(
Ndef(\filterbank, {
	var snd = SinOsc.ar(\freq.kr(440)) * 0.1;
	var orig = snd;
	var lo, midhi;
	snd = BLowCut.ar(orig, 40.midicps, 2);
	snd = BHiCut.ar(snd, 64.midicps, 4);
	2.do { snd = Allpass1.ar(snd, 40.midicps) };

	[Mix((40..64).collect { |m|
		BBandPass.ar(snd, m.midicps, 0.2) * 0.25
		// BPF.ar(snd, m.midicps, 0.15) * 0.25
	}), orig *LFPulse.ar(1)];

}).mold.play
)

s.scope
Ndef(\filterbank).gui

40.midicps

"5".namemidi
64.midicps

Ndef(\test, { var snd = SinOsc.ar(\frq.kr(440)); BLowCut.ar(snd, 999) }).play


(
Ndef(\test2, {
	var freqs = (60..62).midicps;
	var amps = [0, 0.4, 0];

	var snd = Mix(SinOsc.ar(freqs[1])) * LFPulse.ar(1);

	if (false) {

		snd = Mix(freqs.collect { |fq, i|
			BBandPass.ar(snd, fq, 0.2) * amps[i];
		});
	} {
		snd = [Mix(freqs.collect { |fq, i|
			BPF.ar(snd, fq, 0.1) * amps[i];
		}), snd * 0.4];
	}
}).mold.play
)
