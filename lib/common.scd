//Common data, eg labels, mappings
//Things that needs to sync between eg synthDefs, buses and guis

//Create synthDescLib. Put this here first to be able to use \synthDescAdded signal
SynthDescLib.all[\lumber] ?? {
	var servers = [Server.default];
	Server.named[\bela] !? { |s| servers = servers.add(s) };
	SynthDescLib(\lumber, servers);
};

Environment().know_(true).make({

	~belaAddress = "192.168.7.2";
	~belaRoot = "/root/lumber";
	~sshCommand = "ssh root@%".format(~belaAddress);
	~calibrationPath = ~belaRoot +/+ "data/calibration.bin";

	//Macro sources
    //That is, physical or virtual controllers
    //This also defines gui order
    //Should it?
    ~macroSources = #[
        activity, intensity, orientation,
        softpot_l, softpot_s,
        expression
    ];

	//This is populated in d_synthdefs.scd
	//data taken from synthdef metadata
	~macroDestinations = ();

	//Frequencies for multi-param-eq, as semitones.
	//(Semitones work better as dict keys)
	~eqSemitones = (36..59);


}).keysValuesDo { |k, v|
	Library.put(\lumber, \common, k, v);
};

