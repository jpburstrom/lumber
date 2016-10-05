//Create launchpad mktl
~lp = MKtl('lp', "*launchpad*");
~lp.rebuild

(
~ctl.free;
~ctl = "../lib/protos/buttonController".import;
~ctl.connect(~lp, (0..7));
~ctl.isKeyInited = true;
~ctl.onShortPress = { |index| index.postln; 1 }
)
~ctl.indexMapper
~ctl.model

~lp.elAt(\pad).elements
action = { |index| index.postln }
~lp.elementGroup.elements
\pad_1_on]
MKtl