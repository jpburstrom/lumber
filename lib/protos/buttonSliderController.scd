"buttonController".import.clone({

    var disableSynch = false;

    ~elementGroup = \pad;
    ~isKeyInited = true;

    //Storage for normalized values on key press
    ~tmpVal = ();

    ~buttonActionFactory = { |key|
        { |isOn|
            var output;

            if (isOn) {

                output = ~onShortPress.(key, ~tmpVal[key])

            };

            output !? { currentEnvironment[~setStateFunc].(key, output) };
        }
    };

    ~ktlAction = { |onoff, e, grp|

        ~indexMapper[grp.name] !? { |index|
            if (e.isOn) {
                var size = grp.elements.size;
                var val = grp.elements.indexOf(e);
                //Bottom-most button works as a toggle, turning off value if cur value > 0
                if (val == 0 and: { (~tmpVal[index] ? 0) > 0} ) {
                    ~tmpVal[index] = 0;
                } {
                    ~tmpVal[index] = (val + 1) / size;
                }

            };
            ~actions[index].value(e.isOn);
        }
    };


    ~onShortPress = { |key, val|

        val

    };

    ~elementAt = { |key|
        ~ktl.elementAt(~elementGroup, key)
    };


	~connectCV = { |cvs|
        ~cvs = cvs;
        if (cvs.size != ~indexes.size) {
            "Couldn't connect CVs. Check the array sizes".warn;
        } {
            cvs.do(_.addDependant(currentEnvironment));
            ~onStateChange = { |k, v|
                disableSynch = true;
                cvs[k].value = v;
                disableSynch=false;

            };
        }
	};

    ~update = e { |obj, what, v|
        if (what == \synch && disableSynch.not) {
            //this should be enough
            var k = ~cvs.indexOf(obj);
		    ~setState.(k, v.value);
        }
    };
});
