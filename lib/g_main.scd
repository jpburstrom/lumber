//Main gui
//Brings in all others

var mainScriptPath = "../main.scd".resolveRelative;

Library.at(\lumber, \mainWindow) !? (_.close);

{
	var window = Window.new("Lumber");
	var sections = List();
	var connections;
	var playButton;
	var presetBtns = { |offset, count, keys|
		var textField;
		var view = View().layout_(HLayout(
			textField = TextField().string_("---").font_(Font.default.size_(10)).fixedWidth_(120),
			*{ |i|
				var curOffset = offset;
				var label = (i+offset+1).asString;
				Button().fixedWidth_(20).states_([
					[label, Color.black, Color.white],
					[label, Color.white, Color.black]
				]).mouseDownAction_({ |btn, a, b, mod|
					btn.parent.children(Button).reject(_==btn).do(_.value = 0);
					btn.value = 0;
					if (mod.isShift) {
						~presets.save(i+curOffset, keys, textField.string);
					} {
						textField.string = ~presets.load(i+curOffset, keys) ? "";

					}
				}.inEnvir)
				.toolTip_("Click to load, Shift+click to save");

		}.dup(count)).margins_(0).spacing_(0)).fixedSize_(Size((count * 20) + 120, 16));
		view
	};


	var header = { |string|
		StaticText().string_(string)
		align_: \center
		font_: Font().bold_(false).size_(16)
	};

	var oneShotBtn = { |name, action|
		Button().states_([[name, Color(),window.background]]).action_(action).font_(Font.default.size_(12))
		;
	};

	//popup.("header", "action1", {}, "action2", {})
	var popup = { |...args|
		var labels, actions, header;
		header = args[0];
		args = args[1..].clump(2).flop;
		labels = args[0];
		actions = args[1];
		PopUpMenu().items_([header] ++ labels).action_({ |btn|
			actions[btn.value-1].value;
			btn.value = 0;
		}).background_(window.background).maxWidth_(80)
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

	var statusLed = Require("gui/statusLed");
	var serverStatusLed = Require("gui/statusLed");
	var checkBelaStatus = {
		statusLed.setActive(false);
		fork {
			//Test ping for 30 seconds
			"ping -t 45 -o %".format(Library.at(\lumber, \common, \belaAddress)).unixCmd({ |code|
				statusLed.setActive((code == 0));

			}, false);
		}

	};

	var serverStatusTask = SkipJack({
		Library.at(\lumber, \server) !? { |server|
			serverStatusLed.setActive(server.hasBooted)
		}
	}, 1, { window.isClosed });

	var tabby = TabbedView2(window);

	window.view.minHeight_(800);

	checkBelaStatus.value;

	window.autoRememberPosition(\lumber, \mainWindow);

	window.view.background_(Color.fromHexString("ddbbcc"));
	tabby.backgrounds = [Color.fromHexString("ddbbcc")];

	window.layout_(VLayout(
		HLayout(
			playButton = Button().states_([["Play", nil, window.background], ["Stop", nil, window.background]]).action_({ |b|
				if (b.value == 1) {
					~serverController.play;
				} {
					~serverController.stop;
				}
			}.inEnvir).font_(Font.default.size_(12)),
			value {
				var sshCommand = Library.at(\lumber, \common, \sshCommand);
				popup.("Bela",
					"  Reboot", {
						"Reboot".postln;
						{
							(sshCommand + "reboot").runInTerminal;
							5.wait;
							checkBelaStatus.value;
						}.fork(AppClock);

					},
					"  Halt", { (sshCommand + "halt").runInTerminal }
			)},
			statusLed.makeGUI.mouseDownAction_(checkBelaStatus),
			popup.("Server",
				"  Window", { Library.at(\lumber, \server).makeWindow },
				"  Meter",
				{ Library.at(\lumber, \server).meter(2, 2) },
				"  Tree",
				{ TreeSnapshotView().autoUpdate(true, Library.at(\lumber, \server)).front },
				"  Free All", { Library.at(\lumber, \server).freeAll },
				"  Reboot", { "TODO".postln },
			),
			serverStatusLed.makeGUI,
			nil,

			popup.("Sensors",
				"  Train sensors", Require("gui/sensorview", always:false).inEnvir(q),
				"  Calibrate Accel + Gyro", { calibrationTask.(\calibrateAccelGyro) },
				"  Calibrate Magnetometer", { calibrationTask.(\calibrateMag); "FIXME".warn },
				"  Save calibration", { MPU.saveCalibration(calibrationPath,
					Library.at(\lumber, \server)) },
				"  Load calibration", { MPU.loadCalibration(calibrationPath,
					Library.at(\lumber, \server)) }
			),
			popup.("Storage",
				"  Save", { q.storage.save },
				"  Load", { q.storage.load },
				"  Save as…", {
					Dialog.savePanel({ |filename|
						~storage.save(filename);
					}.inEnvir, path: ~storage.storagePath)
				}.inEnvir,
				"  Load from…", {
					Dialog.openPanel({|filename|
						~storage.load(filename);
					}.inEnvir, path: ~storage.storagePath)
				}.inEnvir
			),
			oneShotBtn.("Reload", { q.serverController.stop; mainScriptPath.load })

		),
		tabby.view
	));

	tabby.add("Macros", scroll:true);
	tabby.add("EQ", scroll:false);
	tabby.tabViews[0].layout_(VLayout(
		HLayout(nil, presetBtns.value(0, 6, \macros)),
		Require("g_macros").makeWindow,
		nil
	));

	tabby.tabViews[1].layout_(VLayout(
		HLayout(nil, presetBtns.value(6, 4, \eq)),
		Require("g_eq")
	));


	{ tabby.refresh }.defer(0.2);

	window.acceptsMouseOver_(true);

	Library.put(\lumber, \mainWindow, window);

	connections = ConnectionList.make {
		~serverController.debug("SC").signal(\isPlaying).connectTo(playButton.valueSlot)
		.transform({|o, w, v| v; [o, w, v.asInteger]});
	};


	window.onClose = ({
		connections.free;
	});

	window.front;
}.value

