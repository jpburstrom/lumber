var model = ~macros ? q.macros; //assuming we're in the same environment, otherwise fallback to global (hack)

Proto({

	//Update these after defining new synths
	//They define order of sources/destinations in macro matrix
	var sourceOrder = #[intensity, activity, orientation, expression, softpot_l, softpot_s];
	var destOrder = #[gainer, delay, freqshift, saturation, peakEqBand, freeze, lfo1, lfo2];

	var osc = ();

	var levelIndicator = { |path, spec, height|
		var width = 20, view, ind, num;
		var offset = 9;
		height = height ? ~width;
		view = View().fixedHeight_(height).fixedWidth_(width);
		ind = LevelIndicator(view, Rect((width - 5) * 0.5, 0, 5, height - offset));
		num = StaticText(view, Rect(0, height - offset + 1, width, 10)).string_(0.0).font_(Font.monospace.size_(7)).align_(\center).fixedSize_(Size(width, 8));
		path = path.asSymbol;
		spec = spec.asSpec;
		ind.warningColor_(Color.green);
		ind.criticalColor_(Color.red);
		ind.meterColor_(Color.red);
		ind.warning = 0.1;
		ind.critical = 0.9;
		osc[path] = OSCFunc({ |args|
			{
				var val = args[3];
				ind.value = val.linlin(spec.minval, spec.maxval, 0.1, 0.9, \none);
				num.string = if (val.isNaN) { "0.0" } { val.asStringPrec(2) };
			}.defer;
		}, path);
		view
	};

	~model = model;
	~width = 40;
	~sources = Library.at(\lumber, \common, \macroSources).keys.asArray.sort { |x, y|
		(sourceOrder.indexOf(x) ? inf) < (sourceOrder.indexOf(y) ? inf)
	};
	~destinations = Library.at(\lumber, \common, \macroDestinations);
	~destinationKeys = ~destinations.keys.asArray.sort { |x, y|
		(destOrder.indexOf(x) ? inf) < (destOrder.indexOf(y) ? inf)
	};
	//StaticTexts
	~makeDestString = { |dest, input|
		"%:%".format(~destinations[dest].label, input);
	};

	~font = Font.monospace.size_(10);

	~makeSourceHeader = { |label, height|
		var font = ~font;
		UserView().minHeight_(height).drawFunc_{ |v|
			var extent = v.bounds.extent;
			Pen.font = font;
			Pen.translate((extent.x * 0.5) - 6, extent.y);
			Pen.rotate(-0.5pi);
			Pen.string(label);
			Pen.stroke;
		};
	};

	~staticText = { |str|
		StaticText().string_(str).font_(~font)
	};


	~makeWindow = {

		var cellFactory = Require("gui/envelopeCell");
		var connections = ConnectionList();

		~destinationHeaders = {
			~destinationKeys.collect({ |k|
			// k.postln;
				~destinations[k].inputs.collect { |input|
					var txt = ~makeDestString.(k, input);
					HLayout(
						levelIndicator.("/meter/%/%".format(k, input), ~destinations[k].specs[input]),
						~staticText.(txt).maxWidth_(100).align_(\center);
					).spacing_(0);
				}
			}).flatten;
		};

		~view = View().layout_(GridLayout.columns(
			//Top Headers
			//Sources are rows
			* (~sources.collect { |source, sourceIndex|
				var conf = Library.at(\lumber, \common, \macroSources)[source];
				var sourceHeader;
				var destWidgets = List();
				//First column: source header

				//One cell for every destination input
				//~destinations are synthdefs with metadata
				//dest.specs has inputs
				//We just grab all of them, but maybe it would be better to use lumber.inputs or similar

				~destinationKeys.do({ |destKey|

					var dest = ~destinations[destKey];

					dest.inputs.do { |inputKey|
						destWidgets.add([cellFactory.(
							model: model,
							source: source,
							destKey: destKey,
							dest: dest,
							inputKey: inputKey
						), a: \center]);
					}
				});


				[HLayout(
					value {
						var label = conf.label ? source;
						sourceHeader = ~makeSourceHeader.(label, 70);
					},
					value {
						[levelIndicator.value("/meter/%".format(source), conf[\outputSpec], 70), a: \bottom];
					}
				)] ++ destWidgets ++ [nil]
			}).add(
				[nil] ++ ~destinationHeaders.value;
			)
		));


		~view.onClose = {
			osc.do { |x| x.free };
			connections.free;
		}.inEnvir;

	};

})
