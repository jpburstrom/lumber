//Common data, eg labels, mappings
//Things that needs to sync between eg synthDefs, buses and guis

//--------SPECS------------


//Gain. 0.5 input roughly equals 0 dB
Spec.add(\gain, ControlSpec(-44.0, 12.0, \db, 0.0, 0, " dB"));

Spec.add(\preamp, ControlSpec(0.0, 32.0, \db, 0.0, 0, " dB"));

//dB range for eq
Spec.add(\eqdb, ControlSpec(-36, 24, \db, 0.0, 0, " dB"));

//cut range for eq
//Used by hi shelf filter
Spec.add(\eqcut, ControlSpec(-48, 0, \db, 0.0, 0, " dB"));

//boost range for peak eq
Spec.add(\eqboost, ControlSpec(0, 12, \db, 0.0, 0, " dB"));

//Freq range for peak eq
Spec.add(\eqfreq, ControlSpec(65.0, 247.0, \exp, 0.0, 65.0, " Hz"));

//rq range for peak eq
Spec.add(\peakrq, ControlSpec(0.03125, 0.25, \exp, 0.0, 0.0625));

//phase for freqshift etc
Spec.add(\phase, ControlSpec(0, 2pi, \lin));

//
Spec.add(\shortDelay, ControlSpec(0.0, 0.05, 8, 0, 0.0, " secs"));






Environment().know_(true).make({

	~belaAddress = "192.168.7.2";
	~belaRoot = "/root/Bela/projects/lumber";
	//-f makes ssh go to background just before command execution.
	~sshCommand = "ssh -f root@%".format(~belaAddress);
	~calibrationPath = ~belaRoot +/+ "data/calibration.bin";

	//Macro sources
    //That is, physical or virtual controllers
    //This also defines gui order
    //Should it?
	~macroSources = Library.at(\lumber, \common, \macroSources) ?? { () };


	//This is populated in d_synthdefs.scd
	//data taken from synthdef metadata
	//(synthDefName: (inputs: [name1, name2], specs: (name1: ControlSpec(), name2: \specKey)
	//label: "GUI label", group: \serverGroupKey)
	//... where group is found in q.serverController[\groups][\serverGroupKey]
	~macroDestinations = Library.at(\lumber, \common, \macroDestinations) ?? { () };

	//Frequencies for multi-param-eq, as semitones.
	//(Semitones work better as dict keys)
	~eqSemitones = (24..59);


}).keysValuesDo { |k, v|
	Library.put(\lumber, \common, k, v);
};

//Check if we're running sclang on Bela
Fdef(\ifBela, {
	var isBela = (unixCmdGetStdOut("hostname").findRegexpAt("bela\\s").notNil);
	{ |trueFunc, falseFunc|
		isBela.if(trueFunc, falseFunc);
	}
}.value);


Library.put(\lumber, \serverName, Fdef(\ifBela).value(\local, \bela));

Library.put(\lumber, \isBelaServer, Fdef(\ifBela).value(true, { Library.at(\lumber, \serverName) == \bela }));


//Create synthDescLib. Put this here first to be able to use \synthDescAdded signal
SynthDescLib.all[\lumber] ?? {
	var servers = [Server.default];
	Server.named[\bela] !? { |s| servers = servers.add(s) };
	SynthDescLib(\lumber, servers);
};



