// jshint esversion:6
var sc = require("supercolliderjs");
let { dryadic, SCLang, SCServer, SCSynthDef, Synth } = require('supercolliderjs/lib/dryads');

let app = dryadic();

let s = new SCServer({}, [
    new SCLang({debug: false}, [
        new SCSynthDef({
            compileFrom: 'sinosc.scd',
            saveToDir: './'
        }) 
    ])
]);

app.play(s);
