(
MKtl('lp', "novation-launchpad-mini", true);
~lpOut = LaunchpadOut(MKtl('lp'));

MKtl('lp-amount', "novation-launchpad-mini");
MKtl('lp-lfo', "novation-launchpad-mini");
~pages = PagedMKtl(\arrPages, ['lp-amount', 'lp-lfo'], ['amount', 'lfo'])
)
~pages.currPage
~pages.pageNames

MKtl('lp-amount').elAt(\padSlider)

MKtl('lp-amount').elAt(\padSlider).do { |x| x.value.postln }
MKtl('lp-lfo').elAt(\padSlider).do(_.doAction)

MKtl('lp').elAt(\arr, 0).action = { ~pages.page('lp-amount'); MKtl('lp-amount').elAt(\padSlider).do(_.doAction) }.inEnvir
MKtl('lp').elAt(\arr, 1).action = { ~pages.page('lp-lfo') }.inEnvir
Model
~state
(
~state = ();
['lp-amount', 'lp-lfo'].do { |page|
    var x, m;
    m = MKtl(page);

    ~state[page] = ();

    x = MKtlElementGroup(\padSlider, m,
        8.collect { |i|
            ~state[page][i] = 0;
            MKtlElementGroup(i, m,
                8.collect { |j|
                    var index, key;
                    j = 7 - j;
                    index = i + (j * 8);
                    key = j.asSymbol;
                    key -> m.elAt(\pad, index);

                }
            );
        }

    );
    m.addNamed(\padSlider, x);
    m.elAt(\padSlider).debug;


    m.elAt(\padSlider).action = { |el, grp, sl, parent|
        if (grp.isOn) {
            var slider = parent.elemIndexOf(sl);
            var value = sl.elemIndexOf(grp);
            8.do { |i|
                var index = (8 * (7 - i)) + slider;
                var color = \off;
                if (i <= value) {
                    color = \green
                };
                color.postln;
                ~lpOut.setColor(index, color)

            };
            ~state[page][slider] = value;
            [slider.class, value].postln
        }
    }
};

)


//Art -> LP slider

MKtl('art', "arturia-beatstep-rel-16")

(
~values = (knob:0);
MKtl('art').elAt(\1, \kn, 0).action = { |el|
    var val;
    // el.value.postln;
    ~values.knob = (~values.knob + ((el.value - 0.5) * 0.5)).max(0).min(1);
    val = (~values.knob * 8);
    8.do { |i|
        var color;
        color = \off;
        if (val > i) {
            color = \green
        };
            if (val.absdif(i) < 0.5 and: { val != 0 }) {
                color = \yellow
            };

           i = 7 - i;
        ~lpOut.setColor(i * 8, color)
    };
};
)


