p = Require("protos/serverPlayer", always:false).clone {

	//Reset containers of freeable stuff
	//Assumes things have already been freed
	//Redefinition
	~prResetContainers = {
		//Bag of [src, dest] pairs. Pairs are added/removed when macros become "active".
		//They are used for playing and stopping synths from ~play and ~stop
		~activeDestinations = Bag();
		~activeInputs = Set();

		~groups = ();
		//Destination synths
		~synths = ();
		//Mapping synths. dest = MultiLevelIdentityDictionary(source, input, Synth())
		~mappingSynths = ();

	};

	//Need to do this to update data structure
	~prResetContainers.value;

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
					switch(v.value,
						\on, { e.playSynth(source, destKey, inputKey) },
						\off, { e.stopSynth(source, destKey, inputKey) }
					);
				}.inEnvir)
			}, 4);



		};
	};

	//Prepare, create groups and buses
	//TODO create buses
	~onPrep = { |target|

		var makeDef = ~prMakeMappingDef.inEnvir;

		//Loop through sources and destination and populate ~macroMapping dict
		//sourceKey -> destKey -> inputKey -> (spec: a ControlSpec, specDef: a SynthDef)
		~macroMapping = ();
		Library.at(\lumber, \common, \macroSources).do { |src|
			~macroMapping[src] = ().make { |srcMap|
				Library.at(\lumber, \common, \macroDestinations).keysValuesDo { |destKey, dest|
					srcMap[destKey] = ().make { |destMap|
						dest.inputs.do { |inputKey|
							destMap[inputKey] = (
								//spec for input
								spec: dest.specs[inputKey],
								//Mapping synthdef f
								mappingDef: makeDef.(dest.specs[inputKey], src, destKey, inputKey)
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
		//FIXME
		~activeRoutings.asArray.flatten.pairsDo { |src, dest|
			~playSynth.(src, dest);
		};

	};

	//source->[busA]->specMapper->[busB]->destination
	//busA is (currently) defined in c_server
	//source synths are spawned in c_server as well
	//specMapper has bus index input
	//
	//destination input is regular control (not In.kr)

	//MIXING SEVERAL SOURCES to same input
	//sourceA->[busA]->specMapperA->[busX]
	//sourceB->[busB]->specMapperB->[busX]
	//specMapperA/B
	//blend/LinXFade2
	//But how check that we need to blend?
	//ReplaceOut.ar(bus, LinXFade.ar(snd, In.ar(bus), \blend.kr(0)))
	//Synth 1: Play on bus
	//Synth 2: Play on bus, add to tail, set \blend to 0.5
	//but then synth 3 will be double weight compared to 1 & 2

	//sourceA->[busA]->				specMapperA->[busX]->syn
	//sourceB->[busB]->specMapperB/


	//Spawn single dest synth + mapping
	//TODO play on designated busses
	//TODO map mapping input to src output bus
	//TODO map dest input to mapping output bus
	~playSynth = { |src, dest, input|
		//TODO: use env var instead?



		if (~activeInputs.includes([src, dest, input]).not) {
			if (~activeDestinations.includes(dest).not) {
				~prPlayDestSynth.(dest);
			};
			~prPlayMappingSynth.(src, dest, input);
			//Add another instance to the bag
			~activeDestinations.add(dest);
			"Spawn synth src:%, dest:%, input:%".format(src, dest, input).postln;
		} {
			"Already playing src: %, dest: %, input: %".format(src, dest, input).postln;
		};

	};

	//Create group and play synth
	~prPlayDestSynth = { |dest|
		var grp = ~groups[dest] = Group(~parentGroup);
		//TODO: synth arguments
		~synths[dest] = Synth(dest, [], grp).register(true).onFree(~prResetDestination.inEnvir);
		~mappingSynths[dest] = MultiLevelIdentityDictionary();
	};


	//Play mapping synth
	~prPlayMappingSynth = { |src, dest, input|
		//Go through all input params, exclude on/off and make synthdef args
		//TODO: get mapping synthdef
		var args = ~macroMapping[src][dest][input].reject({ |v, k|
			k == \active
		}).collect(_.value).asPairs;

		//TODO: set mapping def
		var def = \ping;

		~activeInputs.add([src, dest, input]);
		~mappingSynths[dest].put(
			src, input,
			Synth(def, args, ~groups[dest], \addToHead).register(true).onFree({
				~mappingSynths[dest].removeAt(src, input);
				~activeInputs.remove([src, dest, input])
			}.inEnvir)
		);
	};

	~stopSynth = { |src, dest, input|
		if (~activeDestination.remove(dest).includes(dest).not) {
			"Stopping destination synth %".format(src).postln;
			//Will free group from doneAction.
			//Group & synth counters are released from .onFree above
			~synths[dest].release;
		} {
			//synth counters are released from .onFree above
			~mappingSynths[dest].at(src, input).release;
		}
	};

	~onFree = {
		~connections.do(_.free);
	};

	//Reset counters and bags for destination
	//Called from ~synths[dest].onFree
	~prResetDestination = { |dest|
		//XXX should buses be kept or freed?
		~groups[dest] = nil;
		~synths[dest] = nil;
		//Empty counters to be sure
		~activeDestination.remove(dest, inf);
		~activeInputs = ~activeInputs - ~activeInputs.select({ |x| x[1] == dest});
	};


	//Make a synthdef from given spec
	//Name after Spec.specs key, or src_dest
	//TODO: three args
	~prMakeMappingDef = { |spec, src, dest, input|
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

