q = ();

q.bela = false; //TODO set this programmatically

//Macro parameters - mapping controllers to parameters
q.macros = Require("lib/macros");
//Storage - handle save/load to disk
q.storage = Require("lib/storage");

//Connect macros with storage
q.storage.register(\macros, q.macros);

//Synth graph (including server-side controllers)
q.storage.register(\foo, (getParams: 22, setParams: {|this, x| x.postln }))

q.storage.save(\foo)

q.storage.load(\foo)

//OSC setup (touchosc)
q.osc = ();
q.osc.touchosc;

if (!q.bela) {

    q.osc.grt

    q.gui
    //GUI

}
AnalogIn


