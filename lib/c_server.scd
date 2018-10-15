Require("protos/serverPlayer", always:false).clone {

	// Need to look up absolute path here, not inside method.
	var synthdefPath = "d_synthdefs.scd".resolveRelative;

	~eq = Require("c_eq");
	~macros = Require("c_macros");


	~connectToModels = { |...args|
		args.pairsDo { |k, model|
			currentEnvironment[k].connect(model);
		}
	};

	~onPrep = {
		Require(synthdefPath);
		//Load calibration for MPU ugens
		if (~server.name == \bela) {
			MPU.loadCalibration(Library.at(\lumber, \common, \calibrationPath), ~server);
		};
		~eq.server = ~server;
		~macros.server = ~server;
		~eq.prep;
		~macros.prep;

		//XXX hack to let ~macros access macroSource buses & groups
		~macros.buses.parent = ~buses;
	};

	~onPlay = {
		~macros.groups.parent = ~groups;
		~eq.play(~buses.main, ~groups.eq);
		~macros.play(~buses.main);

	};

	~onStop = {
		~eq.stop;
		~macros.stop;
	};

	~onFree = {
		~eq.free;
		~macros.free;
	};

	~factory.make {

		~buses = { |server|
			~main = Bus.audio(server, 1);
			~out = Bus(\audio, 0, 1, server);

			//TODO Later move to ~macros
			Library.at(\lumber, \common, \macroSources).keysValuesDo { |src|
				currentEnvironment[src] = Bus.control(server);
			}
		};

		~groups = { |parentGroup|
			~main = Group(parentGroup);
			//Add to head means reverse order
			~post       = Group(~main);
			~output 	= Group(~main);
			//TODO maybe some of these should be created by children
			~fx 		= Group(~main);
			~eq 		= Group(~main);
			~lfo 		= Group(~main);
			~sensors 	= Group(~main);
			~input 		= Group(~main);
		};

		~synths = { |buses, groups, server|
			//\in is for SoundIn, ie first input channel
			~input = Synth(\lumberIn, [\in, 0, \out, buses.main], target: groups.input);
			~output = Synth(\lumberOut, [\out, buses.out, \in, buses.main], target: groups.output);
			~ping = Synth(\ping, [\release, 10, \out, buses.main], target: groups.input);
		};
	};
};
