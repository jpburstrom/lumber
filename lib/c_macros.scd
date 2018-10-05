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
		~model = m.params;
		//Automagically add all created connections to ~connections
		~connections = ConnectionList.make {
			var keys = #[levels, times, curves, lagU, lagD];

			m.recursiveDo({ |source, destKey, inputKey, cvs|
				var synth, connections;
				cvs[\active].signal(\value).connectTo({ |v|
					switch(v.value,
						\on, {
							e.playSynth(source, destKey, inputKey) !? { |syn|
								synth = syn;
								connections = keys.collect({ |key|
									cvs[key];
								}).connectEach(\value, synth.argSlots(*keys));
							}
						},
						\off, {
							e.stopSynth(source, destKey, inputKey);
							connections.free;
						}
					);
				}.inEnvir);


			}, 4);



		};
	};

	//Prepare, create groups and buses
	//TODO create buses
	~onPrep = { |target|

		var makeDef = ~prMakeMappingDef.inEnvir;

		//Loop through sources and destination and populate ~allInputs dict
		//sourceKey -> destKey -> inputKey -> (spec: a ControlSpec, specDef: a SynthDef)
		~allInputs = ();
		Library.at(\lumber, \common, \macroSources).do { |src|
			~allInputs[src] = ().make { |srcMap|
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

		if (~isPlaying) {

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
		}

	};

	//Create group, bus and play synth
	~prPlayDestSynth = { |dest|
		var grp = Group(~parentGroup);
		~groups[dest] = grp;
		~buses[dest] = ();
		//TODO: synth arguments
		~synths[dest] = Synth(dest, [\out, ~buses.out], grp).debug("destSyn").register(true).onFree(~prResetDestination.inEnvir);
		~mappingSynths[dest] = MultiLevelIdentityDictionary();
	};


	//Play mapping synth
	~prPlayMappingSynth = { |src, dest, input|
		var def, bus, args, synth;
		//Get pre-generated mapping synthDef
		//FIXME
		def = ~allInputs[src][dest][input].mappingDef;
		//Create buses. Inputs from different sources share buses, so we make sure
		//we only create them once per input.
		bus = ~buses[dest][input] ?? {
			"creating bus for input %.%".format(dest, input).postln;
			~buses[dest][input] = bus = (
				//Main bus for input
				main: Bus.control(~server),
				//All routing synths play a 1 on a count bus,
				//which is used for scaling the output with a \controlBusMul synth.
				//This also makes it possible to fade in/out destinations smoothly,
				//by using the same attack/release on the count signal
				count: Bus.control(~server)
			);
			~mappingSynths[dest].put(\specMapping,
				Synth(def.name, [\bus, bus[\main]], ~synths[dest], \addBefore));
			~mappingSynths[dest].put(\controlBusDiv,
				Synth(\controlBusDiv,
					[\bus, bus[\main], \divisorBus, bus[\count]],
					~mappingSynths[dest][\specMapping], \addBefore));
			~synths[dest].map(input, bus[\main]);
			bus
		};
		//Go through all input params, exclude on/off and make synthdef args
		args = ~model[src][dest][input].reject({ |v, k|
			k == \active
		}).collect(_.value).asPairs;

		args = args ++ [\inbus, ~buses.debug("buses")[src.postln], \outbus, bus.main, \countbus, bus[\count]];

		//Play input mapping synth
		synth = Synth(\inputMapper, args, ~groups[dest], \addToHead).register(true).onFree({
			~mappingSynths[dest].removeAt(src, input);
			~activeInputs.remove([src, dest, input]);
		}.inEnvir);

		~mappingSynths[dest].put(src, input, synth.debug("inputMapper"));
		~activeInputs.add([src, dest, input]);
	};

	~stopSynth = { |src, dest, input|
		if (~activeDestinations.remove(dest).includes(dest).not) {
			"Stopping destination synth %".format(dest).postln;
			//Will free group from doneAction.
			//Group & synth counters are released from .onFree above
			~synths[dest].release;
		} {
			//synth counters are released from .onFree above
			~mappingSynths[dest].at(src, input).release;
		}
	};

	~onFree = {
		~mappingSynths.do(_.unregister);
		~synths.do(_.unregister);
		~connections.do(_.free);
	};

	//Reset counters and bags for destination
	//Called from ~synths[dest].onFree
	~prResetDestination = { |dest|
		//XXX should buses be kept or freed?
		~buses[dest].free;
		~buses[dest] = nil;
		~groups[dest] = nil;
		~synths[dest] = nil;
		//Empty counters to be sure
		~activeDestinations.remove(dest, inf);
		~activeInputs = ~activeInputs - ~activeInputs.select({ |x| x[1] == dest});
	};


	//Make a synthdef from given spec
	//Name after Spec.specs key, or src_dest
	//TODO: three args
	~prMakeMappingDef = { |spec, src, dest, input|
		var name, func;
		spec = spec.asSpec;
		name = Spec.findKeyForSpec(spec) ?? { "%@%".format(input, dest) };
		//This should run last before input,
		//maps 0-1 to input spec
		SynthDef("%SpecMapper".format(name), { |bus=0|
			ReplaceOut.kr(bus, spec.map(In.kr(bus)));
		}).add(\lumber);

	};


};

