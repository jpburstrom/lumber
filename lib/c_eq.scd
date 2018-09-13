Proto {

	~target = nil;
	~isPlaying = false;

	~synths = ();

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

		
