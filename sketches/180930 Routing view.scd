//TODO: use curve
var width = 25;
var sources = #[
	activity, intensity, orientation,
	softpot_l, softpot_s,
	expression, lfo1, lfo2
].dup(2).flatten;
var destinations = #[delay, detune, phase, eq, saturation, lfo1, lfo2].dup(2).flatten;
var view = View().layout_(GridLayout.rows(
	([nil] ++ destinations).collect { |t| t !? {
		StaticText().fixedWidth_(width).string_(t).font_(Font.monospace.size_(10))
	} },
	*sources.collect { |source, i|
		[StaticText().string_(source).font_(Font.monospace.size_(10))] ++
		destinations.collect { |dest, i|
			var from = 0;
			var to = 0;
			var enabled = false;
			//TODO: use envelopeView, so we can use curve
			var uview = UserView().fixedSize_(width+1).drawFunc_({
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


			}).mouseDownAction_({ |view, x, y|
				var nbxf, nbxt, cb,
				slt, slf,
				spec = \freq.asSpec,
				specFrom, specTo,
				cbtest = enabled,
				win = Window(bounds: Window.flipY(Rect(0, 0, 200, 50).center_(view.mapToGlobal(x@y)))).layout_(VLayout(
					HLayout(
						cb = CheckBox().value_(enabled).action_{ |cb|
							enabled = cb.value
						},
						StaticText().string_("% ▷ %".format(source, dest)).font_(Font.monospace.size_(10)),
						nil
					),
					HLayout(
						[StaticText().string_("From").font_(Font.monospace.size_(10)), s:1],
						[slf = Slider().orientation_(\horizontal).value_(from).action_({|sl|
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
						[slt = Slider().orientation_(\horizontal).value_(to).action_({|sl|
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
					StaticText().string_("% input".format(dest)).align_(\center).font_(Font.monospace.size_(10)),
					//Spec views
					HLayout(
						//
						specFrom = NumberBox().action_({ |v|
							slf.valueAction_(spec.unmap(v.value))
						}),
						specTo = NumberBox().action_({ |v|
							slt.valueAction_(spec.unmap(v.value))
						})
					)
				)).onClose_({
					view.refresh;
				}).view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
					if (key == 16777216) {
						view.close
					}
				}).front;

				[nbxf, nbxt].do(_.enabled_(false));

			});

			uview
		}
	};
));

//Temporary close on escape
/*
view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
	if (key == 16777216) {
		view.close
	}
});
*/
view.front

