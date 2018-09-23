//A proto playing stuff on a server
//Handle resources and children players
//free synths & groups on stop
//free buses & buffers on free
Proto {

	//If state is ready for play
	~readyForPlay = false;
	~isPlaying = false;

	//If ~server is nil, use Server.default
	~server = nil;

	//Everything is playing in a parent group
	~parentGroup = nil;
	//Different free methods depending on if parent group is created internally or not (see ~makeParentGroup)
	~parentGroupFreeMethod = \free;

	~factory = ();
	#[groups, synths, buffers, buses].do { |k|
		currentEnvironment[k] = ();
	};

	//~factory.groups = { ~main = Group() };
	//~factory.buses = { ~fxBus = Bus.audio };
	//~factory.synths = { |buses| ~reverb = Synth(\reverb, [\out, buses.main]) };

	//Prepare resources
	~prep = { |playNow=false|
		//FIXME server.default can change.
		var server = ~server ?? { Server.default };
		ServerTree.add(currentEnvironment, ~server);

		forkIfNeeded {
			if (server.hasBooted.not) {
				var cond = Condition();
				server.boot;
				server.doWhenBooted { cond.unhang };
				cond.hang;
			};
			~freeResources.value;
			~runFactoryFunc.(\buffers);
			~runFactoryFunc.(\buses);
			server.sync;
			//Prep hook, return false to cancel
			if (~onPrep.value != false) {
				~readyForPlay = true;
				if (playNow) {
					~play.value;
				};
			} {
				~freeResources.value;
			}
		}
	};

	//target
	//--parentGroup
	//----group1
	//------synth1
	//----group2
	//------synth2
	//Play
	//TODO: use bus arg
	~play = { |bus=0, target, addAction=\addToHead|

		"playing".postln;
		if (~readyForPlay.not) {
			//prepare and play
			~prep.value(true);
		} {
			if (~isPlaying.not) {
				~makeParentGroup.(target, addAction);
				~runFactoryFunc.(\groups);
				~runFactoryFunc.(\synths);

				//Play hook -- override for custom behaviour
				~onPlay.value;

				~isPlaying = true;
				~this.changed(\isPlaying, true);
			} {
				"already playing".warn;
			}
		}
	};

	~stop = {
		//stop hook. We run it first so we can free stuff there before
		~onStop.value;
		~this.changed(\playState, \stopped);

		//~parentGroupFreeMethod is set in ~makeParentGroup
		~parentGroup.perform(~parentGroupFreeMethod);

		~prResetContainers.value;

		~isPlaying = false;
		~this.changed(\isPlaying, false);

	};

	~restart = {
		~stop.value;
		~play.value; //FIXME store/use previous args
	};

	~freeResources = {
		~buses !? { ~buses.do(_.free) };
		~buffers !? { ~buffers.do(_.free) };
	};

	//Frees entire Proto
	~free = {
		if (~isPlaying) { ~stop.value };
		//Free hook
		~onFree.value;
		~freeResources.value;
		ServerTree.remove(currentEnvironment, ~server);
		~readyForPlay = false;
	};

	//Create parent group if it's not already set and playing
	~makeParentGroup = { |target, addAction|
		if (~parentGroup.isPlaying.not) {
			//If we have created the parentGroup, free it completely
			~parentGroupFreeMethod = \free;
			~parentGroup = Group(target, addAction).register(true);
		} {
			//If we have a parentGroup creted externally, just free everything inside
			//(But that's a bit weird also)
			~parentGroupFreeMethod = \freeAll;
		}
	};

	//Run factory functions inside buffer/bus environments. Pass any env variables from proto
	//as args to function (eg ~groups => { |groups| ... }
	~runFactoryFunc = { |sym|
		var envir = currentEnvironment;
		~factory[sym] !? { |func|
			currentEnvironment[sym].use({func.valueWithEnvir(envir.debug("% CE".format(sym)))});
		}
	};

	//Stuff to do on boot and cmd+period
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

};

