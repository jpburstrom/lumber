var done, threshold = 0.5;
var onLongPress = { "long press".postln };
var onShortPress = { "short press".postln };
Button().front.mouseDownAction_({
	done = false;
	fork {
		threshold.wait;
		if (done.not) {
			onLongPress.value;
			done = true;
		};
	};
}).mouseUpAction_({
	if (done.not) {
		onShortPress.value;
		done = true;
	}
});