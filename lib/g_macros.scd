var layout, view, connections;

var scroll = ScrollView().minWidth_(360).hasHorizontalScroller_(false).autohidesScrollers_(false);
view = View().minWidth_(350).layout_(
    VLayout().margins_(10).spacing_(10);
);

scroll.canvas = view;
scroll.hasBorder = false;

connections.do(_.free);
connections = ConnectionList();

//Loop over source -> parameter label list
Library.at(\lumber, \common, \macroSources).do { |source|

    var paramLabels = q.macros.paramLabels[source];
    var knobColor = Color.rand;
	var txt = { |str|
		StaticText().string_(str).font_(Font.default.size_(9)).align_(\center)

	};
	view.layout.add(StaticText().string_("~" ++ source.asString.toUpper ++ "~").align_(\left));

	//Loop over parameter labels
	//Sort alphabetically
	paramLabels.keys.asArray.sort.do { |key|
		var config = paramLabels[key];
        var params;
		var specs = Spec.specs.select(_.isKindOf(ControlSpec)).keys.asArray.sort { |x, y|
			var lx = x.asString.find("lumber", true).notNil;
			var ly = y.asString.find("lumber", true).notNil;
			//Sort non-lumber key after lumber key
			if (lx.xor(ly)) {
				lx
			} {
				//if no lumber key or only lumber keys, sort alphabetically
				x < y
			}
		};
		var label = config.name;
		var cb, sl, nbx;
		var subview;
		var active = false;
		var inactiveColor = Color.fromHexString("ccc");

		sl = { |i|
			Slider().orientation_(\horizontal).value_(i).maxHeight_(20)
		} ! 2;
		nbx = { |i|
			NumberBox().enabled_(false)
			.background_(inactiveColor).maxHeight_(20).maxWidth_(35).value_(i)
		} ! 2;

	    view.layout.add(
            subview = View().layout_(
                GridLayout.columns(
					[txt.(""), StaticText().string_(label).minWidth_(75)],
					[txt.("On"), cb = CheckBox()],
					[txt.("Range")] ++
					2.collect { |i| HLayout( sl[i], nbx[i] ).margins_([10, 0, 0, 0]).spacing_(10) }

				).spacing_(0).margins_([0, 0, 10, 0]);
            )
        );

		//FIXME q.macros global variable
        params = q.macros.getParamsFor(source, label);

		// curve.action = { |v| env.curves = v.value.linlin(0,1, -8, 8)};

		cb.action = { |v|
			active = v.value.asBoolean;
			sl.do(_.enabled = active);
		};

		2.do { |i|
			var p = params[#[from, to][i]];
			connections.add(sl[i].signal(\value).connectTo(nbx[i].valueSlot));
			connections.add(sl[i].signal(\value).connectTo(p.valueSlot));
			connections.add(p.signal(\value).connectTo(sl[i].valueSlot));
			connections.add(p.signal(\value).connectTo(nbx[i].valueSlot));
		};

		connections.add(cb.signal(\value)
			.connectTo(params[\active].inputSlot)
			.transform({|o, w, v| [o, w, v.asInteger]})
		);
		connections.add(params[\active].signal(\value)
			.connectTo(cb.valueSlot)
			.transform({|o, w, v| [o, w, v == \on]})
		);
		// slFrom.signal(\value).connectTo(params[\from])



		//No more headers
		txt = nil;
    };

    view.layout.add(20);

};
view.onClose_({
    connections.free;
}.inEnvir);


scroll.front;