~weki = NetAddr("localhost", 6448);
~grt = NetAddr("localhost", 5000);
~bus = Bus.control(s, 3);

~bus
~data = List[];
(
OSCdef(\acc, { |msg|
    ~bus.setnSynchronous(msg[1..]);
    ~weki.sendMsg("/wek/inputs", *msg[1..]);
    ~grt.sendMsg("/Data", *msg[1..]);

    //~data.add(msg[1..]);
    // msg.postln;
}, '/accxyz')
)

SOMTrain

x = { Splay.ar(SinOsc.ar(In.kr(~bus, 3).range(200, 400).poll)) * 0.1 }.play;

x.free

//Reset
(
~classes = 5.collect { [[0,0,0], [[1, 0, 0], [0, 1, 0], [0, 0, 1]], 0.2] };
~data = nil.dup(5);
~win = Window.new.front.layout_(VLayout(* (5.collect { |i|
    var func, data;
    Button().states_([
        ["Start %".format(i+1), Color.gray, Color.black], ["Stop %".format(i+1), Color.gray, Color.black]
    ]).action_({ |but|
        if (but.value == 1) {
            data = List();
            func = OSCFunc({ |msg|
                data.add(msg[1..]);
            }, '/accxyz');
        } {
            func.free;
            ~classes[i] = [
                data.mean,
                Matrix.with(data).cov.asArray,
                0.2
            ].postln;

        }
    })
})));
)

~serialised = GaussClass.classesToFloatArray(~classes);
b = Buffer.loadCollection(s, ~serialised);
b.plot
x = { GaussClass.kr(In.kr(~bus, 3), b, Impulse.kr(20)).poll }.play;
