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
						cv.signal(\value).connectTo(
							currentEnvironment.methodSlot("setParam('%', '%', value)".format(key, p)))
					}
				} {
					cvOrDict.signal(\value).connectTo(
						currentEnvironment.methodSlot("setGain(%, value)".format(key)));
				}
			}
		}
	};

	~play = { |target, out|
		~target = target;
		~outbus = out;
		~model.getParams(\player).keysValuesDo { |key, val|

			switch(key,
				\lowCut, {
					~synths[key] = Synth(\lowCutBand,
						[\freq, val.freq, \out, ~outbus],
						~target
					);
				},
				\hiShelf, {
					if (val.db != 0) {
						~synths[key] = Synth(\hiShelfBand,
							[\freq, val.freq, \rs, val.rs, \db, val.db, \out, ~outbus],
							~target
						);
					}
				},
				\preamp, {
					if (val.gain != 0) {
						~synths[key] = Synth(\gainer,
							[\gain, val.db, \out, ~outbus],
							~target
						);
					};
				},
				//Default: midi note number, val is gain in dB
				{
					if (val != 0) {
						~synths[key] = ~prMakeSynth.value(key.midicps, val);
					}
				}
			);

		};
	};


	~stop = {
		~synths.do(_.release);
		~synths.clear;
	};

	~prMakeSynth = { |freq, db|
		//Quick hack
		if (~target.notNil) {
			Synth(\peakEqBand, [\freq, freq, \db, db, \out, ~outbus], ~target);
		}
	};

	~setGain = { |param, db|
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

	~setParam = { |band, key, val|
		//Only set running synths
		if (key == \db) {
			~setGain.(band, val);
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



