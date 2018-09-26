//Main gui
//Brings in all others

var mainScriptPath = "../main.scd".resolveRelative;

Window.closeAll;


{
	var window = Window.new("Lumber").layout_(HLayout());
	var sections = List();
	var presetBtns = { View().layout_(HLayout(*{Button()}.dup(5)).margins_(0)).fixedSize_(Size(90, 16)) };

	var header = { |string|
		StaticText().string_(string)
		align_: \center
		font_: Font().bold_(false).size_(16)
	};

	var oneShotBtn = { |name, action|
		Button().states_([[name]]).action_(action).font_(Font.default.size_(12));
	};

	var serverStatus, serverView = View(nil, Rect(0, 0, 300, 100)).fixedSize_(Size(300, 100));
	serverView.addFlowLayout;
	serverView = SCViewHolder().view_(serverView);
	//FIXME: Server.default
	Server.default.makeGui(serverView);


	window.autoRememberPosition(\lumber, \mainWindow);

	window.view.background_(Color.fromHexString("ddbbcc"));

	window.view.layout.add(VLayout(
		HLayout(
			oneShotBtn.("Play", { q.server.play }),
			oneShotBtn.("Stop", { q.server.stop }),
			nil,
			oneShotBtn.("Cmd+Period", { CmdPeriod.run }),
			oneShotBtn.("Reload", { q.server.stop; mainScriptPath.load }),
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
			oneShotBtn.("Server", { Server.default.makeWindow }),
			oneShotBtn.("Meter",
				{ Server.default.meter(2, 2) }),
			nil
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

