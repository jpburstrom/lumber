//TODO: use curve
var model = ~macros ? q.macros; //assuming we're in the same environment, otherwise fallback to global (hack)

Proto({

	//Update these after defining new synths
	//They define order of sources/destinations in macro matrix
	var sourceOrder = #[intensity, activity, orientation, expression, softpot_l, softpot_s];
	var destOrder = #[boogie, lfo1, destTest]; //TODO

	~model = model;
	~width = 50;
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

	~staticText = { |str|
		StaticText().string_(str).font_(Font.monospace.size_(10))
	};

	~makeWindow = {

		var cellFactory = Require("gui/envelopeCell");
		var connections = ConnectionList();

		~destinationHeaders = ~destinationKeys.collect({ |k|
			// k.postln;
			~destinations[k].inputs.collect { |input|
				var txt = ~makeDestString.(k, input);
				StaticText().maxWidth_(100).fixedHeight_(75).string_(txt).font_(Font.monospace.size_(10))
			}
		}).flatten;


		~view = View().layout_(GridLayout.columns(
			//Top Headers
			//Sources are rows
			* (~sources.collect { |source, sourceIndex|
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
						//TODO: These values should be collected from CVs somewhere

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
						var label = Library.at(\lumber, \common, \macroSources)[source].label ? source;
						sourceHeader = StaticText().fixedWidth_(75).align_(\center)
						.string_(label).toolTip_(source).font_(Font.monospace.size_(10))
					},
					LevelIndicator().fixedWidth_(5).fixedHeight_(~width)
				)] ++ destWidgets ++ [nil]
			}).add(
				[nil] ++ ~destinationHeaders.collect { |h|
					HLayout(

						LevelIndicator().fixedHeight_(~width).fixedWidth_(5),
						h.align_(\center),
					)
				}
			)
		));

		~view.onClose = {
			connections.free;
		}.inEnvir;

	};

});
