q = ();

(
q.do(_.free);
q.make {
	//Macro parameters - mapping controllers to parameters
	~macros = Require("lib/m_macros");
	//Macro parameters - mapping controllers to parameters
	~eq = Require("lib/m_eq");
	//Storage - handle save/load to disk
	~storage = Require("lib/c_storage");
	//Connect macros with storage
	~storage.register(\macros, q.macros);
	~storage.register(\eq, q.eq);

	//Sound stuff
	~server = Require("lib/c_server");




	//
	if (true) { //TODO: GUI check
		Require("lib/g_main");
	}
}

)

q.server.play