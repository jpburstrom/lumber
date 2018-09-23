Require("protos/serverPlayer", always:false).clone {

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

	~onFree = {
		~connections.free;
	};

	~factory.make {

		~synths = { |model, parentGroup, buses, synths, makeSynth|
			model.getParams(\player).keysValuesDo { |key, val|

			switch(key,
				\lowCut, {
					currentEnvironment[key] = Synth(\lowCutBand,
						[\freq, val.freq, \out, buses.out],
						parentGroup
					);
				},
				\hiShelf, {
					if (val.db != 0) {
						currentEnvironment[key] = Synth(\hiShelfBand,
							[\freq, val.freq, \rs, val.rs, \db, val.db, \out, buses.out],
							parentGroup
						);
					}
				},
				\preamp, {
					if (val.gain != 0) {
						currentEnvironment[key] = Synth(\gainer,
							[\gain, val.db, \out, buses.out],
							parentGroup
						);
					};
				},
				//Default: midi note number, val is gain in dB
				{
					if (val != 0) {
						synths[key] = makeSynth.value(key.midicps, val);
					}
				}
			);

		};
		};

	};


	~makeSynth = { |freq, db|
		//Quick hack
		Synth(\peakEqBand, [\freq, freq, \db, db, \out, ~buses.out], ~parentGroup);
	};

	~setGain = { |param, db|
		if (db == 0) {
			~synths[param] !? { |x|
				x.release;
				~synths[param] = nil;
			};
		} {
			if (~synths[param].isNil) {
				~synths[param] = ~makeSynth.value(param.midicps, db);
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




};



