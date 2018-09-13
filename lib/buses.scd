//Function runs inside the ~buses environment
//self is main proto

{ |self|
	var server = self.server;
	var common = Require("common");
	// "Reloading buses".postln;

	~main = Bus.audio(server, 1);
	~out = Bus(\audio, 0, 1, server);

	common.macroSources.do { |src|
		currentEnvironment[src] = Bus.control(server);
	}

}


(

groups: {
},

buses: {
},

synths: {
}

)