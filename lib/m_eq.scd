p = Require("protos/paramDict").clone {

	~dbSpec = ControlSpec(-24, 6, \db, default:0);

	//We're using a dictionary instead of an array,
	//to be able to change frequency range while making sense
	//of old presets
	Library.at(\lumber, \common, \eqSemitones).do { |k|
		~params[k] = NumericControlValue(0, ~dbSpec);
	};

	~params[\lowCut] = (freq: NumericControlValue(60, ControlSpec(20, 200, \exp, 0, 60, " Hz")));
	~params[\hiShelf] = (
		freq: NumericControlValue(200, ControlSpec(100, 400, \exp, 0, 200, " Hz")),
		rs: NumericControlValue(1, [0.1, 10, \exp, 0.0, 1].asSpec),
		db: NumericControlValue(-24, ControlSpec(-48, 0, \db, 0.0, 0, " dB"))
	);
	~params[\preamp] = (db: NumericControlValue(0, ControlSpec(0, 24, \db, 0.0, 0, " dB")));

	~setParams = { |obj, params|
		params = params ?? { ~params };
		params.keysValuesDo { |k, v|
			if (v.respondsTo(\keysValuesDo)) {
				obj[k] !? { |o| ~setParams.(o, v) };
			} {
				obj[k] !? { |newVal|
					params[k].value = newVal;
				}
			}
		}
	};

	~getParams = { |usage, params|
		var obj=();
		params = params ?? { ~params };
		params.keysValuesDo { |k, val|
			if (val.respondsTo(\keysValuesDo)) {
				obj[k] = ~getParams.(usage, val);
			} {
				obj[k] = val.value;
			}
		};
		obj
	};
};

