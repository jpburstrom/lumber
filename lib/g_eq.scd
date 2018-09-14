var layout, view, connections;
var elements = q.eq.params.size;
var rows = 2;
var sliderWidth = 35;
var fullWidth = (sliderWidth * elements / rows) + (4 * elements / rows);
//FIXME: don't hardcode?
var params = q.eq.params;

var fact = (
	paramSlider: { |self, label, cv|
		var lbl, sl, out;
		out = VLayout(
			HLayout(
				StaticText().string_(label),
				lbl = StaticText()
					.string_("% %".format(20, cv.spec.units))
					.align_(\right).font_(Font.monospace.size_(10)),
			),
			sl = Slider().orientation_(\horizontal)
		);
		connections.add(sl.signal(\value).connectTo(cv.inputSlot));
		connections.add(cv.signal(\input).connectTo(sl.valueSlot));
		connections.add(cv.signal(\value).connectTo(
			lbl.methodSlot("string_(\"%" ++ cv.spec.units ++ "\".format(value.round(0.1)))")));
		out;
	};
);
Connection.traceAll = false;

view = View().minWidth_(fullWidth).minHeight_(400).layout_(
	VLayout(Require("gui/eqview"), *(rows + 1).collect{ HLayout() }).margins_(0).spacing_(0)
);

//Loop over source -> parameter label list
//FIXME: q.eq
Require("common").eqSemitones.asArray.sort.do { |midinote, i|

	//FIXME: Hardcoded reference to q.eq
	var cv = params[midinote];
	var background = Color.white, knobColor = Color.rand;
	var task, oldval, sl, txt,
		label = midinote.midiname.asString;
	if (label.includes($#) or: {label.includes($b)}) {
		background = nil;

	};
	// view.layout.children.postln;
	view.layout.children[(i.div(elements/rows))].add(
		View().layout_(
			VLayout(
				sl = Slider().orientation_(\vertical)
					.background_(background).knobColor_(knobColor),
				txt = StaticText().string_(label)
				.font_(Font.monospace.size_(10)).align_(\center);
			).spacing_(10).margins_(2);
		).fixedWidth_(sliderWidth);
	);

	connections.add(sl.signal(\value).connectTo(cv.inputSlot));
	connections.add(cv.signal(\input).connectTo(sl.valueSlot));

	oldval = cv.value;

	task = SkipJack({
		var lbl, count = 1;
		var totalTime = 1;
		var waitTime = 0.1;
		while { count > 0 } {
			if (oldval != cv.value) {
				count = totalTime / waitTime;
				//If label is nil, set label to note name.
				lbl ?? {
					lbl = txt.string;
				};
				oldval = cv.value;
				txt.string = oldval.round(0.1).asString;
			};
			count = count - 1;
			0.1.wait;
		};
		//If value has been set, reset to notename here
		lbl !? {
			txt.string = lbl;
		}

	}, 0.05);

	//Reset to zero + dB inc/dec
	//Key sets cv value
	//j: down
	//k: up
	//0: zero
	sl.keyDownAction = { |view, char, modifiers, unicode, keycode, key|
		var inc = case
		{ modifiers.isCmd } { 3 }
		{ modifiers.isShift } { 0.1 }
		{ 1 };
		switch(key,
			//0
			48, {
				cv.value = 0;
			},
			//k
			75, {
				cv.value = cv.value + inc;
			},
			//j
			74, {
				cv.value = cv.value - inc;
			}
		);
		sl.defaultKeyDownAction(char, modifiers, unicode, keycode, key);
	};

};

view.layout.children[2].add(View().layout_(HLayout(
	View().layout_(VLayout(
		StaticText().string_("Low cut").align_(\center),
		fact.paramSlider("Freq", params[\lowCut][\freq])
	).margins_(5).spacing_(5).add(nil)),
	View().layout_(VLayout(
		StaticText().string_("Hi shelf").align_(\center),
		fact.paramSlider("Freq", params[\hiShelf][\freq]),
		fact.paramSlider("RS", params[\hiShelf][\rs]),
		fact.paramSlider("Gain", params[\hiShelf][\db]),
		// nil
	).margins_(5).spacing_(5)),
	View().layout_(VLayout(
		StaticText().string_("Preamp").align_(\center),
		fact.paramSlider("Gain", params[\preamp][\db]),
		nil
	).margins_(5).spacing_(5)),
	nil
)));


view.onClose_({
    connections.do(_.free)
}.inEnvir);


SCViewHolder().view_(view).front;