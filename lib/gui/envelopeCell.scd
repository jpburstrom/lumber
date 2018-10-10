var editorFactory = Require("envelopeEditor"); //A proto.
{ |model, source, destKey, dest, inputKey|

	var connections = ConnectionList();
	var container, eview;

	//FIXME
	//Keep a copy of current input params
	var cellModel = model.params[source][destKey][inputKey];
	var envEditor = editorFactory.value;

	var envFromModel = { |m|
		Env(m.levels.input, m.times.value, m.curves.value);
	};

	//Enable on first window open, if not already
	var firstTest = cellModel.active.value == \off;

	envEditor.model = cellModel;
	envEditor.spec = dest[\specs][inputKey].asSpec;

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
		eview.visible = (cv.value == \on);
	});

	container.onClose = {
		connections.free;
	};

	container

}
