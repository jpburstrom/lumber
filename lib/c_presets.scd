//Preset collector
Require("../lib/protos/paramList").clone({

	var recursiveDo = { |thing, func|
		var out = ();
		thing.keysValuesDo{ |k, v|
			if (v.isKindOf(Dictionary)) {
				out[k] = recursiveDo.(v, func);
			} {
				out[k] = func.(v);
			}
		};
		out
	};

	//TODO: implement this + setIndex + \changed etc
	~activeIndex = 0;

	//Preset holder with 10 slots
	~params = 10.collect { `() };

	//Objects that are registered for preset handling
	~objects = ();

    //Register object at key
    //Objects should implement getParams and setParams
    //getParams is called with \preset as argument
    //so objects can exclude certain non-storable things
    ~register = { |key, object|
        if (~objects[key].notNil) {
            "Re-registering storage at key %".format(key).warn
        };
        ~objects[key] = object;
    };

    ~unregister = { |key|
        ~objects[key] = nil;
    };

	~save = { |index=0, keys|
		var obj = ();
		keys = ~prCheckKeyArg.(keys);
		keys.do { |k|
			obj[k] = ~objects[k].getParams(\preset);
		};
		~params[index].value = obj;
	};

	~load = { |index=0, keys|
		var obj = ~params[index].value;
		keys = ~prCheckKeyArg.(keys);
		keys.do { |k|
			~objects[k].setParams(obj[k]);
		}
	};

	~setSpecs = { |params|
		~specs = recursiveDo.(params, (_.spec));
	};

	~blendIndex = { |indexFrom, indexTo, blend = 0.5, fill = true|

		var blendFunc = { |these, that, blend, fill, specs|
			var commonKeys, mySingleKeys, otherSingleKeys;
			var myKeys =  these.keys, otherKeys = that.keys;
			var res = ();

			if (myKeys == otherKeys) {
				commonKeys = myKeys;
			} {
				commonKeys = myKeys.sect(otherKeys);
				mySingleKeys = myKeys.difference(otherKeys);
				otherSingleKeys = otherKeys.difference(myKeys);
			};

			if (specs.isNil) {
				commonKeys.do { |key|
					res.put(key, blendFunc.(these[key], that[key], blend));
				};
			} {
				commonKeys.do { |key|
					if (these[key].isKindOf(Dictionary)) {
						res.put(key, blendFunc.(these[key], that[key], blend, fill, specs[key]));
					} {
						var spec = specs[key], val;
						if (spec.notNil) {
							val = spec.map(
								blend(
									spec.unmap(these[key]),
									spec.unmap(that[key]),
									blend)
							);
							res.put(key, val);
						} {
							"% : no spec for % - using linear.\n".postf(thisMethod, key);
							res.put(key, blend(these[key], that[key], blend));
						};
					}
				};
			};
			if (fill) {
				mySingleKeys.do { |key| res.put(key, these[key]) };
				otherSingleKeys.do { |key| res.put(key, that[key]) };
			};
			res
		};

		blendFunc.(~params[indexFrom].value, ~params[indexTo].value, blend, fill, ~specs);
	};

	//Check argument, return array of keys
	~prCheckKeyArg = { |key|
		if (key.isNil) {
			key = ~objects.keys
		} {
			key.asArray
		}
	};


});