x = Require("protos/paramDict").clone {

	//We need integers to be able to save/load
	~freqs = (36..59);

	~spec = ControlSpec(-24, 6, \db, default:0);

	//We're using a dictionary instead of an array,
	//to be able to change frequency range while making sense
	//of old presets
	~freqs.do { |k|
		~params[k] = NumericControlValue(0, ~spec);
	};

};
