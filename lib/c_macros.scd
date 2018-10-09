p = Require("protos/serverPlayer", always:false).clone {

	~factory.make {
		~synths = { |activeSources, activeDestinations, mappingSynths, buses, groups, server|
			//TODO later maybe move these to c_macros
			Library.at(\lumber, \common, \macroSources).keysValuesDo { |src, conf|
				groups[src] = Group( groups[conf[\group] ? \sensors] );
				currentEnvironment[src] = Synth(src, [\out, buses[src]], groups[src]);
				activeSources.add(src);
				if (conf.destination == true) {
					buses[src] = ();
					activeDestinations.add(src);
					mappingSynths[src] = MultiLevelIdentityDictionary();
				};

			};
			server.sync;
			if (server.name == \bela) {
				[\activity, \intensity].do { |x|
					GestureRT.loadPipeline(
						Library.at(\lumber, \common, \belaRoot) +/+ "data/grt/%.grt".format(x),
						currentEnvironment[x], server);
				};
			}
		};
	};

	//Don't empty on reset, we need it to keep previously active inputs
	~pendingInputs = Set();

	//Reset containers of freeable stuff
	//Assumes things have already been freed
	//Redefinition
	~prResetContainers = {

		~activeSources = Set(); //Always playing
		//Bag of [src, dest] pairs. Pairs are added/removed when macros become "active".
		//They are used for playing and stopping synths from ~play and ~stop
		~activeDestinations = Bag();
		~activeInputs = Set();
		//Inputs waiting for onPlay to play

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
	~connect = { |m|
		var e = currentEnvironment;
		~model = m.params;
		//Automagically add all created connections to ~connections
		~connections = ConnectionList.make {
			var keys = #[levels, times, curves, lagU, lagD];

			m.recursiveDo({ |source, destKey, inputKey, cvs|
				var connections;
				cvs[\active].signal(\value).connectTo({ |v|
					switch(v.value,
						\on, {
							e.playSynth(source, destKey, inputKey) !? { |syn|
								connections = keys.collect({ |key|
									cvs[key];
								}).connectEach(\value, syn.argSlots(*keys));
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
	~onPrep = { |target|

		var makeDef = ~prMakeMappingDef.inEnvir;

		//Loop through sources and destination and populate ~allInputs dict
		//sourceKey -> destKey -> inputKey -> (spec: a ControlSpec, specDef: a SynthDef)
		~allInputs = ();
		Library.at(\lumber, \common, \macroSources).keysValuesDo { |src, sourceconf|
			~allInputs[src] = ().make { |srcMap|
				Library.at(\lumber, \common, \macroDestinations).keysValuesDo { |destKey, dest|
					srcMap[destKey] = ().make { |destMap|
						dest.inputs.do { |inputKey|
							destMap[inputKey] = (
								outputSpec: sourceconf[\outputSpec].asSpec,
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
	~onPlay = {
		~pendingInputs.asArray.do { |srcDestInput|
			~playSynth.(*srcDestInput);
		};
		~pendingInputs.clear;

	};

	//Spawn single dest synth + mapping
	~playSynth = { |src, dest, input|
		var synth;
		if (~isPlaying) {

			if (~activeInputs.includes([src, dest, input]).not) {
				if (~activeDestinations.includes(dest).not) {
					~prPlayDestSynth.(dest);
				};
				synth = ~prPlayMappingSynth.(src, dest, input);
				//If dest is not also source, add another item to the bag.
				//Otherwise destination is playing continously
				if (~activeSources.includes(dest).not) {
					~activeDestinations.add(dest);
				};
				"Spawn synth src:%, dest:%, input:%".format(src, dest, input);
			} {
				"Already playing src: %, dest: %, input: %".format(src, dest, input);
			};
			synth;
		} {
			//IF not playing, add to pending inputs
			~pendingInputs.add([src, dest, input]);
			nil;
		};

	};

	//Create group, bus and play synth
	~prPlayDestSynth = { |dest|
		var metadata = Library.at(\lumber, \common, \macroDestinations)[dest];
		var grp = Group(~groups[metadata[\group] ? \fx]);
		~groups[dest] = grp;
		~buses[dest] = ();
		~synths[dest] = Synth(dest,
			[\out, ~buses.out], grp).register(true).onFree(~prResetDestination.inEnvir);
		~mappingSynths[dest] = MultiLevelIdentityDictionary();
		//Set all params to default value
		metadata.inputs.do { |input|
			~synths[dest].set(input, metadata[\specs][input].asSpec.default);
		};
	};


	//Play mapping synth
	~prPlayMappingSynth = { |src, dest, input|
		var def, bus, args, synth, spec, outputSpec;

		 ~allInputs[src][dest][input].use {
			spec = ~spec.asSpec;
			def = ~mappingDef;
			outputSpec = ~outputSpec;
		};

		//Create buses. Inputs from different sources share buses, so we make sure
		//we only create them once per input.
		bus = ~buses[dest][input] ?? {
			"creating bus for input %.%".format(dest, input);
			~buses[dest][input] = bus = (
				//Main bus for input
				main: Bus.control(~server),
				//All routing synths play a 1 on a count bus,
				//which is used for scaling the output with a \controlBusMul synth.
				//This also makes it possible to fade in/out destinations smoothly,
				//by using the same attack/release on the count signal
				count: Bus.control(~server)
			);
			//Mapping 0-1 to spec range
			~mappingSynths[dest].put(\specMapping,
				Synth(def.name, [\bus, bus[\main]], ~synths[dest], \addBefore));
			//Divides input from n mapping synths to fit in 0-1 range
			~mappingSynths[dest].put(\controlBusDiv,
				Synth(\controlBusDiv,
					[\bus, bus[\main], \divisorBus, bus[\count]],
					~mappingSynths[dest][\specMapping], \addBefore)
			);
			//Value is already within spec range, so we put it closest to dest synth
			~mappingSynths[dest].put(\controlBusValue,
				Synth(\controlBusValue,
					[\bus, bus[\main], \divisorBus, bus[\count], \value, spec.unmap(spec.default)],
					~mappingSynths[dest][\specMapping], \addBefore)
			);
			~synths[dest].map(input, bus[\main]);
			bus
		};
		//Go through all input params, exclude on/off and make synthdef args
		args = ~model[src][dest][input].reject({ |v, k|
			k == \active
		}).collect(_.value).asPairs;

		args = args ++ [\inbus, ~buses[src], \outbus, bus.main, \countbus, bus[\count]];

		//Play input mapping synth
		//Check for bipolar specs
		synth = if (abs(outputSpec.minval.sign - outputSpec.maxval.sign).postln == 2) {
			//Put bipolar mapping right before spec mapping
			//So controlBusDiv doesn't affect the output
			Synth(\inputMapperBipolar, args, ~mappingSynths[dest][\specMapping], \addBefore);
		} {
			Synth(\inputMapper, args, ~groups[dest], \addToHead)
		};

		synth.register(true).onFree({
			~mappingSynths[dest] !? { |x| x.removeAt(src, input) };
			~activeInputs.remove([src, dest, input]);
		}.inEnvir);

		~mappingSynths[dest].put(src, input, synth);
		~activeInputs.add([src, dest, input]);
		synth
	};

	~stopSynth = { |src, dest, input|
		var notSource = ~activeSources.includes(dest).not;
		if (notSource) {
			~activeDestinations.remove(dest);
		};
		if (~activeDestinations.includes(dest).not) {
			// "Stopping destination synth %".format(dest);
			//Will free group from doneAction.
			//Group & synth counters are released from .onFree above
			~synths[dest].release;
		} {
			//synth counters are released from .onFree above
			~mappingSynths[dest] !? { |x| x.at(src, input).release };
		}
	};

	~onStop = {
		~mappingSynths.do { |mlid|
			mlid.leafDo { |path, syn| syn.unregister };
		};
		~synths.do(_.unregister);
		~pendingInputs = ~activeInputs.copy;
		~activeInputs.clear;
	};

	~onFree = {
		~connections.do(_.free);
	};

	//Reset counters and bags for destination
	//Called from ~synths[dest].onFree
	~prResetDestination = { |dest|
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

