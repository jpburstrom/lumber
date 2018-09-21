var common = Require("common");

Require("synthdefs/*");

//Check that we have all needed defs
common.macroMapping.keysValuesDo { |k, o|
	o.keysValuesDo { |kk, map|
		SynthDescLib.match(map.def) ?? { "Macro synthDef '%' not found".format(map.def).warn }
	}
};