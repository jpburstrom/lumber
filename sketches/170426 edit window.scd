(
var scroll = ScrollView(bounds:Rect(0,0,300,300).center_(Window.availableBounds.center));
var canvas = View();
var layout;
var i = 0;

var sources = ["Accel X", "Accel Y", "Accel Z"];
var dests = ["Synth param"];

var makeEntry = {
    var view = View().background_(Color.rand).layout_(
        GridLayout.columns(
            [StaticText().string_("Sources"), PopUpMenu().items_(sources)],
            [StaticText().string_("Edit"),
                Button().states_([["Edit mapping"]]).action_({Window.new.front})],
            [StaticText().string_("Destinations"), PopUpMenu().items_(dests)]

        )
    );
    i = i + 1;
    view;
};

layout = VLayout();
layout.add ( View().background_(Color.black).layout_(
    HLayout(
        Button().states_([["Add"]]).action_({ layout.insert(makeEntry.(), i) }),
        nil // stretch remaining empty space
    )
));

canvas.layout = layout;
1.do { canvas.layout.add( makeEntry.() ) };
canvas.layout.add(nil); // stretch remaining empty space

scroll.canvas = canvas;
scroll.front;
)