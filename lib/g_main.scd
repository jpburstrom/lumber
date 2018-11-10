//Main gui
//Brings in all others

var mainScriptPath = "../main.scd".resolveRelative;

Library.at(\lumber, \mainWindow) !? (_.close);

{
	var window = Window.new("Lumber");
	var sections = List();
	var connections = ConnectionList();
	var playButton;
	var presetBtns = { |offset, count, keys|
		var textField;
		var view = View().layout_(HLayout(
			textField = TextField().string_("---").font_(Font.default.size_(10)).fixedWidth_(120),
			*{ |i|
				var index = i + offset;
				var label = (index+1).asString;
				var inactiveState = 0;
				var btn = Button().fixedWidth_(20).states_([
					[label, Color.black, Color.white],
					[label, Color.black, Color.gray(0.6)],
					[label, Color.white, Color.black]
				]).mouseDownAction_({ |btn, a, b, mod|
					case
					{ mod.isShift } {
						~presets.save(index, keys, textField.string);
					}
					//Clear preset
					{ mod.isAlt } {
						~presets.clearIndex(index);
					}
					{
						~presets.load(index, keys) ? "";
					};
					true
				}.inEnvir)
				.toolTip_("Click to load, Shift+click to save, Alt+click to clear");

				connections.add(
					//Watch for active preset and set button accordingly
					//TODO maybe smarter to have one connection watching all buttons
					~presets.signal(\activePreset).connectTo({ |obj, what, pindex, name|
						if (index == pindex) {
							btn.value = 2;
							textField.string = name;
						} {
							btn.value = inactiveState;
						}
					})
				);

				connections.add(
					//Watch if preset slot is filled with something,
					//and set button inactive state to 1 (gray)
					~presets.signal(\index).connectTo({ |obj, what, pindex, value|
						if (pindex == index) {
							//If value (preset dict) isn't empty, set "inactive" state to 1
							value.size.postln;
							inactiveState = value.size.min(1);
							btn.value = inactiveState;
						}
					})
				);

				btn

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

	//TODO: Refactor this, maybe all that's needed is inside Server/ServerStatusWatcher
	var serverCheck = false;
	var serverStatusTask = SkipJack({
		Library.at(\lumber, \server) !? { |server|
			//If server wasn't running, make sure we get notifications
			//(otherwise we won't get those after rebooting server)
			if (server.serverRunning and: { serverCheck.not }) {
				// FIXME Qt primitive failed (Server window)
				//{ server.notify = true }.fork(AppClock);
				//serverCheck = true;
			};
			serverStatusLed.setActive(server.serverRunning);
			if (server.unresponsive) {
				serverStatusLed.setColor(\yellow);
				//serverCheck = false;
			};
		}
	}, 1, { window.isClosed });

	var tabby = TabbedView2(window);

	//Run a command on the bela
	var sshCommand = { |cmd|
		{
			(
				Library.at(\lumber, \common, \sshCommand) + cmd.quote + "&& sleep 3"

			).runInTerminal
		}.fork(SystemClock);
	};


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
			popup.("Bela",
					"  Reboot", {
						"Reboot".postln;
						{
							sshCommand.("reboot");
							5.wait;
							checkBelaStatus.value;
						}.fork(AppClock);

					},
					"  Halt", { sshCommand.("halt") }
			),
			statusLed.makeGUI.mouseDownAction_(checkBelaStatus),
			popup.("Server",
				"  Window", { Library.at(\lumber, \server).makeWindow },
				"  Meter",
				{ Library.at(\lumber, \server).meter(2, 2) },
				"  Tree",
				{ TreeSnapshotView().autoUpdate(true, Library.at(\lumber, \server)).front },
				"  Free All", { Library.at(\lumber, \server).freeAll },
				"  Reboot", {
					sshCommand.("/usr/bin/make -C /root/Bela PROJECT=lumber runscreen");
				},
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

	connections.add(
		~serverController.signal(\isPlaying).connectTo(playButton.valueSlot)
		.transform({|o, w, v| v; [o, w, v.asInteger]});
	);


	window.onClose = ({
		connections.free;
	});

	window.front;
}.value

