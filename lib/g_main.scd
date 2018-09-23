//Main gui
//Brings in all others

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

	window.autoRememberPosition(\lumber, \mainWindow);

	window.view.background_(Color.fromHexString("ddbbcc"));

	window.view.layout.add(HLayout(
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