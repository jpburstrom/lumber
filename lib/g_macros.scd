//TODO: use curve
var model = ~macros ? q.macros; //assuming we're in the same environment, otherwise fallback to global (hack)

Proto({

	~model = model;
	~width = 50;
	~sources = Library.at(\lumber, \common, \macroSources);
	~destinations = Library.at(\lumber, \common, \macroDestinations);
	~destinationKeys = ~destinations.keys.asArray.sort;
	//StaticTexts
	~makeDestString = { |dest, input|
		"%:%".format(~destinations[dest].label, input);
	};

	~staticText = { |str|
		StaticText().string_(str).font_(Font.monospace.size_(10))
	};

	~makeWindow = {

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
				var counter = -1;
				//First column: source header

				//One cell for every destination input
				//~destinations are synthdefs with metadata
				//dest.specs has inputs
				//We just grab all of them, but maybe it would be better to use lumber.inputs or similar
				~destinations.keysValuesDo({ |destKey, dest|
					dest.inputs.do { |inputKey|
						//TODO: These values should be collected from CVs somewhere

						var container, eview;
						var i = counter = (counter + 1);

						//FIXME
						//Keep a copy of current input params
						var cellModel = model.params[source][destKey][inputKey];
						var envEditor = Require("gui/envelopeEditor");

						var envFromModel = { |m|
							Env(m.levels.value, m.times.value, m.curves.value);
						};

						//Enable on first window open, if not already
						var firstTest = cellModel.active.value == \off;
						envEditor.model = cellModel;

						container = View().fixedSize_(~width).background_(Color.gray(0.9))
						.mouseDownAction_({ |view, x, y, mod|
							if (mod.isShift) {
								cellModel.active.toggle;
							} {
								var connectionString = "% ▷ %".format(source, ~makeDestString.(destKey, inputKey));
								var win = envEditor.makeWindow;
								win.name = connectionString;
								win.bounds_(Window.flipY(win.bounds.center_(view.mapToGlobal(x@y))));
								//XXX test
								if (firstTest) {
									cellModel.active.value = \on;
									firstTest = false;
								}
							}
						}.inEnvir);

						destWidgets.add([container, a: \center]);

						eview = EnvelopeView(container, container.bounds.insetBy(-11))
						.setEnv(envFromModel.(cellModel))
						.gridOn_(false).drawRects_(false)
						.editable_(false)
						.mouseDownAction_(false)
						.visible_(cellModel.active.value == \on);
						//A square with graph from FROM to TO



						connections.add(envEditor.signal(\value).connectTo { |editor, what, key|
							key ?? { key = #[levels, times, curves] };
							key = key.asArray;
							key.do { |k|
								cellModel[k].value = editor[k];
							};

						});

						#[levels, times, curves].do { |k|
							connections.add(cellModel[k].signal(\value).connectTo({ |cv|
								envEditor[k].putEach(Array.series(cv.value.size), cv.value);
								eview.setEnv(envFromModel.(cellModel));
							}).collapse(0.1));
						};
						connections.add(cellModel[\active].signal(\value).connectTo { |cv|
							eview.visible = cv.value == \on;
						})

					}
				});


				[HLayout(
					sourceHeader = StaticText().fixedWidth_(75).align_(\center)
					.string_(source).toolTip_(source).font_(Font.monospace.size_(10)),
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
