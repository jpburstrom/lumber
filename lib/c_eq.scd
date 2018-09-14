p = Proto {

	~target = nil;
	~isPlaying = false;

	~outbus = 0;

	~synths = ();

	~connect = { |model|
		~model = model;
		~connections = ConnectionList.make {
			model.params.keysValuesDo { |key, cvOrDict|
				//Set k/v for lowcut/hishelf
				if (cvOrDict.respondsTo(\keysValuesDo)) {
					cvOrDict.keysValuesDo { |p, cv|
						cvOrDict.signal(\value).connectTo(
							currentEnvironment.methodSlot("setEqParam('%', '%', value)".format(key, p)))
					}
				} {
					cvOrDict.signal(\value).connectTo(
						currentEnvironment.methodSlot("setEqGain(%, value)".format(key)));
				}
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

	~setEqGain = { |param, db|
		if (db == 0) {
			~synths[param] !? { |x|
				x.release;
				~synths[param] = nil;
			};
		} {
			if (~synths[param].isNil) {
				~synths[param] = ~prMakeSynth.value(param.midicps, db);
			} {
				~synths[param].set(\db, db);
			}
		}
	};

	~setEqParam = { |band, key, val|
		//Only set running synths
		if (key == \db) {
			~setEqGain.(band, val);
		} {
			~synths[band] !? {
				~synths[band].set(key, val);
			};
		}
	};


	~free = {
		~connections.free;
	};


};



