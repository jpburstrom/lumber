p = Require("protos/paramDict").clone {

	//Specs are defined in common

	Library.at(\lumber, \common, \eqSemitones).do { |k|
		~params[k] = NumericControlValue(0, \eqdb.asSpec);
	};

	~params[\lowCut] = (freq: NumericControlValue(60, ControlSpec(20, 200, \exp, 0, 60, " Hz")));
	~params[\hiShelf] = (
		freq: NumericControlValue(200, ControlSpec(100, 400, \exp, 0, 200, " Hz")),
		rs: NumericControlValue(1, [0.1, 10, \exp, 0.0, 1].asSpec),
		db: NumericControlValue(-24, \eqcut.asSpec)
	);
	~params[\preamp] = (db: NumericControlValue(0, \gain.asSpec));

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

