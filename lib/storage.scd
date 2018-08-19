Proto({

    ~storagePath = "../data/storage.zarchive".resolveRelative;
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


    ~save = { |path|
        var obj=();
        path ?? { path = ~storagePath };
        ~objects.keysValuesDo { |k, v|
            obj[k] = v.getParams(\storage);
        };
        ~prWrite.(obj, path);
    };


    ~load = { |path|
        var obj;
        path ?? { path = ~storagePath };
        if (File.exists(path)) {
            obj = ~prRead.(path);
            obj.keysValuesDo { |k, v|
                if (~objects[k].notNil) {
                    ~objects[k].setParams(v);
                }
            }
        } {
            "Storage file doesn't exist at %".format(path).error;
        };

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

    ~backup = {
        var dir = ~storagePath.dirname +/+ "backup";
        var file = ~storagePath.basename.splitext;
        File.mkdir(dir);
        File.copy(~storagePath, dir +/+ file[0] ++ Date.getDate.stamp ++ "." ++ file[1]);
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
