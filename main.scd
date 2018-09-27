(
//Load common variables into Library(\lumber, \common)
Require("lib/common", always:false);

q.do(_.free);
q.make {
	//Macro parameters - mapping controllers to parameters
	~macros = Require("lib/m_macros");
	//Macro parameters - mapping controllers to parameters
	~eq = Require("lib/m_eq");
	//Storage - handle save/load to disk
	~storage = Require("lib/c_storage");
	//Connect macros with storage
	~storage.register(\macros, ~macros);
	~storage.register(\eq, ~eq);

	//Sound stuff
	~serverController = Require("lib/c_server");
	~serverController.connectToModels(\eq, ~eq, \macros, ~macros);

	Platform.case(
		//Load gui on osx
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
			~serverController.server = Server.local;
		}
	);

	//Put server where others can find it
	Library.put(\lumber, \server, ~serverController.server);
	~storage.load;
	~serverController.play;
}
)
