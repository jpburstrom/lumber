(
~bela = Server.remote(\bela, NetAddr("bela.local", 57110));
CmdPeriod.freeRemote = true;
Server.default = ~bela;
)

~bela.initTree


Ndef(\inputMonitor, { SoundIn.ar(0).dup }).end

//¨...........


//Record input channel
r = Recorder(~bela)
r.prepareForRecord("/root/miktest3.wav", 1);
r.record(bus: s.options.numOutputBusChannels)
    r.stopRecording


//Simple feedback loop
(
Ndef(\zero, {
    var snd = SoundIn.ar(0) * \preamp.kr(10);
    4.do { snd = HPF.ar(snd, 60) };
    snd = BHiShelf.ar(snd, 200, 1, -36);
    snd
}).play
)


Quarks.update("Modality-toolkit")

MKtlDesc.postLoadable

"https://modalityteam.github.io/controllers/".openOS;

MKtl.find

m = MKtl('midi_0_arturi', "arturia-beatstep-rel-16");
m.trace(false)

m.elAt(\1, \kn, \10).action = { |x| x.value.postln }