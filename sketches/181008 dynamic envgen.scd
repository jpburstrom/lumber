(
y = {

	var in = LFSaw.kr(20).unipolar;

	var levels = [0, 0.2, 0.8, 1];
	var times = \times.kr([0, 0.3, 0.6, 1.0], 1);
	var curves = [-4, 0, 4];

	var y = levels;
	var x = times ;

	1.do {

		3.collect({ |i|
			in.lincurve(x[i], x[i+1], y[i], y[i+1], curves[i], \none).clip(y[i], y[i+1]) - y[i]
		}).sum;

		// IEnvGen.kr(Env(levels, times, curves), in);
	}


}.asSynthDef.dumpUGens
// Env(y, x.differentiate[1..], curves).plot
)

y.set(\times, [0.1, 0.1, 0.8])

LinLin