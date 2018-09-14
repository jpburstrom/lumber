//Main sound producer
//
Proto({

	var common = Require("common");

	~ready = false;
	~server = nil;
	~isPlaying = false;
	//used during reload of errored file
	~isError = false;

	~c_eq = Require("c_eq");
	//FIXME q.eq
	~c_eq.connect(q.eq);

	//List of things to free

	~prep = {

		ServerTree.add(currentEnvironment, ~server);
		//FIXME: paths are weird. How does resolveRelative work again?
		Require("lib/d_synthdefs");
		~prResetContainers.value;
		~addBuses.value;
		/*
		~watcher = FileWatcher(["synths.scd", "buses.scd"].collect(_.resolveRelative), { |path|

			//XXX Seems like we need to fork
			//Otherwise error handling doesn't work as it should
			//Don't know why.
			{
				//Reload buses if
				if (path.basename == "buses.scd") {
					{
						~addBuses.value;
					}.try {
					};
				};

				if (~isPlaying or: { ~isError }) {
					{
						~restart.value;
						~isError = false;
					}.try { |err|
						err.reportError;
						~isError = true;
					}
				};
			}.fork;

		}.inEnvir);
		*/

		~ready = true;
	};

	~addBuses = {
		var b, envir = currentEnvironment;
		~prFreeBuses.value; //free buses if they exist
		~buses = ().make {

			~main = Bus.audio(~server, 1);
			~out = Bus(\audio, 0, 1, ~server);

			common.macroSources.do { |src|
				currentEnvironment[src] = Bus.control(~server);
			}

		};

	};

	~addGroups = {
		~groups.make {
			~main = Group();
			//Add to head means reverse order
			~output 	= Group(~main);
			~fx 		= Group(~main);
			~eq 		= Group(~main);
			~lfo 		= Group(~main);
			~sensors 	= Group(~main);
			~input 		= Group(~main);
		}
	};

	~addSynths = {
		//Static synths here
		~synths[\output] = Synth(\lumberOut, [\out, ~buses.out, \in, ~buses.main], target: ~groups.output);
		~synths[\ping] = Synth(\ping, [\release, 10, \out, ~buses.main], target: ~groups.input);

		~c_eq.play(~groups.eq, ~buses.main);

		//Controller.play
	};

	//Rebuild synths and groups
	~play = { |watch=true|
		if (~isPlaying.not) {
			~server = ~server ? Server.default;
			forkIfNeeded {
				if (~server.hasBooted.not) {
					var cond = Condition();
					s.boot;
					s.doWhenBooted { cond.unhang };
					cond.hang;
				};
				if (~ready.not) { ~prep.value };
				~prPlay.value;
				/*
				if (watch) {
					~watcher.watch;
				}
				*/
			}
		};
	};

	~prPlay = {
		"building".postln;
		~addGroups.value;
		~proxySpace = ProxySpace(~server, "lumber");
		~addSynths.value;
		~isPlaying = true;
	};

	~stop = { |stopWatching=true|
		~groups !? { ~groups.main.free };
		~c_eq.stop;
		~isPlaying = false;
		/*
		if (~watcher.notNil and: { stopWatching }) {
			~watcher.stopWatching;
		}
		*/
	};

	~restart = {
		//Stop but don't stop watching
		~stop.value(false);
		//And don't start watching again
		~play.value(false);
	};

	~prFreeBuses = {
		~buses !? { ~buses.do(_.free) };
	};

	~free = {
		~stop.value;
		~prFreeBuses.value;
		~ready = false;
		ServerTree.remove(currentEnvironment, ~server);
	};

	//
	~doOnServerTree = {
		~prResetContainers.value;
		~isPlaying = false;
		//currentEnvironment.prPlay;
	};

	//Reset containers of freeable stuff
	//Assumes things have already been freed
	~prResetContainers = {
		~groups = ();
		~synths = ();
	}
});
