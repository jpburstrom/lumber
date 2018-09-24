Require("protos/serverPlayer", always:false).clone {

	// Need to look up absolute path here, not inside method.
	var synthdefPath = "d_synthdefs.scd".resolveRelative;

	~eq = Require("c_eq", always:true);


	//FIXME q.eq
	~eq.connect(q.eq);

	~onPrep = {
		Require(synthdefPath);
		~eq.prep;
	};

	~onPlay = {
		~eq.play(~buses.main, ~groups.eq)
	};

	~onStop = {
		~eq.stop;
	};

	~onFree = {
		~eq.free;
	};

	~factory.make {

		~buses = { |server|
			~main = Bus.audio(server, 1);
			~out = Bus(\audio, 0, 1, server);

			Library.at(\lumber, \common, \macroSources).do { |src|
				currentEnvironment[src] = Bus.control(server);
			}
		};

		~groups = { |parentGroup|
			~main = Group(parentGroup);
			//Add to head means reverse order
			~output 	= Group(~main);
			//TODO maybe some of these should be created by children
			~fx 		= Group(~main);
			~eq 		= Group(~main);
			~lfo 		= Group(~main);
			~sensors 	= Group(~main);
			~input 		= Group(~main);
		};

		~synths = { |buses, groups|
			~output = Synth(\lumberOut, [\out, buses.out, \in, buses.main], target: groups.output);
			~ping = Synth(\ping, [\release, 10, \out, buses.main], target: groups.input);

			//
			Library.at(\lumber, \common, \macroSources).do { |src|
				currentEnvironment[src] = Synth(src, [\out, buses[src]], groups.sensors);
			};
		};
	};


};

