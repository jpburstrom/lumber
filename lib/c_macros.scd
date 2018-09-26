(
m = Require("protos/serverPlayer", always:false).clone {

	//Set of [src, dest] pairs. Pairs are added/removed when macros become "active".
	//They are used for playing and stopping synths from ~play and ~stop
	~activeRoutings = Set();

	//Source is playing in ~sensors or ~lfo on ~bus (Synth("macro_%".format(~source)))
	//dest is playing in ~fx or ~lfo, (sensor can control lfo)

	//Connect model to controller.
	//Connect macro.source.dest.active cv's to play/stop synths
	//TODO: connect other cvs (mapping-related) to methods
	~connect = { |m|
		var e = currentEnvironment;
		~model = m;
		//Automagically add all created connections to ~connections
		~connections = ConnectionList.make {
			m.params.keysValuesDo { |source, obj|
				obj.keysValuesDo { |dest, cvs|
					/*
					if (cvs.active.value == \on) {
					~spawnSynth.value(source, dest);
					};
					*/
					dest = dest.toLower;
					cvs.active.signal(\value).connectTo({ |v|
						var method;
						if (v.value == \on) {
							method = \playSynth;
							e.activeRoutings.add([source, dest]);
						} {
							method = \stopSynth;
							e.activeRoutings.remove([source, dest]);
						};
						if (e.isPlaying) {
							e.perform(method, source, dest);
						}
						// ~spawnSynth.value(source, dest);
					}.inEnvir)

				};

			};
		};
	};

	//Prepare, create groups and buses
	//TODO create buses
	~onPrep = { |target|
		//Go through all specs and make synthdefs for them
		~macroMapping = Library.at(\lumber, \common, \macroMapping);
		~macroMapping.keysValuesDo { |src, o|
			o.keysValuesDo { |dest, conf|
				conf.spec !? { conf.specDef = ~prMakeSpecSynthDef.(conf.spec, src, dest) }
			}
		};
	};

	//Play everything
	//TODO play sources?m
	~onPlay = {

		~activeRoutings.asArray.flatten.pairsDo { |src, dest|
			~playSynth.(src, dest);
		};

	};

	//Spawn single dest synth + mapping
	//TODO play on designated busses
	//TODO map mapping input to src output bus
	//TODO map dest input to mapping output bus
	~playSynth = { |src, dest|
		//TODO: use env var instead?
		var x = ~macroMapping[src][dest];
		var g;
		~groups[src][dest] = g = Group(~parentGroup);
		//TODO enclose synths in group?
		x.specDef !? { Synth(x.specDef, [], g) };
		~synths[src][dest] = Synth(x.def, [], g, \addToTail);
		"Spawn synth src:%, dest:%".format(src, dest).postln;
	};

	//Stop single dest synth
	//XXX should buses be kept or freed?
	~stopSynth = { |src, dest|
		~groups[src][dest].free;
		~groups[src][dest] = nil;
		~synths[src][dest] = nil;
	};

	~onFree = {
		~connections.do(_.free);
	};

	//Reset containers of freeable stuff
	//Assumes things have already been freed
	//Redefinition
	~prResetContainers = {
		~groups = ();
		~synths = ();
		Library.at(\lumber, \common, \macroSources).do {|k|
			~groups[k] = ();
			~synths[k] = ();
		}
	};

	//Need to do this to update data structure
	~prResetContainers.value;

	//Make a synthdef from given spec
	//Name after Spec.specs key, or src_dest
	~prMakeSpecSynthDef = { |spec, src, dest|
		var name;
		spec = spec.asSpec;
		name = Spec.findKeyForSpec(spec) ?? { "%_%".format(src, dest) };
		SynthDef("%SpecMapper".format(name), {
			ReplaceOut.kr(\out.kr(0), spec.map(\in.kr(0).lincurve(\inMin.kr(0), \inMax.kr(1), 0, 1, \curve.kr(0))));
		}).add.name;

	};


};

)

