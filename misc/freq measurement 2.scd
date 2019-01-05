(
SynthDef(\tester, {
	var in = SoundIn.ar(0);
	var snd = BPF.ar(in, \freq.kr(440), 0.03125) * \amp.kr(1, 0.1);
	var amp = Amplitude.kr(snd, 1, 1);

	SendReply.kr(Impulse.kr(10), '/ampTester', amp);
	Out.ar(0, Limiter.ar(snd, 0.99));
}).add;
)

~amps = ();
~amps.postcs
(
//Run tests for a selection of notes
//save in ~amps
value {
	var replaceExisting = false; //Set to false to avoid running tests for previously tested values
	var routine;
	var cond = Condition();
	var currentNote;
	var syn;
	var count = 20; //Count number of samples before finalizing
	var mavg = RingBuffer(count);
	var curAmp = 0.5; //current set amp
	var targetAmp = 0.25; //target amp for signal
	var avgAmp = 0.5; // moving average of amp output
	var storeAmp = { |amp|
		~amps[currentNote] = amp;
	}.inEnvir;
	var win = Window.new.layout_(VLayout()).front;
	var label = StaticText(win).font_(Font("Monospace", 64));
	var slider = Slider(win);
	var cancel = Button(win).states_([["Cancel"]]).action_({
		cond.unhang;
	}).minHeight_(50);
	var cancelAll = Button(win).states_([["Cancel All"]]).action_({
		cond.unhang;
		routine.stop;
		win.close;
		syn.free;
	}).minHeight_(50);
	var func = OSCFunc({ |msg|
		var outAmp = msg[3];
		avgAmp = (outAmp * 0.3) + (avgAmp * 0.7);
		curAmp = curAmp + ((targetAmp - avgAmp) * 0.1);
		mavg.overwrite(curAmp);

		{ slider.value = avgAmp.absdif(targetAmp) }.defer;

		if (avgAmp.absdif(targetAmp) < 0.1) {
			"OK".postln;

			count = count - 1;
			if (count == 0) {
				curAmp.debug("final amp");
				storeAmp.value(mavg.mean);
				cond.unhang;
			};
		} {
			count = 40;
			syn.set(\amp, curAmp);
		}

	}, '/ampTester');
	routine = fork {
		(28..51).collect { |note|

			if (~amps[note].isNil || replaceExisting) {
				var freq = note.midicps;


				currentNote = note;

				{ label.string = note.midiname }.defer;

				{ SinOsc.ar(freq) * Env.linen(level:0.5).ar(2) }.play;

				2.wait;

				syn = Synth(\tester, [\freq, freq, \amp, curAmp]);

				cond.wait;
				syn.free;
				1.wait;
			}
		};

		{ win.close }.defer;
		func.free;
	};




	//func.free;
};
)

