(
p = Proto {

	~target = nil;
	~isPlaying = false;

	~synths = ();

	SynthDef(\lumberEqBand, {
		var outbus = \outbus.kr(0);
		var snd = In.ar(outbus, 1);
		snd = BPeakEQ.ar(snd, \freq.kr(440), \rq.kr(0.0625), \db.kr(0, 0.1));
		XOut.ar(outbus, Env.asr(1, 1, 1).ar(2, \gate.kr(1)), snd);
	}).add;

	//Connect to EQ model
	//
	~connect = { |model|

		c = ConnectionList.make {
			q.eq.params.keysValuesDo { |key, cv|
				cv.signal(\value).connectTo(p.methodSlot("setEqBand(%, value)".format(key)));
			}
		}
	};

	~play = { |model, target|
		~target = target;
		~model = model;
		model.getParams(\player).keysValuesDo { |midi, db|

			if (db != 0) {
				~synths[midi] = ~prMakeSynth.value(midi.midicps, db);
			}

		};
	};

	~stop = {
		~synths.do(_.release);
		~synths.clear;
	};

	~prMakeSynth = { |freq, db|
		Synth(\lumberEqBand, [\freq, freq, \db, db], ~target);
	};

	~setEqBand = { |midi, db|
		if (db == 0) {
			~synths[midi] !? { |x|
				x.release;
				~synths[midi] = nil;
			};
		} {
			if (~synths[midi].isNil) {
				~synths[midi] = ~prMakeSynth.value(midi.midicps, db);
			} {
				~synths[midi].set(\db, db);
			}
		}
	};

	~free = {
		~connections.free;
	};


};
)

		