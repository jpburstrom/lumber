// ~bela = Server.remote(\bela, NetAddr("192.168.7.2", 57110));
// Server.default = ~bela;

//{SoundIn.ar(0)}.play
//CmdPeriod.freeRemote = true

(
p = Proto({
	~frequencies = (28..51).midicps;

	~settings = (
		numSamples: 500,
		waitBetweenTests: 4
	);

	~prep = {

		SynthDef(\measureFreqAmp_old, {
			var snd, amp, trig, numsamp=40;

			//Test tone
			snd = SinOsc.ar(\freq.kr(440), 0, \amp.kr(1));
			// snd = BPF.ar(SoundIn.ar(0) * 10, \freq.kr(440), 0.0625);
			Out.ar(\out.kr(0), snd * Env.asr(0.01, 1, 0.01).ar(2, \gate.kr(1)));

			//Incoming sound
			snd = SoundIn.ar(\in.kr(0), 1);
			amp = RunningMax.kr(Amplitude.kr(snd));
			trig = Impulse.kr(numsamp.reciprocal * ControlRate.ir);

			//TODO mean

			SendReply.kr(trig, '/ampMeasurement', amp);


		}).add;



		SynthDef(\measureFreqAmp, {
			var line, snd, amp, trig, numsamp=40;

			//Test tone
			snd = SinOsc.ar(\freq.kr(440), 0, \amp.kr(1));
			// snd = BPF.ar(SoundIn.ar(0) * 10, \freq.kr(440), 0.0625);
			Out.ar(\out.kr(0), snd * Env.asr(0.01, 1, 0.01).ar(2, \gate.kr(1)));

			//Incoming sound
			snd = SoundIn.ar(\in.kr(0), 1);
			amp = RunningMax.kr(Amplitude.kr(snd));
			trig = Impulse.kr(numsamp.reciprocal * ControlRate.ir);

			//TODO mean

			SendReply.kr(trig, '/ampMeasurement', amp);


		}).add;
	};


	~testSingleFreq = { |args, callback|

		var count = 0;
		var synth;
		var numSamp = ~settings.numSamples;
		var func = OSCFunc({ |msg|

			count = count + 1;
			if (count >= numSamp) {
				func.free;
				synth.release;
				callback.value(msg[3].debug("Max"));
			};
		}, '/ampMeasurement');

		synth = Synth(\measureFreqAmp, args.asPairs)

	};


	~play = {
		~task = Routine({
			var cond = Condition();
			var out = List();

			"Waiting 10 seconds...".postln;
			10.wait;
			"Starting test.".postln;


			~frequencies.do { |freq|
				freq.cpsname.debug("NOTE");
				fork {
					~testSingleFreq.value((freq:freq), {|val|
						out.add(val);
						cond.unhang;
					});
				};
				cond.hang;
				~settings.waitBetweenTests.wait;
			};

			~amplitudes = out;



		});

		~task.play;
	};

	~getAmpCurve = {
		var db = ~amplitudes.ampdb;
		//subtract all items from minimum item
		db = db.minItem - db;
		//Convert to amp values
		db.dbamp;

	};

	~testAmplitudes = {

		~task = Routine({
			var cond = Condition();
			var amps = ~getAmpCurve.value;


			~frequencies.do { |freq, i|
				fork {
					~testSingleFreq.value((freq:freq, amp:amps[i]), {|val|
						cond.unhang;
					});
				};
				cond.hang;
			}
		});

		~task.play;
	};


	~stop = {
		~task.stop
	};

});

)

(
{
	//var freq = XLine.kr(~frequencies.first, ~frequencies.last, 10, doneAction:2);
	var freqs = p.frequencies;
	var amps = p.getAmpCurve;
	var in = SoundIn.ar(0) * 5;
	var snd = DC.ar + (SinOsc.ar(100) * Env.perc.ar);

	(24..34).midicps.do { |freq|
		var index = freqs.indexInBetween(freq);
		var freqLFO = LFNoise2.kr(0.11).range(0.95, 1.05);
		var ampLFOSpeed = LFNoise1.kr(0.1).exprange(0.01, 1);
		var ampLFO = LFNoise2.kr(ampLFOSpeed).exprange(0.125, 1.05);

		//Line.ar(dur: 30, doneAction:2);

		snd = snd + (BPF.ar(in, freq * freqLFO, 0.0625) * amps.blendAt(index) * ampLFO);

	};

	// snd = snd + DelayC.ar(snd, 0.01, 0.01);
	snd = HPF.ar(snd, 50);

	Limiter.ar(snd);

}.play

)
p.getAmpCurve.int


p.stop;
p.prep;
p.play;
p.getAmpCurve
.indexInBetween(28.midicps)
/*
p.testAmplitudes
p.amplitudes.asArray.plot
m
*/