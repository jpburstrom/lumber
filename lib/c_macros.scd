p = Require("protos/serverPlayer", always:false).clone {

	//Bag of [src, dest] pairs. Pairs are added/removed when macros become "active".
	//They are used for playing and stopping synths from ~play and ~stop
	~activeDestinations = Bag();
	~activeInputs = Set();

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

			m.recursiveDo({ |source, destKey, inputKey, cvs|
				cvs.active.signal(\value).connectTo({ |v|
					if (v.value == \on) {
						//FIXME  this logic should be in playSynth/stopSynth instead

						if (e.activeDestinations.includes[destKey].not) {
							e.playSynth(source, destKey, inputKey);
						};
						//We add this every time to keep count
						e.activeDestinations.add([source, destKey]);
					} {
						e.activeDestinations;
						if (e.activeDestination.remove(destKey).includes([source, destKey]).not) {
							e.stopSynth(source, destKey, inputKey);
						}
					};
					// ~spawnSynth.value(source, dest);
				}.inEnvir)
			}, 4);



		};
	};



	//Prepare, create groups and buses
	//TODO create buses
	~onPrep = { |target|
		//Go through all specs and make synthdefs for them
		var e = currentEnvironment;

		//Loop through sources and destination and populate ~macroMapping dict
		//sourceKey -> destKey -> inputKey -> (spec: a ControlSpec, specDef: a SynthDef)
		~macroMapping = ();
		Library.at(\lumber, \common, \macroSources).do { |src|
			~macroMapping[src] = ().make {
				Library.at(\lumber, \common, \macroDestinations).keysValuesDo { |destKey, dest|
					currentEnvironment[destKey] = ().make {
						dest.inputs.do { |inputKey|
							currentEnvironment[inputKey] = (
								spec: dest.specs[inputKey],
								specDef: e.prMakeSpecSynthDef.(dest.specs[inputKey], src, destKey->inputKey)
							)
						}
					}
				}
			};
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
	~playSynth = { |src, dest, input|
		//TODO: use env var instead?
		var x = ~macroMapping[src][dest][input];
		var g;
		g = ~groups[src][dest] ?? {
			~groups[src][dest] = g = Group(~parentGroup);
			~synths[src][dest] = Synth(dest, [], g, \addToTail);
			~groups[src][dest];
		};
		//TODO enclose synths in group?
		x.specDef.postln !? { Synth(x.specDef, [], g, \addToHead) };
		"Spawn synth src:%, dest:%, input:%".format(src, dest, input).postln;
	};

	//Stop single dest synth
	//XXX should buses be kept or freed?
	~stopSynth = { |src, dest, input|
		//TODO add conditional logic, free if last playing destination
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
	//TODO: three args
	~prMakeSpecSynthDef = { |spec, src, dest|
		var name, func;
		spec = spec.asSpec;
		//TODO: better naming. All specs predefined?
		//TODO: lagud
		//TODO: move func to preset
		//TODO: use envir variables instead of prependArgs, + Environment.use: ~in, ~spec.
		func = Library.at(\lumber, \mapfunc, \src, \dest);
		name = Spec.findKeyForSpec(spec) ?? { "%_%".format(src, dest) };
		SynthDef("%SpecMapper".format(name), {
			var in = \in.kr(0);
			if (func.notNil) {
				in = SynthDef.wrap(func, prependArgs:[in, spec]);
			} {
				//no clipping on lincurve to allow inverted inMin/inMax (inMax < inMin)
				//clipping is done in Spec.map
				//FIXME But lag should probably be done before Spec.map, and after clipping. Hmm...
				in = spec.map(in.lincurve(\inMin.kr(0), \inMax.kr(1), 0, 1, \curve.kr(0), \none))
			};
			ReplaceOut.kr(\out.kr(0), in);
		}).add.name;

	};


};

