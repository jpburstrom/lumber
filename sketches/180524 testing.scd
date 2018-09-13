~bela = Server.remote(\bela, NetAddr("bela.local", 57110));
CmdPeriod.freeRemote_(true);
Server.default = ~bela


~sfbuf = Buffer.cueSoundFile(~bela, "/root/lovestory.wav")

{ ReplaceOut.ar(0, BPeakEQ.ar(BHiShelf.ar(In.ar(0, 2), 8000, 1, -24), 800, 1, 12) ) }.play

{ WhiteNoise.ar * 0.5 }.play

b = Buffer.alloc(s, 512, 1, { |buf| buf.chebyMsg([1,0,1,1,0,1])})

b.cheby([1, 1, 1, 1, 1, 0, 1]);
b.chebyMsg([1,0,1,1,0,1])
Ndef(\test).fadeTime
(
Ndef(\test, {

    var pedal, snd, amp;
    var rms500, rms1, analytics;

    AnalogOut.kr(7, 0.8192);
    pedal = AnalogIn.ar(7);

    snd = SoundIn.ar(0).poll * 10;


    //snd = BLowShelf.ar(snd, 100, 1, 24.dbamp);
    snd = BHiShelf.ar(snd, 400, 1, -32);
    // snd = snd + SinOsc.ar(\freq.kr(290), 0, 1);
    snd = BHiCut.ar(snd, 800);

    // snd = BPeakEQ.ar(snd, 120, 0.1, -3);
    // snd = BPeakEQ.ar(snd, 305, 0.1, -9);
    // snd = BPeakEQ.ar(snd, 140, 0.1, -3);
    // snd = BPeakEQ.ar(snd, 83, 0.1, -3);
    //
    snd = BLowShelf.ar(snd, 60, 1, -24);
    // snd = snd + Shaper.ar(b, snd, 1);

    //snd = snd + FreqShift.ar(snd, 20.0);

    // snd = DelayC.ar(snd, 0.1, 0.1);

    rms500 = RMS.ar(snd, 500);
     rms1   = RMS.ar(snd, 1) * 2;
     analytics = max(rms500 - rms1, 0) + rms1;

    snd = (DelayC.ar(snd, 0.02, \lookahead.kr(0) * 0.02) / max(analytics / \limit.kr(0.9), 1));
    amp = Amplitude.ar(snd);
    /*
    snd = Compander.ar(snd, snd, 0.75, 1, 0.01, 0.01, 0.01);

    amp = Amplitude.ar(snd);

    */
    // RunningMax.ar(amp).poll;

    // snd = DelayC.ar(snd, 1, pedal.lag(0.02) * 1);

    // snd = DelayC.ar(snd, 0.01, LFNoise2.ar(1).range(0, 0.01));

    snd * pedal.lag(0.01);




    DelayN.ar(snd, 0.1, ((pedal.lag(0.1) * 127)).midicps.reciprocal);

    // SinOsc.ar * 0.1

}).play;
// 127.midicps.reciprocal
)
"C1".namemidi
Ndef(\test).gui


Ndef(\testtone, { SinOsc.ar(\freq.kr(50)) * 0.5 }).play

Ndef(\testtone).addSpec(\freq, [50, 2500, \exp])
Ndef(\testtone).gui

{ SoundIn.ar(1) }.play


SynthDef(\sinePerc, { Out.ar(\outbus.kr(0), SinOsc.ar(\freq.kr, \phase.kr(0)) * Env.perc(0, \sustain.kr(1)).ar(2)) }).add;

Pdef(\test, Pbind(\instrument, \sinePerc, \octave, 3, \dur, Pwrand([0.25, Pseq(0.25 * [0.65, 0.35])], [0.9, 0.1], inf), \note, Pwhite(0, 24), \legato, 2, \phase, pi * 0.0)).play

{  (MoogFF.ar(Blip.ar(LFNoise2.ar(1).exprange(1, 100), 100), LFNoise2.ar(1).exprange(200, 2000), 2) * 4).softclip * SinOsc.ar(60) }.play

s.meter
CmdPeriod.freeRemote = true

{ MPU.accelKr.poll }.play

{ MPU.pitchKr.poll( }.play

    SCDoc.indexAllDocuments(true); MPU.help

    AnalogIn.help


    MPU.calibrateAccelGyro(~bela)
    MPU.saveCalibration("/root/.config/SuperCollider/mpuCalibration.bin")
    MPU.loadCalibration("/root/.config/SuperCollider/mpuCalibration.bin")


    thisProcess.platform

    Platform.userConfigDir

    nil ?? 2

    s.isRunning




    { SinOsc.ar( AnalogIn.ar( (0..7) ).exprange( 200, 5000 ).poll, 0, 0.1 ) }.play

    //Expression pedal needs power from analog out 7
    { AnalogOut.ar(7, 0.8192); SinOscFB.ar(MPU.accelKr.linexp(-1, 1, 220, 440), AnalogIn.ar(7).poll, 0.1).sum.dup }.play


    