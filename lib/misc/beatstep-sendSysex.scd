Fdef(\beatstepResetControllers, {

    fork {
    var ctl = (enc: (0x20..0x2F), pad: (0x70..0x7F), vol: 0x30, stop:0x59, play:0x58);
    var param = (mode:1, chan:2, cc:3, lo:4, hi:5, relmode:6);
    var globalChan = 41;
    var device = MKtl('art').device.midiOut; //FIXME
    var padMode = (off: 0, contCC:1, mmc: 7, ccSwitch: 8, note:9, pgm: 0x0B);
    var encMode = (off: 0, cc: 1, nrpn: 4);
    var encRelMode = (abs: 0, rel1: 1, rel2: 2, rel3: 3);
    var sendSysex = { arg ctl ... args;
        args.pairsDo { arg param, val;
            [param, val].postln;
            device.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 2, 0, param, ctl, val, 0xF7 ]);

        };
            0.01.wait;
    };

    var gl = (chan:0, acc: (slow: 0, medium:1, fast:2), padVel: (lin:0, log:1, exp:2, full:3));
    //Global settings
    //Channel (0-based)
    device.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 2, 0, 0x40, 0x06, gl.chan, 0xF7 ]);
    device.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 2, 0, 0x41, 0x04, gl.acc.medium, 0xF7 ]);
    device.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 2, 0, 0x50, 0x03, gl.padVel.exp, 0xF7 ]);


    (ctl.enc ++ ctl.vol).do { |enc|
        sendSysex.(enc,
            param.mode, encMode.cc,
            param.chan, globalChan,
            param.cc, enc,
            param.relmode, encRelMode.rel1
        );
    };

    ctl.pad.do { |pad|
        sendSysex.(pad,
            param.mode, padMode.note,
            param.chan, globalChan,
            param.cc, pad,
            param.lo, 0,
            param.hi, 127
        );
    };
    }
});
Fdef(\beatstepResetControllers).value;

Fdef(\beatstepStore, { |slot|
    MKtl('art').device.midiOut.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 06, slot, 0xF7 ]);
});

Fdef(\beatstepRecall, { |slot=1|
   MKtl('art').device.midiOut.sysex(Int8Array[ 0xF0, 0, 0x20, 0x6B, 0x7F, 0x42, 05, slot, 0xF7 ]);
}).value;

Fdef(\beatstepRecall).value(0)
