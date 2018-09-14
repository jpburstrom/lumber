//Common data, eg labels, mappings
//Things that needs to sync between eg synthDefs, buses and guis

Environment().know_(true).make({


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
	~macroMapping = (
		'softpot_s': [(name: "EQ", def: \bypass),
			(name: "Delay", def: \bypass)],
		'orientation': [(name: "Delay", def: \bypass)],
		'intensity': [(name: "Freeze", def: \bypass),
			(name: "Volume", def: \bypass),
			(name: "Saturation", def: \bypass)],
		'softpot_l': [(name: "Pitch", def: \bypass),
			(name: "Phase", def: \bypass),
			(name: "Delay", def: \bypass)],
		'activity': [(name: "LFO", def: \bypass)],
		'expression': [(name: "Weirdness", def: \bypass)]
	);

	//Frequencies for multi-param-eq, as semitones.
	//(Semitones work better as dict keys)
	~eqSemitones = (36..59);


});
