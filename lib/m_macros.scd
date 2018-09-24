//Macro parameters takes input from a sensor
//and maps it to one or several synth parameters
Proto({

	~sources = Library.at(\lumber, \common, \macroSources);

    //Parameter labels
    //This defines macro->parameter mapping
    //Arrays also define parameter order
    ~paramLabels = Library.at(\lumber, \common, \macroMapping);

    //Parameter dictionary
    ~params = ();
    ~paramLabels.keysValuesDo { |src, dests|
		~params[src] = ();
		dests.keysValuesDo { |key, o|
			~params[src][key] = (
                active: OnOffControlValue(\off),
                amount: NumericControlValue()
            )
        }
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
