~bela = Server.remote(\bela, NetAddr("192.168.7.2", 57110));
Server.default = ~bela;
~bela.startAliveThread;
CmdPeriod.freeRemote = true;


s.sendMsg(\cmd, \mpuCmd, 4, "/tmp/test.bin");

//Allocate some things
(
~bus = Bus.control(~bela, 3);
~weki = NetAddr("localhost", 6448);
)
(
//Put accel values -> bus
{ Out.kr(~bus, MPU.accelKr.lag(0.1) ) }.play
)
~bus.get

~bela.listSendMsg(["/c_get", 6]);

s.initTree
s.notify

Server.killAll
(
//Send bus values to wekinator
Tdef(\bus2osc, {
    loop {
        ~bus.get { |val|
            ~weki.sendMsg('/wek/inputs', *val)
        };
        0.03.wait;
    }
}).play
)
~weki.sendMsg('/wek/inputs/inputs-1', [2,3,4])
s

(
{
    var a = MPU.accelKr.lag(0.1);
    var g = MPU.gyroKr.lag(0.1);
    var x = MPU.yawKr.poll;

    var freq = Stepper.kr(g[0] > 40, 1, 1, 8) * Stepper.kr(g[0] < -40, 120, 120, 330, 10);
    // g[0].poll;
    x.poll;
    x = x.linexp(0, 360, 220, 440);

    SinOsc.ar(x, 0, 1)
}.play
)
