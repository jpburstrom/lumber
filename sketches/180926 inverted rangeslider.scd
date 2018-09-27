var min = NumericControlValue();
var max = NumericControlValue();
var sl, ch;
var inv = `false;
var valUpdater = {
	if (max.value > min.value) {
		sl.hi = max.value;
		sl.lo = min.value;
		ch.value = false;
	} {
		sl.hi = min.value;
		sl.lo = max.value;
		ch.value = true;
	};
};
Window().front.layout_(HLayout(
	sl = RangeSlider().orientation_(\horizontal),
	ch = CheckBox()
));

sl.action = { |sl|
	if (inv.value.not) {
		min.value = sl.lo;
		max.value = sl.hi;
	} {
		max.value = sl.lo;
		min.value = sl.hi;
	};

	[min, max].collect(_.value).postln;
};

ch.signal(\value).connectTo({ |ch|
	inv.value = ch.value;
	sl.changed(\value);
});


[min, max].do { |x| x.signal(\value).connectTo(valUpdater) };

min.value = 0;
max.value = 1;
((sl.lo == 0) && (sl.hi == 1) && (inv.value.not)).debug("Test 1");

min.value = 1;
max.value = 0;
//FIXME Inv isn't updated...
((sl.lo == 0) && (sl.hi == 1) && (inv.value)).debug("Test 2");

~min = min; ~max = max; ~sl = sl;
