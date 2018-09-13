var layout, view, connections;

view = View().minWidth_(250).layout_(
    VLayout().margins_(10).spacing_(10);
);

connections.do(_.free);
connections = List();

//Loop over source -> parameter label list
q.macros.sources.do { |source|

    var paramLabels = q.macros.paramLabels[source];
    var knobColor = Color.rand;

    view.layout.add(StaticText().string_(source.asString).align_(\left).font_(Font.monospace));

    //Loop over parameter labels
    paramLabels.do { |config|
        var cb, sl, params;
		var label = config.name;
	    view.layout.add(
            View().layout_(
                HLayout(
                    StaticText().string_(label).minWidth_(75),
                    cb = CheckBox(),
                    sl = Slider().orientation_(\horizontal).knobColor_(knobColor)
                ).spacing_(10).margins_(0);
            )
        );

        params = q.macros.getParamsFor(source, label);

        connections.add(cb.signal(\value)
            .connectTo(params[\active].inputSlot)
            .transform({|o, w, v| [o, w, v.asInteger]})
        );

        connections.add(sl.signal(\value)
            .connectTo(params[\amount].inputSlot)
        );

        connections.add(params[\active].signal(\value)
            .connectTo(cb.valueSlot)
            .transform({|o, w, v| [o, w, v == \on]})
        );

        connections.add(params[\amount].signal(\value)
            .connectTo(sl.valueSlot)
        );
    };

    view.layout.add(20);

};
view.onClose_({
    connections.do(_.free)
}.inEnvir);


SCViewHolder().view_(view);