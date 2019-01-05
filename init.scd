(
//Load common variables into Library(\lumber, \common)
Require("lib/common", always:false);
Require("lib/d_synthdefs", always:true);

q.reject(_.isSymbol).do { |x| x.free };
q.make {
	~serverName = Library.at(\lumber, \serverName);
	//Macro parameters - mapping controllers to parameters
	~macros = Require("lib/m_macros");
	//Macro parameters - mapping controllers to parameters
	~eq = Require("lib/m_eq");

	//Presets
	~presets = Require("lib/c_presets");
	~presets.register(\macros, ~macros);
	~presets.register(\eq, ~eq);

	//Storage - handle save/load to disk
	~storage = Require("lib/c_storage");
	//Connect params to storage
	~storage.register(\macros, ~macros);
	~storage.register(\eq, ~eq);
	//And connect presets as well, making it possible to save both
	//bank of presets and params by group
	~storage.register(\presets, ~presets);


	//Sound stuff
	~serverController = Require("lib/c_server");
	~serverController.connectToModels(\eq, ~eq, \macros, ~macros);

	Fdef(\ifBela).value(
		{
			//Make it explicit
			~serverController.server = Server.local;
		},
		{
			//Show GUI
			Require("lib/g_main");

			Require("lib/c_midi");

			if (~serverName == \local) {
				~serverController.server = Server.local
			} {
				~serverController.server = Server.named[\bela] ?? {
					var server = Server.remote(\bela,
						NetAddr(Library.at(\lumber, \common, \belaAddress), 57110));
					server
				};
				SynthDescLib.all[\lumber].addServer(Server.named[\bela]);
			}
		}
	);

	//Put server where others can find it
	Library.put(\lumber, \server, ~serverController.server);
	~storage.load;
	fork {
		~serverController.bootPrep;
		~serverController.play;
	};
};
\done
)

