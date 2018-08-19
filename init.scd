q = ();

q.bela = false; //TODO set this programmatically

//Macro parameters - mapping controllers to parameters
q.macros = Require("lib/macros");
//Storage - handle save/load to disk
q.storage = Require("lib/storage");

//Connect macros with storage
q.storage.register(\macros, q.macros);

//Load state from disk
q.storage.save


//Synth graph (including server-side controllers)


//OSC setup (touchosc)
q.osc = ();
q.osc.touchosc;

if (!q.bela) {

    q.osc.grt

    q.gui
    //GUI

}



