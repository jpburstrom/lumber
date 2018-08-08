(
//INIT
~grt = NetAddr("localhost", 5000);
~bela = Server.remote(\bela, NetAddr("bela.local", 57110));
~bela.notify = true;
Server.default = ~bela;
CmdPeriod.freeRemote_(true);
)

(
~accelOsc.free;
~accelOsc = {
    var acc = MPU.accelKr;
    SendReply.kr(Impulse.kr(10), '/acc', acc);
}.play(~bela);

OSCdef(\acc, { |args|
    args[3..];
    ~grt.sendMsg('/Data', *args[3..]);
}, '/acc');
)

OSCFunc.trace(true, true)
OSCFunc.trace(false, true)

(
// Server.killAll;
s.initTree;
SynthDef(\grtTest, { |bus=0, amp=0.1|
    var snd, g, in;//= MPU.accelKr;

    var num = 1;
    // in = Latch.kr(in, Impulse.kr(\trigFreq.kr(10)));

    // Timer.kr(Changed.kr(in[0])).poll;

    // in = { LFNoise2.kr(1) } ! 3;

    if (s.name == \localhost) {
        in = { LFNoise1.kr } ! 3;
    } {
        in = MPU.accelKr;
    };
    in = { LFNoise1.kr(0.1).range(0.0, 0.5) } ! 3;
    in = Latch.kr(in, Impulse.ar(100));
    g = GestureRT.kr(in).poll;
    // g.poll;
    snd = Mix.fill(num, {SinOsc.ar(g.linexp(0, 3, 220, 440))}) * num.reciprocal ;

    Out.ar(0,  snd * amp * Env.asr.ar(2, \gate.kr(1)))
}).add;
// ~bus = Bus.control(s, 3);
)
(
f = fork {
    var synths = 15.collect { |i|
        var syn = Synth(\grtTest, [\amp, 10.reciprocal * 0.1]);
        //syn.onFree({"freed".postln});

        { 10.wait; syn.release }.fork;
        syn
        // 1.wait;
    };
    1.wait;
    synths.do { |syn|
        syn.postln;
        GestureRT.loadPipeline("/root/test-pipeline.grt", syn);
        // 0.1.wait;
    }
}
)
f.stop

(
var num = 1;
x = num.collect { Synth(\grtTest, [\amp, 10.reciprocal * 0.1]); }
)
x.do { |syn| GestureRT.loadPipeline("/root/test-pipeline.grt", syn) }
x.do { |syn| GestureRT.loadPipeline("/root/test-pipeline-knn.grt", syn) }
x.do { |syn| GestureRT.loadPipeline("/root/test-pipeline-mindist.grt", syn) }
x.free
Synth(\grtTest, [\amp, 0.2 * 0.1])


SynthDef(\dummy, { Out.ar(0, DC.ar) }).add
x = Synth(\dummy)
GestureRT.loadPipeline("/root/test-pipeline.grt", x);
s.sendMsg(\u_cmd, 1007, 5, "loadPipeline", "asd")

x.set(\trigFreq, 1000)

GestureRT.loadPipeline("/Users/johannes/kod/supercollider/grtplugin/data/test-pipeline.grt", x)



OSCdef(\acc2, { |args|
    args[3..].postln;
    ~bus.setSynchronous(*args[3..]);
}, '/acc');

