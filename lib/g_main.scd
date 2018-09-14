//Main gui
//Brings in all others

Window.closeAll;

{
	var window = Window.new("Lumber").layout_(HLayout());
	var sections = List();

var header = { |string|
    StaticText().string_(string)
    align_: \center
    font_: Font().bold_(false).size_(16)
};
	window.view.layout.add(HLayout(
		VLayout(
			header.("Macros"),
			sections.add(Require("g_macros")).last;
		),
		VLayout(
			header.("EQ"),
			sections.add(Require("g_eq")).last;
		)
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