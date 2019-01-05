//VEM LÅTE
//2019-01-05

(
var amps = "data/amps-190105-1.scd".loadRelative[0];
Ndef(\vem, {
	//var freq = XLine.kr(~frequencies.first, ~frequencies.last, 10, doneAction:2);
	var in = SoundIn.ar(0);
	var snd = DC.ar;
	var minFreq = amps.keys.asArray.minItem.midicps;
	var maxFreq = amps.keys.asArray.maxItem.midicps;
	var maxDelay = minFreq.reciprocal * 0.25;

	amps.keysValuesDo { |k, obj|
		snd = snd + (BPF.ar(in, k.midicps, obj[\rq]) * obj[\amp]);
	};
	snd = DelayC.ar(snd, maxDelay, LFDNoise3.kr(LFNoise1.kr(0.1).range(0.1, 5)).exprange(0.001, maxDelay));
	snd = snd * LFNoise2.kr(0.1).exprange(0.92, 1.05);
	snd = BPeakEQ.ar(snd, LFNoise1.kr(0.1).exprange(minFreq, maxFreq), 0.5, 6);
	snd = HPF.ar(snd, 40);
	snd = LPF.ar(snd, 130);

	Limiter.ar(snd);

}).play
)

(
Ndef(\impulse, {

	Decay.ar(Impulse.ar(1), 0.01);

}).end;
)
