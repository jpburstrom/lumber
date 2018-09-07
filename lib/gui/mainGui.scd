//Main gui
//Brings in all others

var window = Window.new("Lumber").layout_(HLayout());
var header = { |string|
    StaticText().string_(string)
    align_: \center
    font_: Font().bold_(true).size_(16)
};

window.view.layout.add(VLayout(
    header.("Macros"),
    Require("macroGui")
	header.("EQ"),
    Require("eqGui")
));

window.front;


//q.storage.load
