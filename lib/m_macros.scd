//Macro parameters takes input from a sensor
//and maps it to one or several synth parameters
Proto({

	~sources = Library.at(\lumber, \common, \macroSources);

    //Parameter labels
    //This defines macro->parameter mapping
    //Arrays also define parameter order
    ~destinations = Library.at(\lumber, \common, \macroDestinations);

    //Parameter dictionary
	//Source -> dest -> input
    ~params = ();
	~sources.do { |src|
		~params[src] = ();
		~destinations.keysValuesDo { |key, dest|
			~params[src][key] = ();
			dest.inputs.do { |input|
				~params[src][key][input] = (
					active: OnOffControlValue(\off),
					levels: NumericControlValue([0,0.5,0.5,1], \unipolar.asSpec),
					times: NumericControlValue([0.4, 0.2, 0.4], \unipolar.asSpec),
					curves: NumericControlValue([-4, 0, 4], ControlSpec(-16, 16, \lin)),
					lagU: NumericControlValue(),
					lagD: NumericControlValue()
				)
			};
		};
	};


	//-- Methods below -------

	~recursiveDo = { |cb, maxDepth=5|
		var rec = { |obj, cb, keys, count=0|
			count = count + 1;
			obj.keysValuesDo { |k, v|
				if (v.respondsTo(\keysValuesDo) and: { count < maxDepth }) {
					rec.(v, cb, keys ++ k.asArray, count + 1);
				} {
					cb.(*(keys ++ [k, v]));
				}
			};
			currentEnvironment
		};
		rec.(~params, cb);
	};


    //Load param dictionary
    //Useful for preset loading
    ~setParams = { |obj|
	    ~params.keysValuesDo { |srcKey, dests|
			dests.keysValuesDo { |destKey, dest|
            //Check if obj has macro
				obj[srcKey][destKey] !? { |objInputs|
					dest.keysValuesDo { |input, cvs|
						//Check if obj has param (in case preset structure changes)
						objInputs[input] !? { |objCvs|
							cvs.keysValuesDo { |k, v|
								objCvs[k] !? { |objValue|
									cvs[k].value = objValue.value;
								}
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
        ~params.keysValuesDo { |srcKey, dests|
			obj[srcKey] = ();
            dests.keysValuesDo { |destKey, dest|
				obj[srcKey][destKey] = ();
				dest.keysValuesDo { |input, cvs|
					obj[srcKey][destKey][input] = ().make {
						cvs.keysValuesDo { |k, cv|
							currentEnvironment[k] = cv.value
						};
					}
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
                    x[k];
                }
            };

            x !? {
                x.value = v;
            }
        }

    }

});


