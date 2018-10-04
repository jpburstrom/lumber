var common = Require("common");
var sources = Library.at(\lumber, \common, \macroDestinations);

Require("synthdefs/*");

//Set all synthDescs from lumber lib as macro destinations
SynthDescLib.all[\lumber].synthDescs.do { |desc|
	desc.metadata !? {
		desc.metadata.lumber !? { |lum|
			var group = lum.group;
			sources[desc.name.asSymbol] = lum.copy.make {
				~specs = (
					desc.metadata.specs
				);
			};
		}
	}
};

//Check that we have all needed defs
/*
Library.at(\lumber, \common, \macroMapping).do { |list|
	list.do { |map|
		SynthDescLib.match(map.def) ?? { "Macro synthDef '%' not found".format(map.def).warn }
	}
};
*/