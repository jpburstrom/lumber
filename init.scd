q = ();

(
//Macro parameters - mapping controllers to parameters
q.macros = Require("lib/macros");

//Macro parameters - mapping controllers to parameters
q.eq = Require("lib/eq");

//Storage - handle save/load to disk
q.storage = Require("lib/storage");

//Connect macros with storage
q.storage.register(\macros, q.macros);
q.storage.register(\eq, q.eq);
)

//Synth graph (including server-side controllers)

Volume
if (!q.bela) {

    q.osc.grt

    q.gui
    //GUI

}
q.macros.