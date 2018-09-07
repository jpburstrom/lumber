//synth definitions could be set here
//If we make it a proto we could use its putAction to send a changed message whenever
//definition is changed
/*
(
p = Proto {


};
p.putAction = { |k, v|
	p.changed(\put, k, v);
}
)
*/

//then use the changed message (or maybe the putAction directly)
//to update nodeproxies or synths

~macroParms = (
    'orientation': (
        delay: { |snd, delay, amount|
            delay = delay.linlin(0, 1, 0.2, 0.5) * amount;
            DelayC.ar(snd, 0.2, delay);
        },
        freqshift: {}
    ),
    'intensity': (
        volume: { |snd, vol, amount|
            vol = (1 * (1-amount)) + (vol * amount);
            snd * vol;
        },
        saturation: (),
        freeze: { |snd, freeze, amount|
            var recTrig = freeze > 0.8;
            var playTrig = freeze < 0.2;
            //...
        }

    ),
    'activity': (

    ),
    'spl': (

    ),
    'sps': (

    ),
    'pedal': (

    ),
);



(
~macroParms.keysValuesDo { |param, effects|

    effects.keysValuesDo { |effect, func|

        func.postcs

    }

};
)