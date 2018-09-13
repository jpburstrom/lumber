{

	var common = Require("common");


	//Output to main out
	//TODO: synthdef should do limiting and stuff
	Synth(\lumberOut, [\in, ~buses.main, \out, ~buses.out], target: ~groups.output);

	//PING == READY TO ROCK//
	Synth(\ping, [\release, 10, \outbus, ~buses.main], target: ~groups.output);
}
