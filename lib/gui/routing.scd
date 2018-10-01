//TODO: use curve
var width = 25;
var sources = Library.at(\lumber, \common, \macroSources);
var destinations = Library.at(\lumber, \common, \macroDestinations);
var activeHeaders = nil ! 2;
//highlight headers for currently mouseover'd cell
var activateHeaders = { |x, y|
	activeHeaders.do { |h| h !? { h.stringColor_(Color.black) } };
	activeHeaders = [x, y];
	activeHeaders.do(_.stringColor_(Color.red));
};
var destString = { |dest, input|
	"%:%".format(destinations[dest].label, input);
};
var destinationKeys = destinations.keys.asArray.sort;
//StaticTexts
var destinationHeaders = destinationKeys.collect({ |k|
	destinations[k].inputs.collect { |input|
		var txt = destString.(k, input);
		StaticText().fixedWidth_(width).string_(txt[..2]).font_(Font.monospace.size_(10)).toolTip_(txt)
	}
}).flatten;
var view = View().layout_(GridLayout.rows(
	//Top Headers
	[nil] ++ destinationHeaders.collect { |h|
		HLayout(
			h.align_(\center),
			LevelIndicator().fixedHeight_(width).fixedWidth_(5)
		)
	},
	//Sources are rows
	*sources.collect { |source, i|
		var sourceHeader;
		var destWidgets = List();
		var counter = -1;
		//First column: source header

		//One cell for every destination input
		//destinations are synthdefs with metadata
		//dest.specs has inputs
		//We just grab all of them, but maybe it would be better to use lumber.inputs or similar
		destinations.keysValuesDo({ |destKey, dest|
			dest.inputs.do { |inputKey|
				//TODO: These values should be collected from CVs somewhere
				var from = 0;
				var to = 0;
				//FIXME Curve is not implemented yet
				var curve = 0;
				var enabled = false;

				var spec = dest.specs[inputKey];
				var uview;
				var i = counter = (counter + 1);

				var openRouting = { |view, x, y|

					var
					//Slider numberbox
					nbxf, nbxt,
					//Enabled checkbox
					cb,
					//Slider to & from
					slt, slf,
					//Number boxes
					specFrom, specTo,
					//test to enable if moving slider
					cbtest = enabled;

					Window(bounds: Window.flipY(Rect(0, 0, 200, 50).center_(view.mapToGlobal(x@y)))).layout_(VLayout(
						HLayout(
							cb = CheckBox().value_(enabled).action_{ |cb|
								enabled = cb.value
							},
							StaticText().string_("% ▷ %".format(source, destString.(destKey, inputKey))).font_(Font.monospace.size_(10)).minWidth_(200)
						),
						HLayout(
							[StaticText().string_("From").font_(Font.monospace.size_(10)), s:1],
							[slf = Slider().orientation_(\horizontal).action_({|sl|
								if (cbtest.not) {
									cb.valueAction_(true);
									cbtest = true; //Only first time
								};
								from = sl.value;
								nbxf.value = from;
								specFrom.value = spec.map(from);
								view.refresh;
							}), s:5],
							[nbxf = NumberBox(), s:1]
						),
						HLayout(
							[StaticText().string_("To   ").font_(Font.monospace.size_(10)), s:1],
							[slt = Slider().orientation_(\horizontal).action_({|sl|
								if (cbtest.not) {
									cb.valueAction_(true);
									cbtest = true; //Only first time
								};
								to = sl.value;
								specTo.value = spec.map(to);
								nbxt.value = to;
								view.refresh;
							}), s:5],
							[nbxt = NumberBox(), s:1]
						),
						10,
						StaticText().string_("% input".format(dest.label)).align_(\center).font_(Font.monospace.size_(10)),
						//Spec views
						HLayout(
							//
							specFrom = NumberBox().action_({ |v|
								slf.valueAction_(spec.unmap(v.value))
							}),
							specTo = NumberBox().action_({ |v|
								slt.valueAction_(spec.unmap(v.value))
							}),
							StaticText().font_(Font.monospace.size_(10)).string_(spec.asSpec.units.trim)
						),
						StaticText().string_("Lag").align_(\center).font_(Font.monospace.size_(10)),
						//Spec views
						HLayout(
							//
							NumberBox().scroll_step_(0.01).action_({ |v|
								"TODO".postln;
							}),
							NumberBox().scroll_step_(0.01).action_({ |v|
								"TODO".postln;
							})
						),
						TextView().font_(Font.monospace.size_(10));
					)).onClose_({
						view.refresh;
					}).view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
						//Close window with ESC
						if (key == 16777216) {
							view.close
						}
					}).front;

					//Disable view-only number boxes
					[nbxf, nbxt].do(_.enabled_(false));

					slf.valueAction_(from);
					slt.valueAction_(to);

				};

				spec = spec.asSpec;

				//A square with graph from FROM to TO
				//TODO: use envelopeView, so we can use curve
				uview = UserView().fixedSize_(width+1).drawFunc_({
					if (enabled) {
						Pen.fillColor = Color.fromHexString("ff6699");
						Pen.moveTo(0@width);
						Pen.lineTo(Point(0, width - (width * from)));
						Pen.lineTo(Point(width, width - (width * to)));
						Pen.lineTo(width@width);
						Pen.fill;
					};// Pen.lineTo
					Pen.moveTo(0@width);
					Pen.lineTo(0@0);
					Pen.lineTo(width@0);
					Pen.stroke;

					//Activate headers on mouse over
				}).mouseWheelAction_({ |view, x, y, mod, xDelta, yDelta|
					var deltaMul = 0.01;
					if (x <= (0.5 * width)) {
						from = (from - (yDelta * deltaMul)).max(0).min(1)
					} {
						to = (to - (yDelta * deltaMul)).min(1).max(0)
					};
					view.refresh;
				}).mouseOverAction_({ |view|
					activateHeaders.(sourceHeader,destinationHeaders[i]);
					//Open routing window on click
					//2 sliders, from & to
					//Checkbox to enable routing
					//2 number boxes to set values from destination spec
				}).mouseDownAction_(openRouting);

				destWidgets.add(uview);
			}
		});

		[HLayout(
			sourceHeader = StaticText().string_(source).font_(Font.monospace.size_(10)),
			LevelIndicator().fixedWidth_(5).fixedHeight_(width)
		)] ++ destWidgets
	};
)
);

//Temporary close on escape
/*
view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
	if (key == 16777216) {
		view.close
	}
});
*/
view.acceptsMouseOver = true;
view
.front
