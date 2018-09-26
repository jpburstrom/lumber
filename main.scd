q = ();

(
//Load common variables into Library(\lumber, \common)
Require("common", always:false);

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
	~serverController = Require("lib/c_server");

	Platform.case(
		\osx, {
			Require("lib/g_main");
			~serverController.server = Server.named[\bela] ?? {
				var server = Server.remote(\bela, NetAddr(Library.at(\lumber, \common, \belaAddress), 57110));
				server
			};
		},
		//Bela
		\linux, {
			//Make it explicit
			~serverController.server = Server.default;
		}
	);

	~serverController.play(server);
}

)

q.server.play;
q.eq.params.hiShelf.freq.value = 200