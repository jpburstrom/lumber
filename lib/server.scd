//Main sound producer
//
(
q.main.free;
q.main = Proto({

	~ready = false;
	~server = nil;
	~isPlaying = false;
	//used during reload of errored file
	~isError = false;

	//List of things to free

	~prep = {

		ServerTree.add(currentEnvironment, ~server);
		Require("synthdefs");
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
		Synth(\ping, [\release, 10, \outbus, ~buses.main], target: ~groups.output);

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
				if (watch) {
					~watcher.watch;
				}
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
		~proxySpace.clear.remove;
		~isPlaying = false;
		if (~watcher.notNil and: { stopWatching }) {
			~watcher.stopWatching;
		}
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
		//currentEnvironment.prPlay;
	};

	//Reset containers of freeable stuff
	//Assumes things have already been freed
	~prResetContainers = {
		~groups = ();
	}
});
q.main.play;
)
q.main.stop
q.main.watcher.task.task.isPlaying
q.main.isError
SkipJack.verbose = true
q.main.watcher = ()
1
/*
var connection;
~slider = Slider().front;
~slider.onClose_ {
	connection.free;
};
~dep = ().make {
	~setEqBand = { |self, midi, db|
		[midi, db].postln;
	};
};
connection = ~slider.signal(\value).connectTo(~dep.methodSlot("setEqBand(32, value)"));
*/