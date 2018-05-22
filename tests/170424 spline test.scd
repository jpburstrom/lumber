~win = Window("Single spline test", Rect(0, 0, 100, 200)).layout_(VLayout()).front;
b = BezierSpline([0.1, 0], [[0.5, 0.5]], [0.9,1]);
~bGui = b.gui();
~slider = Slider(~win.layout);
~slider.action_({|x| ~setCurve.(x.value) });
(
~setCurve = { |c|
    var fromX = b.points[0][0];
    var toY = b.points[1][1];
    //try again
    var mid = b.value(0.5);
    var x = ((1 - c) * mid[0]) + (c * fromX);
    var y = (c * (toY - mid[1])) + mid[1];
    b.setControlPoint(0, 0, [x, y]);
    ~bGui.refresh;
};
);

~setCurve.value(0)
