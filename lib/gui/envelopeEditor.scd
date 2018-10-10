//Mapping envelope editor
{
	Proto {

		~presets = (
			Linear: #[[ 0.0, 0.33, 0.67, 1.0 ], [ 0.33, 0.34, 0.33 ], [ 0, 0, 0 ]],
			EaseInOut: #[[ 0.0, 0.5, 0.5, 1.0 ], [ 0.5, 0.0, 0.5 ], [ 4, 0, -4 ]],
			EaseMid: #[[ 0.0, 0.5, 0.5, 1.0 ], [ 0.4, 0.2, 0.4 ], [ -4, 0, 4 ]],
			UpDown: #[[ 0.0, 1, 1, 0 ], [ 0.33, 0.34, 0.33 ], [ 0, 0, 0 ]],
		);

		//Keep internal connections between model and ui
		~connections = ConnectionList();

		//For display purposes, corresponding to input spec of destination
		~spec = \unipolar.asSpec;

		//Envelope values. These are updated from the ui
		~levels = ~presets[\Linear][0].copy;
		~times = ~presets[\Linear][1].copy;
		~curves = ~presets[\Linear][2].copy;

		//Cached envelope. Envelope is regenerated on every value change.
		~envelope = Env(~levels, ~times, ~curves);

		~value_ = { |val|
			~levels = val[0];
			~times = val[1];
			~curves = val[2];
			~updateEnvelope.value;
		};

		//Get values as array
		~value = {
			[~levels, ~times, ~curves]
		};
		//Some envelope presets
		~presetGroup = {
			var labels, actions;
			var things = ~presets.asPairs.clump(2).collect({ |pairs|
				var label, env, action;
				#label, env = pairs;
				action = {
					env[0].do { |val, i| ~levels[i] = ~model.levels.spec.map(val) };
					env[1].do { |val, i| ~times[i] = val };
					env[2].do { |val, i| ~curves[i] = val };
					currentEnvironment.changed(\value);
				}.inEnvir;
				[label, action]
			});

			#labels, actions = things.flop;

			PopUpMenu().items_(["Presets"] ++ labels).action_({ |v|
				actions[v.value - 1].value;
				v.value = 0;
			}.inEnvir);
		};

		//Some actions
		~actionGroup = {
			var labels, actions;
			var things = [
				"Invert": { |env|
					~levels.do {|val, i| ~levels[i] = 1 - val };
					// ~envelope.curves.do {|val, i| ~envelope.curves[i] = val.neg };
				},
				"Normalize levels": { |env|
					var new = ~levels.copy;
					new = new * new.maxItem.max(0.01).reciprocal;
					~levels.putEach(Array.series(new.size), new);
					// ~envelope.curves.do {|val, i| ~envelope.curves[i] = val.neg };
				},
				"Slider test": {
					{
						var dur = 2;
						var steps = dur * 30;
						steps.do { |i|
							~testSlider.valueAction = i / (steps-1);
							(dur/steps).wait;
						}
					}.fork(AppClock)
				},
				"Audio test": {
					~envelope.test;
				}
			].clump(2).collect({ |pairs|
				var label, env, action;
				#label, env = pairs;
				action = ({ currentEnvironment.changed(\value) } <> env).inEnvir;
				[label, action]
			});

			#labels, actions = things.flop;

			PopUpMenu().items_(["Actions"] ++ labels).action_({ |v|
				actions[v.value - 1].value;
				v.value = 0;
			}.inEnvir);
		};

		//Group of number boxes, corresponding to levels/curves etc
		~boxGroup = { |key, size, step=0.01|
			var model = currentEnvironment[key];
			var spec = ~model[key].spec;
			size.collect { |i|
				var box = NumberBox().value_(model[i]).action_({ |box|
					if (key == \times) {
						var new;
						model[i] = box.value;
						new = model.normalizeSum;
						new.do { |val, i| model[i] = val };

					}  {
						model[i] = box.value;
					};
					currentEnvironment.changed(\value, key);
				}.inEnvir).clipLo_(spec.clipLo).clipHi_(spec.clipHi).scroll_step_(step);
				~connections.add(currentEnvironment.signal(\value).connectTo({
					box.value = model[i];
				}.inEnvir));
				box;
			}
		};

		//Update cached envelope
		~updateEnvelope = {
			~envelope = Env(~model.levels.spec.unmap(~levels), ~times, ~curves);
			~eview.setEnv(~envelope);
		};

		~prReactivateSynth = {
			if (~model[\active].value == \on) {
				//HACK: restart when env ha
				{
					~model[\active].toggle;
					Library.at(\lumber, \server).sync;
					~model[\active].toggle;
				}.fork(AppClock);
			}
		};


		//Create and return window
		~makeWindow = {
			var sl2;
			var lagU, lagD;
			var levelBoxes = ~boxGroup.(\levels, 4);
			var specBoxes =  4.collect {
				NumberBox().enabled_(false).background_(QPalette.light.window)
			};
			var timeBoxes = ~boxGroup.(\times, 3);
			var curveBoxes = ~boxGroup.(\curves, 3, 0.5);
			var enabledBox;

			value {
				var spec = ~model.levels.spec;
				~isBipolar = ((spec.clipHi.sign - spec.clipLo.sign) == 2);
			};

			~win !? {
				if (~win.isClosed.not) {
					~win.close
				}
			};
			~win = Window.new.front.layout_(VLayout(
				HLayout(
					//First slider: mapped through envelope to second slider
					~testSlider = Slider().action_({ |sl|
						sl2.value = ~envelope.at(sl.value);
					}.inEnvir),
					~eview = EnvelopeView().setEnv(~envelope).action_({ |z|
						//EnvelopeView edit updates levels and times. Curves are edited with number boxes
						~levels.putEach(Array.series(4), ~model.levels.spec.map(z.value[1]));
						~times.putEach(Array.series(3), z.value[0].differentiate[1..]);
						currentEnvironment.changed(\value, [\levels, \times]);
					}.inEnvir).keepHorizontalOrder_(true),
					sl2 = Slider().enabled_(false)
				),
				GridLayout.rows(
					[[StaticText().string_("Levels")]].addAll(levelBoxes.collect { |x| [x, \columns, 2] }),
					[[StaticText().string_("Output")]].addAll(specBoxes.collect { |x| [x, \columns, 2] }),
					[[StaticText().string_("Times"), \columns, 2]].addAll(timeBoxes.collect { |x| [x, \columns, 2] }),
					[[StaticText().string_("Curves"), \columns, 2]].addAll(curveBoxes.collect { |x| [x, \columns, 2] }),
					[
						[StaticText().string_("LagU"), \columns, 2],
						[lagU = NumberBox().scroll_step_(0.1), \columns, 2],
						[StaticText().string_("LagD"), \columns, 2],
						[lagD = NumberBox().scroll_step_(0.1), \columns, 2]
					]
				).margins_(0).spacing_(2),
				HLayout(
					HLayout(
						enabledBox = CheckBox(),
						StaticText().string_("Enabled").align_(\left).mouseDownAction_({
							~model.active.toggle;
						}.inEnvir),
						nil
					).spacing_(10),
					~presetGroup.value,
					~actionGroup.value,
				).margins_(0).spacing_(2)

			)).onClose_({
				~connections.free;
			}.inEnvir);

			//This updates envelope and view on value change.
			//A bit redundant to re-set envelope on view, if view has edited envelope
			~connections.add(currentEnvironment.signal(\value).connectTo(~updateEnvelope.inEnvir));

			~model !? {
				~connections.addAll(ConnectionList.make {
					enabledBox.signal(\value)
					.connectTo(~model[\active].inputSlot)
					.transform({|o, w, v| v; [o, w, v.asInteger]});
					~model[\active].signal(\value)
					.connectTo({ |cv|
						enabledBox.value = (cv.value == \on)
					});
					~model[\lagU].signal(\value).connectTo(lagU.valueSlot);
					~model[\lagD].signal(\value).connectTo(lagD.valueSlot);
					lagU.signal(\value).connectTo(~model[\lagU].valueSlot);
					lagD.signal(\value).connectTo(~model[\lagD].valueSlot);

					~model[\levels].connectTo({|levels|
						levels.value.do { |val, i|
							specBoxes[i].value = ~spec.map(val);
						};
					});
				});


				~updateEnvelope.value;
			};


			~eview.keyDownAction_({ |view, char, mod, unicode, keycode, key|
				if (key == 16777216) {
					false;
				} {
					view.defaultKeyDownAction(char, mod, unicode, keycode, key);
				}
			});

			~win.view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
				//Close window with ESC
				if (key == 16777216 or: { char == $w and: {mod.isCmd} }) {
					view.close
				}
			});

			~win
		}
	}

}