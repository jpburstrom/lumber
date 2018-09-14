Proto {

	~target = nil;
	~isPlaying = false;

	~outbus = 0;

	~synths = ();

	~connect = { |model|
		~model = model;
		~connections = ConnectionList.make {
			model.params.keysValuesDo { |key, cv|
				cv.signal(\value).connectTo(
					currentEnvironment.methodSlot("setEqBand(%, value)".format(key)));
			}
		}
	};

	~play = { |target, out|
		~target = target;
		~outbus = out;
		~model.getParams(\player).keysValuesDo { |midi, db|

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
		Synth(\lumberEqBand, [\freq, freq, \db, db, \out, ~outbus], ~target);
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


