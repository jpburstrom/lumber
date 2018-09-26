(
~belaMPU.free;

~belaMPU = Proto({

    var bounds = [[999, 999, 999],[-999, -999, -999]];

    ~synth = nil;
    ~func = nil;


    ~accel = nil;

    //Hardcoded bounds
    ~accelBounds = [ [ -1.0179443359375, -1.0663452148438, -0.92694091796875 ], [ 1.1795654296875, 1.1810913085938, 1.1517944335938 ] ];
    ~gyro = nil;
    ~gyroBounds = [ [ -178.67279052734, -180.89294433594, -80.863952636719 ], [ 1.1795654296875, 1.1810913085938, 1.1517944335938 ] ];
    ~mag = nil;
    ~magBounds = [ [ -159.50927734375, -311.07061767578, -539.07739257812 ], [ 761.70159912109, 553.81359863281, 317.91744995117 ] ];
    ~orientation = nil;
    ~orientationBounds = [ [ -88.512725830078, -179.69926452637, 0.10358381271362 ], [ 63.236881256104, 177.6607208252, 359.60214233398 ] ];

    ~grtAddr = NetAddr("localhost", 5000);
    ~grtSend = (accel: false, gyro: false, mag: false, orientation: false);

    //Currently unused
    ~specs = (
        default: ControlSpec(-1, 1);
    );

    // ~belaMPU.orientationBounds

    //Run synth and OSCfunc,storing sensor data
    ~run = { |serverName=\bela|
		var server = Server.named[serverName];
        ~synth.free;
        ~synth = SynthDef(\belaToOSC, {
            var out;

			if (serverName == \bela)  {
				out = ([\accelKr, \gyroKr, \magKr,
					\orientationKr].collect { |sym|
					LPF.kr(MPU.perform(sym), 5);
				}).flatten;
			} {
				out = DC.ar ! 12
			};

            SendReply.kr(Impulse.kr(33), '/mpu', out);
		}).play(server);

        ~func.free;

        ~func = OSCFunc({ |args|
            // args.postln;

            var send;

            args = args[3..].clump(3);


            // args.postln;
            ~accel = args[0];
            ~accelBounds = [~accel.min(~accelBounds[0]), ~accel.max(~accelBounds[1])];
            ~gyro = args[1];
            ~gyroBounds = [~gyro.min(~gyroBounds[0]), ~accel.max(~gyroBounds[1])];
            ~mag = args[2];
            ~magBounds = [~mag.min(~magBounds[0]), ~mag.max(~magBounds[1])];
            ~orientation = args[3];
            ~orientationBounds = [~orientation.min(~orientationBounds[0]), ~orientation.max(~orientationBounds[1])];

            #[accel, gyro, mag, orientation].do { |key|
                if (~grtSend[key]) {
                    send = send.addAll(currentEnvironment[key]);
                };
            };

            send !? {
                ~grtAddr.sendMsg("/Data", *send);
            }

        }.inEnvir, '/mpu', server.notify_(true).addr)

    };


    //Stop synth, osc and ui updates
    ~stop = {
        ~func.free;
        ~synth.free;
        ~task.stop;
    };

    ~free = {
        ~stop.value;
        ~win !? { ~win.onClose = nil; ~win.close };
        ~grtAddr.free;
    };

    //Make gui
    //Start task which updates gui
    ~makeGui = {

        var env = currentEnvironment;

        var updateGUI = FunctionList();

        var f = (
            header: { |self, label|
                StaticText().string_(label).font_(Font("Source Code Pro")).align_(\center)
            },

            //Numbers with resettable min/max values
            numbersXYZ: { |self, key, task|
                var data;
                var view = View().layout_(GridLayout.columns(
                    [NumberBox().enabled_(false), StaticText().string_("X"), task !? {
                        //Reset button currently out of order
                        [Button().states_([["Reset"]]).enabled_(false), columns:3] }],
                    [NumberBox().enabled_(false), StaticText().string_("Y")],
                    [NumberBox().enabled_(false), StaticText().string_("Z")]
                ));

                var boxes = view.children(NumberBox).postln;
                data = {
                    switch (task,
                    \min, {
                        currentEnvironment[(key ++ "Bounds").asSymbol][0]
                    },
                    \max, {
                        currentEnvironment[(key ++ "Bounds").asSymbol][1]
                    },
                    {
                        currentEnvironment[key]
                    }
                )
                }.inEnvir;

                updateGUI.addFunc({
                    data.value.do { |val, i| boxes[i].value = val }
                }.inEnvir);

                view
            },

            sendToGRT: { |self, key|
                View().layout_(HLayout(
                    StaticText().string_("Send to GRT"),
                    CheckBox().action_ { |box|

                        env.grtSend[key] = box.value;


                    }
                ));
            },

            //Create slider2d + slider
            //Also show raw values, min and max
            sensor3d: { |self, label, key, specArray|

                var view = View().layout_(VLayout(
                    self.header(label),
                    Slider2D(),
                    Slider().orientation_(\horizontal),
                    self.header("RawValues"),
                    self.numbersXYZ(key),
                    self.header("Min"),
                    self.numbersXYZ(key, \min),
                    self.header("Max"),
                    self.numbersXYZ(key, \max),
                    self.sendToGRT(key),
                    nil
                ));


                specArray = (specArray ?? ~specs[key] ?? ~specs.default).asArray;

                updateGUI.addFunc({
                    var bounds = currentEnvironment[(key ++ "Bounds").asSymbol];
                    currentEnvironment[key] !? {
                        view.children[1].y =
                        currentEnvironment[key][0].linlin(bounds[0][0], bounds[1][0], 0, 1);
                        view.children[1].x =
                            currentEnvironment[key][1].linlin(bounds[0][1], bounds[1][1], 0, 1);
                        view.children[2].value =
                                currentEnvironment[key][2].linlin(bounds[0][2], bounds[1][2], 0, 1);
                    };
                }.inEnvir);

                view

            }

        );

        ~win = Window.new("Bela Controls", Rect(0,0,800,580).center_( Window.availableBounds.center )).front.layout_(HLayout(
            f.sensor3d("Acceleration", \accel),
            f.sensor3d("Gyro", \gyro),
            f.sensor3d("Mag", \mag),
            f.sensor3d("Orientation", \orientation),
            nil
        ));

        ~task = Routine({
            inf.do {
                updateGUI.value;
                0.033.wait;
            }
        }).play(AppClock);

        ~win.onClose = {
            ~task.stop;
            ~win = nil;
        }.inEnvir;

    };




});
~belaMPU.run(\bela);
~belaMPU.makeGui;
)

