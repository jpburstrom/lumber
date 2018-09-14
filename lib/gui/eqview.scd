var font = Font(Font.defaultSansFace, 10);
var view = UserView().minHeight_(200).minWidth_(400);
//Selected band
var selected = nil;

view.frameRate = 5;
view.animate = true;

view.drawFunc = { |vw|
	var freqs, svals, values, bounds, zeroline;
	var min = 40, max = 320, range = 24;
	var vlines = [40,80,160, 240];
	var vLabels = vlines.collect("%Hz".format(_));
	var dimvlines = Array.series(24, 32).midicps;
	var hlines = [-18,-12,-6,6,12,18];
	var pt, strOffset = 11;
	//FIXME
	var sr = s.sampleRate ? 44100;
	//FIXME
	var frdb;

	bounds = vw.bounds.moveTo(0,0);

	freqs = ({|i| i } ! (bounds.width+1));
	freqs = freqs.linexp(0, bounds.width, min, max);
	frdb = List[[60, 4]];
	values = List[BLowCut.magResponse(freqs, sr, *frdb[0])];
	// values = List[BPeakEQ.magResponse(freqs, sr, *frdb[0])];

	// Array.series(4, 36).do { |midi|
	//FIXME: stupid
	q.eq.getParams.keysValuesDo { |midi, db|
		var vals = [midi.midicps, 0.0625, db];
		frdb.add(vals);
		values.add(BPeakEQ.magResponse(freqs, sr, *vals))
	};

	frdb.add([240, 1, -32]);
	values.add(BHiShelf.magResponse(freqs, sr, *frdb.last));
	values = values.ampdb.max(-200).min(200);

	zeroline = 0.linlin(range.neg,range, bounds.height, 0, \none);

	svals = values.sum.linlin(range.neg,range, bounds.height, 0, \none);
	values = values.linlin(range.neg, range, bounds.height, 0, \none);

	vlines = vlines.explin(min, max, 0, bounds.width);
	dimvlines = dimvlines.explin(min, max, 0, bounds.width);


	pt = frdb.collect { |array|
		(array[0].explin(min, max, 0, bounds.width))
		@
		(array[1].linlin(range.neg,range,bounds.height,0,\none));
	};

	Pen.color_(Color.white.alpha_(0.25));
	Pen.roundedRect(bounds, [6,6,0,0]).fill;

	Pen.color = Color.gray(0.2).alpha_(0.5);
	//Pen.strokeRect(bounds.insetBy(-1,-1));

	//Pen.addRect(bounds).clip;
	Pen.roundedRect(bounds.insetBy(0,0), [6,6,0,0]).clip;

	Pen.color = Color.gray(0.2).alpha_(0.125);

	hlines.do({ |hline,i|
		hline = hline.linlin(range.neg,range, bounds.height, 0, \none);
		Pen.line(0@hline, bounds.width@hline)
	});
	dimvlines.do({ |vline,i|
		Pen.line(vline@0, vline@bounds.height);
	});
	Pen.stroke;

	Pen.color = Color.gray(0.2).alpha_(0.5);
	vlines.do({ |vline,i|
		Pen.line(vline@0, vline@bounds.height);
	});
	Pen.line(0@zeroline, bounds.width@zeroline).stroke;

	/*
	Pen.color = Color.white.alpha_(0.5);
	Pen.fillRect(Rect(33, 0, 206, 14));
	*/

	Pen.font = font;

	Pen.color = Color.gray(0.2).alpha_(0.5);
	hlines.do({ |hline|
		Pen.stringAtPoint(hline.asString ++ "dB",
			3@(hline.linlin(range.neg,range, bounds.height, 0, \none)
				- strOffset));
	});
	vlines.do({ |vline,i|
		Pen.stringAtPoint(vLabels[i],
			(vline+2)@(bounds.height - (strOffset + 1)));
	});
	values.do({ |svals,i|
		var color;

		color = Color.hsv(
			i.linlin(0,values.size,0,1),
			0.75, 0.5).alpha_(if (selected == i) { 0.75 } { 0.25 });
		Pen.color = color;
		Pen.moveTo(0@(svals[0]));
		svals[1..].do({ |val, i|
			Pen.lineTo((i+1)@val);
		});
		Pen.lineTo(bounds.width@(bounds.height/2));
		Pen.lineTo(0@(bounds.height/2));
		Pen.lineTo(0@(svals[0]));
		Pen.fill;

		Pen.addArc(pt[i], 5, 0, 2pi);

		Pen.color = color.alpha_(0.75);
		Pen.stroke;

	});

	Pen.color = Color.blue(0.5);
	Pen.moveTo(0@(svals[0]));
	svals[1..].do({ |val, i|
		Pen.lineTo((i + 1)@val);
	});
	Pen.stroke;

	Pen.extrudedRect(bounds, [6,6,0,0], 1, inverse: true);

};
view.bounds.postln;
view