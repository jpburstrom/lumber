/*
MKtl(\lp, "novation-launchpad-mini");

(
MKtl(\lp).at(\pad).elements.do({|x, i|
	var col = i % 8;
	var row = i.div(8);
	x.action = { |el|
		if (el.isOn) {

		};
	};
})
)

*/