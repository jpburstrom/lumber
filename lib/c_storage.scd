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
    ~save = { |keys, path|
		var obj, p;
		keys = ~prCheckKeyArg.(keys);
		keys.do { |k|
			p = path ?? { ~prMakeStoragePath.value(k) };
			obj = ~objects[k].getParams(\storage);
			~prWrite.(obj, p);
		}
	};


	//Load object(s). Both key and path is optional (see ~save)
    ~load = { |keys, path|
        var obj;
		keys = ~prCheckKeyArg.(keys);

		keys.do { |k|
			path ?? { path = ~prMakeStoragePath.value(k) };
			if (File.exists(path)) {
				obj = ~prRead.(path);
				if (~objects[k].notNil) {
					~objects[k].setParams(obj);
				}
			} {
				"Storage file doesn't exist at %".format(path).error;
			}
		};

		~objects;

    };

    /* Move these to a gui place
    ~loadDialog = {
        Dialog.openPanel({ |p|
            ~load.value(p);
            //TODO later think about how to load everything more smoothly
            ~loadToGroup.(\snapshots, 0);
            ~loadToGroup.(\presets, params.meta.target.value.asInt);

        }.inEnvir);
    };

    ~saveDialog = {
        Dialog.savePanel(~save.inEnvir);
    };
    */

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

	~prMakeStoragePath = { |key|
		~storagePath +/+ "storage-%.zarchive".format(key);
	};

    ~prWrite = { |obj, path|
        z = ZArchive.write(path);
        z.writeItem(obj);
        z.writeClose;
    };

    ~prRead = { |path|
        var things;
        z = ZArchive.read(path);
        things = z.readItem;
        z.close;
        things;

    }


});

/*
x.register(\macros, q.macros)
x.objects
x.save("/tmp/asdasd")
x.load
x.backup
*/
