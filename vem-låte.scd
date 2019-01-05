//VEM LÅTE
//2019-01-05

//
var totalDuration = 55; //Minutes


//Song lengths
var halftime = totalDuration * 0.5;
var durations = ((#[5,7,11,13].normalizeSum * halftime) ++ halftime).scramble * 60;
//Amplitude data
var amps = "data/amps-190105-1.scd".loadRelative[0];
//Different max delays for different song lengths
var maxDelays = (1 - durations.normalizeSum) * 0.5;


//Score
fork {

	durations.do { |dur, i|

		var fadeOut = 0.001.exprand(10);


		"START Song %, total duration %".format(i+1, dur).postln;

		Ndef(\vem, {
			//var freq = XLine.kr(~frequencies.first, ~frequencies.last, 10, doneAction:2);
			var in = SoundIn.ar(0);
			var snd = DC.ar;
			var minFreq = amps.keys.asArray.minItem.midicps;
			var maxFreq = amps.keys.asArray.maxItem.midicps;
			var maxDelay = minFreq.reciprocal * maxDelays[i];
			var keys = amps.keys.asArray.scramble;

			keys = keys.keep(4.rrand(keys.size));

			keys.midiname.debug("Keys");

			keys.do { |k|
				var obj = amps[k];
				snd = snd + (BPF.ar(in, k.midicps, obj[\rq]) * obj[\amp]);
			};
			snd = DelayC.ar(snd, maxDelay, LFDNoise3.kr(LFNoise1.kr(0.1).range(0.1, 5)).exprange(0.001, maxDelay));
			snd = snd * LFNoise2.kr(0.05.exprand(0.25)).exprange(0.92, 1.05);
			snd = BPeakEQ.ar(snd, LFNoise1.kr(0.1).exprange(minFreq, maxFreq), 0.25, 0.rrand(6));
			snd = HPF.ar(snd, 40);
			snd = LPF.ar(snd, 130);

			snd = snd * XLine.kr(0.8.exprand(1.1), 0.8.exprand(1.1), dur);

			(Limiter.ar(snd) * Env.dadsr(1, 0.5.exprand(10), 0, 1, fadeOut, 1, [4, -4]).ar(2, \gate.kr(1)));

		}).play;

		dur.wait;

		Ndef(\vem).fadeTime = fadeOut;
		"Fading Song %".format(i+1, dur).postln;
		Ndef(\vem).end;

		fadeOut.wait;
		"END Song %".format(i+1, dur).postln;

		10.wait;

	}

}


