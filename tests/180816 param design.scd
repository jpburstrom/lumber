//Which params need to be stored to disk?
//  - Macro mapping (macroParam -> [on/off, amount] -> param)
//  - EQ settings (or hardcoded)

//Which params need to be stored/recalled when spawning a previously ended synth (reading from buses is a solution)

//how to store params to disk


//Group of macro controllers

~macros = #[
    //Bass lying down/standing up
    activity,
    //Bass forward or backward leaning against body
    intensity,
    //Bass turned relative to origin, or changes to orientation
    orientation,
    //Long softpot
    softpot_l,
    //Shorrt softpot
    softpot_s,
    //Expression pedal
    expression
];

// Create one bus for each parameter



ControlSpec
AbstractControlValue
Touch
//Mapping for gui
//These should be stored



ZArchive
//or maybe use nodeproxies to
Ndef(\m_activity, {
    //Some code
    var out = SinOsc.kr(1);

    out
});

p = ProxySpace(s)
p[\m_activity] = { SinOsc.kr(0.1) }
p['macro.activity']

NdefPreset


//Map a macro parameter to some effect
Ndef(\freqshift, {
    var snd = SinOsc.ar * 0.1;
    //XXX maybe exprange doesn't work with values 0-1
    var freq = ~macroBuses.intensity.kr.exprange(0, -600)
    FreqShift.ar(snd, freq);
})


//or through an lfo
Ndef(\randomLFO, {
    LFNoise2.kr(1) * ~macroBuses.intensity.kr;
})

~macroBuses.intensity.set(0.5)

Ndef(\thisCouldBeAnEffect, {
    SinOsc.ar(Ndef(\randomLFO).kr.exprange(220, 440)) * 0.1;
}).play



