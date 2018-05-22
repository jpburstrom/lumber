~bela = Server.remote(\bela, NetAddr("192.168.7.2", 57110));
~bela.startAliveThread

{ MPU.gyroKr.poll }.play
MPU


~vals = Bus(\control, 64, 11, ~bela)
~vals.get

~slider = Slider2D().front

(
x= fork {
    loop {
        ~vals.get { |vals|
            var pr = vals[9..10].linlin(-90,90,0,1);
            pr.postln;
            {
                ~slider.setXY(pr[1], pr[0])
            }.defer
        };
        0.1.wait;
    }
}
)
[2,3,4][-2]


(
Ndef(\test, {
    var snd, freq=440, amp=1, fb=0;
    var pitch = In.kr(73);
    var roll = In.kr(74);
    freq = 2.pow((roll).linlin(-90, 90, -1, 1)) * 440;
    fb = (pitch).linlin(-30, 30, 0, 1) * 0.5pi;
    amp = (pitch).explin(-90, -0.1, 0.01, 1);
    snd = SinOscFB.ar(freq.lag(0.02), fb.lag(0.02), amp.lag(0.02));
    snd = snd.tanh;
}).play;
)
s.freeAll
CmdPeriod.freeRemote = true
Server.default = ~bela
s.freeAll
~bus = Bus.audio(~bela);
(
z.free;
z = {
    var snd, in, prev;
    var slow, thresh = 0.01, trig;
    AnalogOut.ar(7, DC.ar(0.835));
    in = AnalogIn.ar(1);

    //If
    trig = in > thresh;



    //in.poll;

    // in = Select.ar(in < thresh, [in, Gate.ar(DelayN.ar(in, 0.1, 0.1), in > thresh)]);

    //Delayed sensor signal -> Track and hold
    //Delay is 0 when signal is low
    //And 0.01 when signal is high
    //Delay time is lagged so the right value is sampled and held
    in = Gate.ar(DelayN.ar(in, 0.01, trig.lag(0.1) * 0.01), trig);
    //Lag signal, maybe not needed
    Lag.ar(in);
    Out.kr(~bus, in);

    snd = SoundIn.ar(0);
    4.do { snd = HPF.ar(snd, 60) };
    // snd = WhiteNoise.ar;
    snd = BHiShelf.ar(snd, 200, 1, -36);
    snd.poll;

    snd = DelayC.ar(snd, 0.1, AnalogIn.ar(1).lag(0.5) * 0.01);

    snd + FreqShift.ar(snd, AnalogIn.ar(0) * -1000);

    snd = snd * 25.dbamp;
    snd = Compander.ar(snd, snd, 0.1, 1, 0.33);

    Out.ar(1, snd);
    //Out.kr(~bus, DC.ar(0.5));
}.play
)
~slider
~slider = Slider()
~slider.front
(
fork {
    inf.do {
        0.5.wait;
        ~bus.get({ |x| defer { ~slider.value = x }})
    }
}
)
