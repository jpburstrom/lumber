//sliderView
//Showing a value from 0-1 as group color
Proto({
    ~controller = nil;
    ~lpOut = nil;
    //Colors: Off, half, full
    ~colors = [\off, \lRed, \red];
    ~elementGroup = nil;

    ~connect = { |ctl, view|
        ~controller = ctl;
		~lpOut = view;

        if (view.notNil) {
            ctl.addDependant(currentEnvironment);
        };
        currentEnvironment;

    };

    ~update = { |obj, what, k, v|
        if (what == \state) {
            var elements = ~controller.elementAt(k).elements;
            v = v * (elements.size);
            elements.do { |el, i|
                var index=0; //Color index
                if (i < v.floor) { // If this element is than value, give it the "full" color
                    index = 2;
                } {
                    //Otherwise if element is between v + 0.5 and v + 1, give it "half" color
                    if ((v - i) > 0.5) {
                        index = 1
                    }
                };
                ~lpOut.setElemColor(el[0], ~colors[index]);
            }

        }
    }.inEnvir;

    ~free = {
        ~controller.removeDependant(currentEnvironment);
    }.inEnvir;
});
