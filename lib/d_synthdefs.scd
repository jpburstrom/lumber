var sources = Library.at(\lumber, \common, \macroSources);
var destinations = Library.at(\lumber, \common, \macroDestinations);

//Clear all synthDescs when rebuilding
SynthDescLib.all[\lumber].synthDescs.clear;

Require("synthdefs/*");

//Set all synthDescs from lumber lib as macro destinations
SynthDescLib.all[\lumber].synthDescs.do { |desc|
	desc.metadata !? {
		if ( true == desc.metadata[\destination] ) {
			destinations[desc.name.asSymbol] = desc.metadata;
		};
		if ( true == desc.metadata[\source] ) {
			sources[desc.name.asSymbol] = desc.metadata;
		}
	}
};
