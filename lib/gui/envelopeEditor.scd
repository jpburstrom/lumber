//Mapping envelope editor
Proto {

	//Keep internal connections between model and ui
	~connections = ConnectionList();

	//Envelope values. These are updated from the ui
	~levels = [ 0.0, 0.5, 0.5, 1.0 ];
	~times = [ 0.4, 0.2, 0.4 ];
	~curves = [ -4, 0, 4 ];

	//Cached envelope. Envelope is regenerated on every value change.
	~envelope = Env(~levels, ~times, ~curves);

	//Get values as array
	~value = {
		[~levels, ~times, ~curves]
	};

	//Some envelope presets
	~presetGroup = {
		var labels, actions;
		var things = [
			"Linear": #[[ 0.0, 0.33, 0.67, 1.0 ], [ 0.33, 0.34, 0.33 ], [ 0, 0, 0 ]],
			"EaseInOut": #[[ 0.0, 0.5, 0.5, 1.0 ], [ 0.5, 0.0, 0.5 ], [ 4, 0, -4 ]],
			"EaseMid": #[[ 0.0, 0.5, 0.5, 1.0 ], [ 0.4, 0.2, 0.4 ], [ -4, 0, 4 ]],
			"UpDown": #[[ 0.0, 1, 1, 0 ], [ 0.33, 0.34, 0.33 ], [ 0, 0, 0 ]],
		].clump(2).collect({ |pairs|
			var label, env, action;
			#label, env = pairs;
			action = {
				env[0].do { |val, i| ~levels[i] = val };
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
	~boxGroup = { |key, size, range=#[0,1], step=0.01|
		var model = currentEnvironment[key];
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
				currentEnvironment.changed(\value);
			}.inEnvir).clipLo_(range[0]).clipHi_(range[1]).scroll_step_(step);
			~connections.add(currentEnvironment.signal(\value).connectTo({
				box.value = model[i];
			}.inEnvir));
			box;
		}
	};

	//Update cached envelope
	~updateEnvelope = {
		~envelope = Env(~levels, ~times, ~curves);
	};

	//Create and return window
	~makeWindow = {
		var sl1, sl2;
		var levelBoxes = ~boxGroup.(\levels, 4);
		var timeBoxes = ~boxGroup.(\times, 3);
		var curveBoxes = ~boxGroup.(\curves, 3, [-8, 8], 0.5);
		~win = Window.new.front.layout_(VLayout(
			HLayout(
				//First slider: mapped through envelope to second slider
				sl1 = Slider().action_({ |sl|
					sl2.value = ~envelope.at(sl.value);
				}.inEnvir),
				~eview = EnvelopeView().setEnv(~envelope).action_({ |z|
					//EnvelopeView edit updates levels and times. Curves are edited with number boxes
					~levels.putEach(Array.series(4), z.value[1]);
					~times.putEach(Array.series(3), z.value[0].differentiate[1..]);
					currentEnvironment.changed(\value, z);
				}.inEnvir).keepHorizontalOrder_(true),
				sl2 = Slider().enabled_(false)
			),
			GridLayout.rows(
				[[StaticText().string_("Levels")]].addAll(levelBoxes.collect { |x| [x, \columns, 2] }),
				[[StaticText().string_("Times"), \columns, 2]].addAll(timeBoxes.collect { |x| [x, \columns, 2] }),
				[[StaticText().string_("Curves"), \columns, 2]].addAll(curveBoxes.collect { |x| [x, \columns, 2] }),
			).margins_(0).spacing_(2),
			HLayout(
				~presetGroup.value,
				~actionGroup.value,
				//Run test with sliders
				Button().states_([["Slider test"]]).action_({
					{
						var steps = 100;
						steps.do { |i|
							sl1.valueAction = i / (steps-1);
							(1/steps).wait;
						}
					}.fork(AppClock)
				}),
				Button().states_([["Audio test"]]).action_({
					~envelope.test;
				}.inEnvir);

			).margins_(0).spacing_(2)

		)).onClose_({
			~connections.free;
		}.inEnvir);

		//This updates envelope and view on value change.
		//A bit redundant to re-set envelope on view, if view has edited envelope
		~connections.add(currentEnvironment.signal(\value).connectTo({
			~updateEnvelope.value;
			~eview.setEnv(~envelope);
		}.inEnvir));

		~win
	}
};
