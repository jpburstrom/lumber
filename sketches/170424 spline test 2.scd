(
z = BezierSpline.fromPoints([[0,0], [0.5,0.5], [0.5, 0.5], [1,1]], [[[0.0, 0.5]],[], [[1.0, 0.5]]]);

//GUI creation
~win = Window("Channel editor").layout_(VLayout()).front;
~uv = UserView(~win, 200@200).minSize_(200@200).background_(GUI.skin.background);
~splineGui = z.gui(~win.layout, nil, nil, nil, ~uv);
~labelContainer = View(~win).layout_(HLayout(
        [StaticText(~labelContainer).string_("Mid"), stretch:2],
        [StaticText(~labelContainer).string_("Offset"), stretch:2],
        [StaticText(~labelContainer).string_("Bend"), stretch:2],
        [StaticText(~labelContainer).string_("In"), stretch:1],
        [StaticText(~labelContainer).string_("Out"), stretch:1],
).margins_(0));
~slContainer = View(~win).layout_(HLayout().margins_(0));

~mid = 0.1;
~bend = 1;
~offset = 0.5;
~setControlPoint = { |c, fromIndex|
    //var x = (0.5 - ~mid * 0.25) * (~bend * (1 - (0.5 * ~mid)));
    var fromX = z.points[fromIndex][0];
    var toY = z.points[fromIndex + 1][1];
    var mid = z.value(fromIndex + 0.5);
    var x = ((1 - c) * mid[0]) + (c * fromX);
    var y = (c * (toY - mid[1])) + mid[1];
    z.setControlPoint(fromIndex, 0, [x, y]);
};


~setPoints = {
    var x = ~mid * 0.25;
    z.setPoint(1, 0, ~offset - x);
    z.setPoint(2, 0, ~offset + x);
    ~setControlPoint.(~bend, 0);
    ~setControlPoint.(~bend * -1, 2);
};


~midSlider = Slider().value_(~mid);
(
~midSlider.action_({ |sl|
    ~mid = sl.value;
    ~setPoints.value;
    ~splineGui.refresh;
})
);

~offsetSlider = Slider().value_(~offset);
(
~offsetSlider.action_({ |sl|
    ~offset = sl.value;
    ~setPoints.value;
    ~splineGui.refresh;
})
);

~cpSlider = Slider().value_(~bend);
(
~cpSlider.action_({ |sl|
    ~bend = (sl.value);
    ~setPoints.value;
    ~splineGui.refresh;
}
)
);

//In
~inSlider = Slider().background_(GUI.skin.background).enabled_(false);
//Out
~outSlider = Slider().background_(GUI.skin.background).enabled_(false);

~slContainer.layout.add(~midSlider, 2);
~slContainer.layout.add(~offsetSlider, 2);
~slContainer.layout.add(~cpSlider, 2);
~slContainer.layout.add(~inSlider, 1);
~slContainer.layout.add(~outSlider, 1);

)

