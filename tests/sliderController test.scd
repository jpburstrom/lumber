//Create launchpad mktl
~lp = MKtl('lp', "*launchpad*")
~lpOut = LaunchpadOut(~lp);

(
//Create 8 groups of sliders
~lp.rebuild;
MKtlElementGroup.addGroupsAsParent = true;
~lp.addNamed(\padSlider, MKtlElementGroup(\padSlider, m,
    8.collect { |i|
        MKtlElementGroup((i + 1).asSymbol, ~lp,
            8.collect { |j|
                var index, key;
                j = 7 - j;
                index = i + (j * 8);
                key = (j + 1).asSymbol;
                key -> ~lp.elAt(\pad, index);

            }
        );
    }

));
MKtlElementGroup.addGroupsAsParent = false;
)

(
//Create controller
~ctl.free;
~ctl = "../lib/protos/buttonSliderController".import;
~ctl.elementGroup = \padSlider;
~ctl.connect(~lp, (0..7));
~ctl.isKeyInited = true;
~ctl.connectCV(~cvs = 8.collect { CV() })
)

(
~cvs[1].value = 0;
~ctl.model[1].value
)

~cvs[0].value = 0.52

(
~view.free;
~view = "../lib/protos/sliderView".import;
~view.connect(~ctl, ~lpOut);
)
~ctl.model
~lp.elementAt(\padSlider, '1').do (_.postln)

~ctl.elementGroup

~ctl.onStateChange

~ctl.indexMapper
~ctl.env[\onShortPress].asCode

~lp.elementAt(\padSlider, 0).elements.size

MKtlElementGroup
~lp.rebuild
~lp.elementAt(\pad, 0)[0]
elemDesc
~lpOut.setElemColor(~lp.elementAt(\pad, 7)[0])
~lp.elementAt(\pad, 1)
~lp.elementAt(\bt, 0).elemDesc.midiMsgType.class
~lp.elementAt(\pad, 0, 0).elemDesc
MKtlElement
~lp.elementAt(\padSlider, 0, 0).type