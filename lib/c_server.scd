Require("protos/serverPlayer", always:false).clone {

	// Need to look up absolute path here, not inside method.
	var synthdefPath = "d_synthdefs.scd".resolveRelative;

	~eq = Require("c_eq");
	~macros = Require("c_macros");


	//FIXME don't use global variable
	~eq.connect(q.eq);
	~macros.connect(q.macros);

	~onPrep = {
		Require(synthdefPath);
		//Load calibration for MPU ugens
		MPU.loadCalibration(Library.at(\lumber, \common, \calibrationPath), ~server);
		~eq.prep;
		~macros.prep;
	};

	~onPlay = {
		~eq.play(~buses.main, ~groups.eq);
		~macros.play(~buses.main, ~groups.fx);
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

