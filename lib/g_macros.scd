var layout, view, connections;

var scroll = ScrollView().minWidth_(360).hasHorizontalScroller_(false).autohidesScrollers_(false);
view = View().minWidth_(350).layout_(
    VLayout().margins_(10).spacing_(10);
);

scroll.canvas = view;
scroll.hasBorder = false;

connections.do(_.free);
connections = List();



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
		var cb, sl, nbx1, nbx2, specpp, specfield, invcb, invlabel;
		var subview;
		var active = false;
		var inactiveColor = Color.fromHexString("ccc");

	    view.layout.add(
            subview = View().layout_(
                GridLayout.columns(
					[txt.(""), StaticText().string_(label).minWidth_(75)],
					[txt.("On"), cb = CheckBox()],
					[
						txt.("Range"),
						sl = RangeSlider().orientation_(\horizontal),
						HLayout(
							nbx1 = NumberBox().enabled_(false).background_(inactiveColor).maxWidth_(35),
							nil,
							nbx2 = NumberBox().enabled_(false).background_(inactiveColor).maxWidth_(35)
						),

					],
					[
						txt.("Inv"),
						invcb = CheckBox().toolTip_("Invert"),
						invlabel = StaticText().string_(" / "),
					]
				).spacing_([2,5]).margins_([0, 0, 10, 0]);
            )
        );

        params = q.macros.getParamsFor(source, label);

		// curve.action = { |v| env.curves = v.value.linlin(0,1, -8, 8)};

		cb.action = { |v|
			active = v.value.asBoolean;
			[sl, invcb].do(_.enabled = active);
		};

		invcb.action = { |v|
			var lbl = [" / ", " \\ "];
			invlabel.string_(lbl[v.value.asInteger]);
		};

		sl.action = { |v|
			nbx1.value = v.lo;
			nbx2.value = v.hi;
		};

		cb.valueAction_.(_.value);


		/*
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
		*/

		//No more headers
		txt = nil;
    };

    view.layout.add(20);

};
view.onClose_({
    connections.do(_.free)
}.inEnvir);


scroll.front;