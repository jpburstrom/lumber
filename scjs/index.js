// jshint esversion:6
var sc = require("supercolliderjs");
let { defLoad } = require("supercolliderjs/lib/server/osc/msg");
let { dryadic, SCLang, SCServer, SCSynthDef, Synth } = require('supercolliderjs/lib/dryads');
let path = require('path');

let app = dryadic();

//Load server
let s = new SCServer({}, [
    new Synth({
        def: new SCSynthDef({
            loadFrom: "sinosc.scsyndef",
        })
    })
]);

//no Exit after loading synth
app.play(s); //.then(() => { process.exit(0)  });

