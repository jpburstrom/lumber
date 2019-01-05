SoftStep.connect
(
var prev;
f.do(_.free);
f = 5.collect { |i|
	var led = SoftStepLed(i);
	[
		SSLongTrigFunc({ |val|
			var name =
			q.presets.save(i, \macros);
		}, i, true),
		SSTrigFunc({ |val|
			if (val == 0) {
				prev !? { prev.set(0) };
				led.set(1);
				prev = led;
				SoftStep.shortText(q.presets.load(i) ? "");
			}
		}, i)
	]
};
)

y.free; y = SSRawFunc({ |args| args.postln }, 6)

SoftStep.shortText(nil ? "")

q.presets.activeIndex
q.presets.load(3)