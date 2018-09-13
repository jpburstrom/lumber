Ndef(\main, {
	var snd, ctl, freqs;
	//C1->B2
	//TODO: put these in a more central place?
	freqs = Array.series(24, 36).midicps;

	//SoundIn
	snd = SoundIn.ar(0);

	//TODO: spec for preamp. 0-24 db?
	snd = snd * \preamp.kr(0).dbamp;

	//Array or one control per frequency?
	ctl = NamedControl.kr(\eqGain, 0 ! freqs.size);

	//Highpass filter
	//TODO: better high-order filter
	4.do { snd = HPF.ar(snd, 60) };

	//n-band EQ
	freqs.do { |freq, i|
		//see http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/What-is-rq-really-td5619928.html
		//0.03125 = 1 / 16 (0.5 semitones between -3 db)
		snd = BPeakEQ.ar(snd, freq, 0.03125, \eqGain.kr[i]);
	};

	//Highshelf to cut high frequencies
	snd = BHiShelf.ar(snd, freq: 200, rs: 1, db: -36);

	snd

}).gui;
