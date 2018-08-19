//Macro parameters takes input from a sensor
//and maps it to one or several synth parameters
Proto({

    //Macro sources
    //That is, physical or virtual controllers
    //This also defines gui order
    //Should it?
    ~sources = #[
        activity, intensity, orientation,
        softpot_l, softpot_s,
        expression
    ];

    //Parameter labels
    //This defines macro->parameter mapping
    //Arrays also define parameter order
    ~paramLabels = (
        'softpot_s': ["EQ", "Delay"],
        'orientation': [ "Delay" ],
        'intensity': ["Freeze", "Volume", "Saturation"],
        'softpot_l': ["Pitch", "Phase", "Delay"],
        'activity': ["LFO"],
        'expression': ["Weirdness"]
    );

    //Parameter dictionary
    ~params = ();
    ~paramLabels.keysValuesDo { |k, v|
        ~params[k] = v.collectAs({ |p|
            //XXX maybe cv
            p.toLower.asSymbol -> (
                active: OnOffControlValue(\off),
                amount: NumericControlValue()
            )
        }, Event)
    };

    //-- Methods below -------


    //Load param dictionary
    //Useful for preset loading
    ~setParams = { |obj|

        ~params.keysValuesDo { |macro, params|
            //Check if obj has macro
            obj[macro] !? { |objParams|
              params.keysValuesDo { |param, settings|
                    //Check if obj has param (in case preset structure changes)
                    objParams[param] !? { |objSettings|
                        settings.keysValuesDo { |k, v|
                            objSettings[k] !? { |objValue|
                                // [param, k, objValue.value].debug("loading");
                                // ~params[macro][param][k].value = .postln;
                                ~params[macro][param][k].value = objValue.value;
                            }
                        }
                    }
                }
            }
        };
    };

    //Get dictionary of param values
    //Useful for preset saving
    ~getParams = { |usage|
        var obj = ();
        ~params.keysValuesDo { |macro, params|
            obj[macro] = ();
            params.keysValuesDo { |param, settings|
                obj[macro][param] = ();
                settings.keysValuesDo { |k, cv|
                    obj[macro][param][k] = cv.value;
                }
            }
        };
        obj
    };


    ~getParamsFor = { |source, label|
        ~params[source][label.asString.toLower.asSymbol];
    };

    //Set single parameter
    //Usage: .set(\macro, \param, \setting, value)
    ~set = { |...args|
        var v, x = ~params;
        if (args.size != 4) {
            "Macros -set: Wrong argument count".error;
        } {
            v = args.pop;
            args = args.reverse;
            while { x.isKindOf(Event) } {
                x = args.pop.asSymbol !? { |k|
                    k.postln;
                    x[k];
                }
            };

            x.postln;

            x !? {
                x.value = v;
            }
        }

    }

});
