//Common data, eg labels, mappings
//Things that needs to sync between eg synthDefs, buses and guis

var e = Environment().know_(true).make({

	~belaAddress = "192.168.7.2";

	//Macro sources
    //That is, physical or virtual controllers
    //This also defines gui order
    //Should it?
    ~macroSources = #[
        activity, intensity, orientation,
        softpot_l, softpot_s,
        expression
    ];

	//Parameter labels
	//This defines macro->parameter mapping
	//Arrays also define parameter order
	//parameters:
	//name: GUI label
	//def: FX synthdef
	//in: input parameter to control
	//spec: a spec, symbol or array which maps 0-1 from source to the input parameter.
	~macroMapping = (
		softpot_s: (
			eq: (name: "EQ", def: \bypass, in: \freq, spec: [220, 3200, \exp]),
			delay: (name: "Delay", def: \bypass)
		),
		orientation: (
			delay: (name: "Delay", def: \bypass)
		),
		intensity: (
			freeze: (name: "Freeze", def: \bypass),
			volume: (name: "Volume", def: \bypass),
			saturation: (name: "Saturation", def: \bypass)
		),
		softpot_l: (
			pitch: (name: "Pitch", def: \bypass),
			phase: (name: "Phase", def: \bypass),
			delay: (name: "Delay", def: \bypass)
		),
		activity: (
			lfo: (name: "LFO", def: \bypass)
		),
		expression: (
			weirdness: (name: "Weirdness", def: \bypass)
		)
	);

	//Frequencies for multi-param-eq, as semitones.
	//(Semitones work better as dict keys)
	~eqSemitones = (36..59);


});

e.keysValuesDo { |k, v|
	Library.put(\lumber, \common, k, v);
};

e