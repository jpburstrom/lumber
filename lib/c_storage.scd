Proto({

	~storagePath = "../data/".resolveRelative;
    ~objects = ();

    //Register object at key
    //Objects should implement getParams and setParams
    //getParams is called with \storage as argument
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


	//Save object(s). Both key and path is optional.
	//If key is not provided, save all keys
	//If path is not provided, use default path
    ~save = { |path, keys|
		var obj, p;
		keys = ~prCheckKeyArg.(keys);
		p = path ?? { ~prMakeStoragePath.value; };
		if (File.exists(p)) {
			obj = ~prRead.(p);
		} {
			obj = ();
		};
		keys.do { |k|
			obj[k] = ~objects[k].getParams(\storage);
		};
		~prWrite.(obj, p);
	};


	//Load object(s). Both key and path is optional (see ~save)
    ~load = { |path, keys|
        var obj, p;
		keys = ~prCheckKeyArg.(keys);
		p = path ?? { ~prMakeStoragePath.value };
		if (File.exists(p)) {
			obj = ~prRead.(p);
			keys.do { |k|
				if (~objects[k].notNil) {
					~objects[k].setParams(obj[k]);
				}
			}
		} {
			"Storage file doesn't exist at %".format(p).error;
		}
    };

    ~backup = { |keys|
        var dir = ~storagePath +/+ "backup";
		keys = ~prCheckKeyArg.(keys);
        File.mkdir(dir);
		keys.do { |key|
			var storagePath = ~prMakeStoragePath.(key);
			var file = storagePath.basename.splitext;
			File.copy(storagePath, dir +/+ file[0] ++ Date.getDate.stamp ++ "." ++ file[1]);
		}
    };

	//Check argument, return array of keys
	~prCheckKeyArg = { |key|
		if (key.isNil) {
			key = ~objects.keys
		} {
			key.asArray
		}
	};

	~prMakeStoragePath = { |suffix|
		if (suffix.isNil) {
			~storagePath +/+ "storage.zarchive";
		} {
			~storagePath +/+ "storage-%.zarchive".format(suffix);
		}
	};

    ~prWrite = { |obj, path|
        var z = ZArchive.write(path);
        z.writeItem(obj);
        z.writeClose;
    };

    ~prRead = { |path|
        var things;
        var z = ZArchive.read(path);
        things = z.readItem;
        z.close;
        things;

    }


});
