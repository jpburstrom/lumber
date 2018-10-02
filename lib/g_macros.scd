//TODO: use curve
var model = ~macros ? q.macros; //assuming we're in the same environment, otherwise fallback to global (hack)

Proto({

	~model = model;
	~width = 25;
	~sources = Library.at(\lumber, \common, \macroSources);
	~destinations = Library.at(\lumber, \common, \macroDestinations);
	~destinationKeys = ~destinations.keys.asArray.sort;
	//StaticTexts
	~makeDestString = { |dest, input|
		"%:%".format(~destinations[dest].label, input);
	};

	//closure
	~activateHeaders = {
		var activeHeaders = nil ! 2;
	//highlight headers for currently mouseover'd cell
		{ |x, y|
			activeHeaders.do { |h| h !? { h.stringColor_(Color.black) } };
			activeHeaders = [x, y];
			activeHeaders.do(_.stringColor_(Color.red));
		};
	}.value;


	~openRoutingWindow = { |view, x, y, cellModel, connectionString|

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
		cbtest = cellModel[\enabled].value,
		//created connections
		rConnections;


		var win = Window(bounds: Window.flipY(Rect(0, 0, 200, 50).center_(view.mapToGlobal(x@y))))
			.layout_(VLayout(
			HLayout(
				cb = CheckBox(),
				StaticText().string_(connectionString).font_(Font.monospace.size_(10)).minWidth_(200)
			),
			HLayout(
				[StaticText().string_("From").font_(Font.monospace.size_(10)), s:1],
				[slf = Slider().orientation_(\horizontal)/*.action_({|sl|
					if (cbtest.not) {
						cb.valueAction_(true);
						cbtest = true; //Only first time
					};
					from = sl.value;
					nbxf.value = from;
					specFrom.value = spec.map(from);
					view.refresh;
				})*/, s:5],
				[nbxf = NumberBox(), s:1]
			),
			HLayout(
				[StaticText().string_("To   ").font_(Font.monospace.size_(10)), s:1],
				[slt = Slider().orientation_(\horizontal)/*.action_({|sl|
					if (cbtest.not) {
						cb.valueAction_(true);
						cbtest = true; //Only first time
					};
					to = sl.value;
					specTo.value = spec.map(to);
					nbxt.value = to;
					view.refresh;
				})*/, s:5],
				[nbxt = NumberBox(), s:1]
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
			rConnections.free;
			view.refresh;
		}).view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
			//Close window with ESC
			if (key == 16777216) {
				view.close
			}
		}).front;

		//Disable view-only number boxes
		[nbxf, nbxt].do(_.enabled_(false));

		//slf.valueAction_(from);
		//slt.valueAction_(to);

		rConnections = ConnectionList.make {
			slf.signal(\value).connectTo(cellModel[\from].inputSlot);
			slt.signal(\value).connectTo(cellModel[\to].inputSlot);
			cellModel[\from].signal(\value).connectTo(slf.valueSlot);
			cellModel[\to].signal(\value).connectTo(slt.valueSlot);
			//Enabled checkbox
			cb.signal(\value)
			.connectTo(cellModel[\active].inputSlot)
			.transform({|o, w, v| v.debug("cb"); [o, w, v.asInteger]});
			cellModel[\active].signal(\value)
			.connectTo(cb.valueSlot)
			.transform({|o, w, v| [o, w, v == \on]});


		};

		win
	};

	~makeWindow = {

		var connections = ConnectionList();

		~destinationHeaders = ~destinationKeys.collect({ |k|
			// k.postln;
			~destinations[k].inputs.collect { |input|
				var txt = ~makeDestString.(k, input);
				StaticText().fixedWidth_(~width).string_(txt[..2]).font_(Font.monospace.size_(10)).toolTip_(txt)
			}
		}).flatten;


		~view = View().layout_(GridLayout.rows(
			//Top Headers
			[nil] ++ ~destinationHeaders.collect { |h|
				HLayout(
					h.align_(\center),
					LevelIndicator().fixedHeight_(~width).fixedWidth_(5)
				)
			},
			//Sources are rows
			* ~sources.collect { |source, i|
				var sourceHeader;
				var destWidgets = List();
				var counter = -1;
				//First column: source header

				//One cell for every destination input
				//~destinations are synthdefs with metadata
				//dest.specs has inputs
				//We just grab all of them, but maybe it would be better to use lumber.inputs or similar
				~destinations.keysValuesDo({ |destKey, dest|
					dest.inputs.do { |inputKey|
						//TODO: These values should be collected from CVs somewhere

						var spec = dest.specs[inputKey];
						var uview;
						var i = counter = (counter + 1);

						//FIXME
						//Keep a copy of current input params
						var cellModel = model.params[source][destKey][inputKey];

						spec = spec.asSpec;

						//A square with graph from FROM to TO
						//TODO: use envelopeView, so we can use curve
						uview = UserView().fixedSize_(~width+1).drawFunc_({ |view|
							if (cellModel.active.value == \on) {
								view.background_(Color.white);
								Pen.fillColor = Color.fromHexString("ff6699");
								Pen.moveTo(0@~width);
								Pen.lineTo(Point(0, ~width - (~width * cellModel.from.value)));
								Pen.lineTo(Point(~width, ~width - (~width * cellModel.to.value)));
								Pen.lineTo(~width@~width);
								Pen.fill;
							} {
								view.background_(QPalette.light.color(\window));
							};// Pen.lineTo
							Pen.moveTo(0@~width);
							Pen.lineTo(0@0);
							Pen.lineTo(~width@0);
							Pen.stroke;

							//Activate headers on mouse over
						}.inEnvir).mouseWheelAction_({ |view, x, y, mod, xDelta, yDelta|
							if (cellModel.active.value == \on) {

								var deltaMul = 0.01;
								if (x <= (0.5 * ~width)) {
									cellModel.from.value = (cellModel.from.value - (yDelta * deltaMul)).max(0).min(1)
								} {
									cellModel.to.value = (cellModel.to.value - (yDelta * deltaMul)).min(1).max(0)
								};

								view.refresh;
							};
						}.inEnvir).mouseOverAction_({ |view|
							~activateHeaders.(sourceHeader, ~destinationHeaders[i]);
							//Open routing window on click
							//2 sliders, from & to
							//Checkbox to enable routing
							//2 number boxes to set values from destination spec
						}.inEnvir).mouseDownAction_({ |view, x, y, mod|
							if (mod.isCmd) {
								cellModel.active.toggle.postln;
								if (cellModel.from.value == cellModel.to.value) {
									cellModel.to.value = 1.0;
									cellModel.from.value = 0.0;
								}
							} {
								var connectionString = "% ▷ %".format(source, ~makeDestString.(destKey, inputKey));
								~openRoutingWindow.value(view, x, y, cellModel, connectionString)
							}
						}.inEnvir);

						destWidgets.add(uview);

						#[from, to, active].do { |x|
							connections.add(cellModel[x].signal(\value).connectTo { uview.refresh })
						};

					}
				});


				[HLayout(
					sourceHeader = StaticText()
					.string_(source).font_(Font.monospace.size_(10)).maxWidth_(200),
					LevelIndicator().fixedWidth_(5).fixedHeight_(~width)
				)] ++ destWidgets
			};
		)
		);
		~view.acceptsMouseOver = true;

		~view.onClose = {
			connections.free;
		}.inEnvir;

	};

});
