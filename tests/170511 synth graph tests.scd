b = Bus(numChannels:1);
c = Buffer.alloc(s, 1024, 1);
//size must be power of two plus 1
t = Signal.chebyFill(513,[1, 0.5, 1, 0.125]);
// linear function
t.plot
// t.asWavetableNoWrap will convert it to the official Wavetable format at next power of two size
c.sendCollection(t.asWavetableNoWrap);  // may also use loadCollection here

//------------
c
(
SynthDef(\ribbon, { |index, to, bufnum(-1)|
    //TODO: maybe map index
    //var snd = AnalogIn.ar(index);
    var snd = SinOsc.ar;
    //snd = Shaper.ar(bufnum, snd);
    Out.ar(to, snd);
}).add;

SynthDef(\shaped, { |from, to, bufnum|
    var snd = In.ar(from);
    //TODO: map range sensibly
    snd = Shaper.ar(bufnum, snd);
    snd = snd;
    ReplaceOut.ar(to, snd);
}).add;


SynthDef(\range, { |from, to, min, max|
    var snd = In.ar(from);
    //TODO: map range sensibly
    snd = snd;
    ReplaceOut.ar(to, snd);
}).add;

SynthDef(\cubed, { |from, to|
    var snd = In.ar(from);
    snd = snd.cubed;
    ReplaceOut.ar(to, snd);
}).add;

SynthDef(\route, { |from, to|
    Out.ar(to, In.ar(from))
}).add;
)
//----------------

(
var env = currentEnvironment;
~presets = Dictionary();
~c = c;
/*
Format:
preset_name[colon]
one bus per line, one group per line
synth definitions separated by comma
first token is synthDef name
then pairs of arguments
tokens starting with ~ are looked up in env
in javascript, env is simulated by using envObject[key]
are these variables evaluated once or every time?
if everytime, maybe easiest would be to enclose all variables in a function
and do .pairsCollect { |k, v| k, v.() }

TODO:
!bus [id] (...) (create bus(es), put in env[id])

so:
!bus main volume maxDelay third_bus
ribbon index 0, range min 0 max 0.5, route to ~volume
ribbon index 1, route to maxDelay
bass amp ~volume, route to third_bus
delay time maxDelay, route to main
route from main to 0
*/
"
preset 1:
audiobus test_bus 1, audiobus foo 2
ribbon index 0, range min 0 max 0.5, cubed, route to 0
ribbon index 0, range min 0.5 max 1, shaped bufnum ~c, route to 1
".split($:).pairsDo { |k, v|
    var lines = v.split(Char.nl);
    v = [];
    lines.reject(_.isEmpty).do { |line|
        var d;
        line.split($,).do { |synth|
            synth = synth.stripWhiteSpace.split(Char.space);
            synth = synth.collect { |s, i|
                //Hack: interpret env vars
                if (s[0] == $~) {
                    { env[s[1..].asSymbol] }
                } {
                    //Convert to number already here
                    s.asNumberIfPossible
                }

            };
            d = d.add([synth[0], synth[1..]])
        };
        v = v.add(d);
    };
    k.stripWhiteSpace.postcs;
    ~presets[k.stripWhiteSpace] = v
};

~presets


)
~volume = "HOHOHO"

~presets
~presets["preset 1"][1][0]
(
//List of disposables
~things = List();

//Create groups with routings

~presets["preset 1"].do { |lane|
    var ev = ();
    //Don't create private bus for one-item lines
    if (lane.size > 1) {
        ev.bus = Bus.audio();
    }
    ev.grp = Group.tail;
    lane.do { |syn|
        var args = (from: ev.bus, to: ev.bus);
        syn[1].pairsDo { |k, v|
            args[k.asSymbol] = v.value;

        };
        ev[syn[0].asSymbol] = Synth(syn[0].postln, args.asKeyValuePairs.postln, ev.grp, \addToTail);
    };
    ~things.add(ev);
    ///Synth(sd[0], sd[1].collect(_.value))
}
)
~things.do { |x| x.do(_.free) };

~things[0].route.set(\to, 0)
s.meter

~presets["preset 1"][0].size

(foo:23).putPairs([\foo, 234, \hello, 2])

