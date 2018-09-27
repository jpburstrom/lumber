//Main gui
//Brings in all others

var mainScriptPath = "../main.scd".resolveRelative;

Window.closeAll;


{
	var window = Window.new("Lumber").layout_(HLayout());
	var sections = List();
	var presetBtns = { |offset=0|
		View().layout_(HLayout(*{ |i|
			//TODO: preset activeIndex controls button state
			Button().states_([
				["", Color.black, Color.white],
				["", Color.white, Color.black]
			]).mouseDownAction_({ |btn, a, b, mod|
				btn.parent.children.reject(_==btn).do(_.value = 0);
				btn.value = 0;
				if (mod.isShift) {
					"Save".postln;
					~presets.save(i+offset);
				} {
					"load".postln;
					~presets.load(i+offset);
				}
			}.inEnvir)
		}.dup(5)).margins_(0)).fixedSize_(Size(90, 16))
	};

	var header = { |string|
		StaticText().string_(string)
		align_: \center
		font_: Font().bold_(false).size_(16)
	};

	var oneShotBtn = { |name, action|
		Button().states_([[name]]).action_(action).font_(Font.default.size_(12));
	};

	var calibrationPath = Library.at(\lumber, \common, \calibrationPath);

	var calibrationTask = { |method|
		{
			var win = Window("Calibration in 5 seconds").front;
			5.wait;
			win.close;
			win = Window("Be still until window is closed").front;
			MPU.perform(method, Library.at(\lumber, \server));
			1.wait;
			win.close;
		}.fork(AppClock)
	};

	window.autoRememberPosition(\lumber, \mainWindow);

	window.view.background_(Color.fromHexString("ddbbcc"));

	window.view.layout.add(VLayout(
		HLayout(
			oneShotBtn.("Play", { q.serverController.play }),
			oneShotBtn.("Stop", { q.serverController.stop }),
			nil,
			oneShotBtn.("Free All", { Library.at(\lumber, \server).freeAll }),
			oneShotBtn.("Reload script", { q.serverController.stop; mainScriptPath.load }),
			nil,
			oneShotBtn.("Save", { q.storage.save }),
			oneShotBtn.("Load", { q.storage.load }),
			oneShotBtn.("Save as…", { "TODO".postln }),
			oneShotBtn.("Load from…", { "TODO".postln }),

		),
		HLayout(
			VLayout(
				HLayout(
					header.("Macros"),
					nil,
					presetBtns.value
				).margins_([10, 0, 10, 0]),
				sections.add(Require("g_macros").background_(Color.fromHexString("ddbbcc"))).last,
				// nil
			),
			VLayout(
				HLayout(
					header.("EQ"),
					nil,
					presetBtns.value
				).margins_([0, 0, 10, 0]),
				sections.add(Require("g_eq")).last,
				nil
			).margins_([10, 0, 0, 0])
		),
		HLayout(
			oneShotBtn.("Server", { Library.at(\lumber, \server).makeWindow }),
			oneShotBtn.("Meter",
				{ Library.at(\lumber, \server).meter(2, 2) }),
			oneShotBtn.("Tree",
				{ Library.at(\lumber, \server).plotTree }),
			nil,
			oneShotBtn.("Calibrate Accel + Gyro", { calibrationTask.(\calibrateAccelGyro) }),
			oneShotBtn.("Calibrate Magnetometer", { /*calibrationTask.(\calibrateMag)*/ "FIXME".warn }),
			oneShotBtn.("Save calibration", { MPU.saveCalibration(calibrationPath,
				Library.at(\lumber, \server)) }),
			oneShotBtn.("Load calibration", { MPU.loadCalibration(calibrationPath,
				Library.at(\lumber, \server)) }),

			oneShotBtn.("Train sensors", Require("gui/sensorview", always:false).inEnvir(q));

		),
	));

	window.view.minHeight_(800);

	window.view.keyDownAction = { |view, char, modifiers, unicode, keycode, key|
		switch(key,
			//1
			49, {
				//TODO: Let section views become protos or similar
				//and add a .focus method which focuses as necessary
				//alt. use tabbedview
				sections[0].children[1].children[1].focus;
			},
			50, {
				sections[1].children[0].children[0].focus;
			}
		);
	};

	window.front;
}.value

