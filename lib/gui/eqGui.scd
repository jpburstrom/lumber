var layout, view, connections;

view = View().minWidth_(600).minHeight_(400).layout_(
    HLayout().margins_(10).spacing_(10);
);

connections.do(_.free);
connections = List();

//Loop over source -> parameter label list
q.eq.params.keys.asArray.sort.do { |midinote|

	var cv = q.eq.params[midinote];
	var knobColor = Color.rand;
	var sl, label = midinote.midiname.asString;

	view.layout.add(
		View().layout_(
			VLayout(
				sl = Slider().orientation_(\vertical).knobColor_(knobColor),
				StaticText().fixedWidth_(25).string_(label)
			).spacing_(10).margins_(2);
		)
	);

	connections.add(sl.signal(\value).connectTo(cv.inputSlot));
	connections.add(cv.signal(\input).connectTo(sl.valueSlot));

};
view.onClose_({
    connections.do(_.free)
}.inEnvir);


SCViewHolder().view_(view);