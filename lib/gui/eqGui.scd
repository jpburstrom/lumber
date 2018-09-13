var layout, view, connections;
var elements = q.eq.params.size;
var rows = 2;
var sliderWidth = 35;
var fullWidth = (sliderWidth * elements / rows) + (4 * elements / rows);

view = View().minWidth_(fullWidth).minHeight_(400).layout_(
	VLayout(*rows.collect{ HLayout() }).margins_(0).spacing_(0)
);

connections.do(_.free);
connections = List();

//Loop over source -> parameter label list
q.eq.params.keys.asArray.sort.do { |midinote, i|

	var cv = q.eq.params[midinote];
	var background = Color.white, knobColor = Color.rand;
	var task, oldval, sl, txt,
		label = midinote.midiname.asString;
	if (label.includes($#) or: {label.includes($b)}) {
		background = nil;
	};
	view.layout.children[i.div(elements/rows)].add(
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
view.onClose_({
    connections.do(_.free)
}.inEnvir);


SCViewHolder().view_(view).front;