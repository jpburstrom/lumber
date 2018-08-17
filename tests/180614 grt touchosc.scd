~grt.sendMsg("/TrainingClassLabel", 2.5)

//GUI
(
~grt = NetAddr("localhost", 5000);
~touchOsc = NetAddr("myfone.local", 9000);
~win = Window.new("Bela ♥ MPU9250 ♥ GRT").front.layout_(VLayout(
   nil,
    //
    HLayout(
        VLayout(Slider(), StaticText().string_("0.0").align_(\center).font_(Font.monospace), StaticText().string_("Prediction").align_(\center)), nil)
));

)

(
~sendAccelerometer = false;
~sendPrediction = false;
~touchOsc.sendMsg("/sendAccelerometer", 0.0);
OSCdef(\grtTargetVector, { |args|
    var val = args[1].round(0.01);
     ~grt.sendMsg("/TargetVector", val);
    ~touchOsc.sendMsg("/Regression/TargetVectorLabel", val)
}, '/Regression/TargetVector');
OSCdef(\grtTrainingClassLabel, { |args|
    var val = args[1].round(1);
    // val.postln;
    ~grt.sendMsg("/TrainingClassLabel", val);
    ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/Classification/TrainingClassLabel');
OSCdef(\grtClear, { |args|
    var val = args[1];
    // val.postln;
    ~grt.sendMsg("/ClearTrainingDataset");
    ~touchOsc.sendMsg("/Predict", 0);
    ~touchOsc.sendMsg("/Record", 0);
    // ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/ClearDataset');
OSCdef(\grtRecord, { |args|
    var val = args[1];
    // val.postln;
    ~grt.sendMsg("/Record", val);
    if (val == 1) {
        ~sendPrediction = false;
        ~touchOsc.sendMsg("/Predict", 0);
    }
    // ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/Record');
OSCdef(\grtTrain, { |args|
     var val = args[1].asBoolean;
    // val.postln;
    if (val) {
        ~grt.sendMsg("/Record", 0);
        ~grt.sendMsg("/Train");
        ~touchOsc.sendMsg("/Record", 0);
    } ;

    ~sendPrediction = val.postln;

    // ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/Predict');
OSCdef(\grtSendAccelerometer, { |args|
    var val = args[1].asBoolean;

    ~sendAccelerometer = val;
    // ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/sendAccelerometer');
OSCdef(\grtAccelerometer, { |args|
    // var val = args[1].asBoolean;
    if (~sendAccelerometer) {
        ~grt.sendMsg("/Data", *args[1..]);
    }
    // ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val.asString)
}, '/accxyz');
OSCdef(\grtRegressionFeedback, { |args|
    var val = args[2].round(0.01);
    defer {
        ~win.view.children(Slider)[0].value_(val);
        ~win.view.children(StaticText)[0].string_(val);
    };
    if (~sendPrediction) {
        ~touchOsc.sendMsg("/Regression/TargetVector", val);
        ~touchOsc.sendMsg("/Regression/TargetVectorLabel", val);
    }
}, '/RegressionData', recvPort:5001);

OSCdef(\grtClassificationFeedback, { |args|
    var val = args[2].round(1);
    defer {
    ~win.view.children(Slider)[0].value_(val / 10);
    ~win.view.children(StaticText)[0].string_(val);
    };
    // ~touchOsc.sendMsg("/Regression/TargetVector", val);
    if (~sendPrediction) {
        ~touchOsc.sendMsg("/Classification/TrainingClassLabel", val);
        ~touchOsc.sendMsg("/Classification/TrainingClassLabelLabel", val);
    }

}, '/ClassLabels', recvPort:5001)
)

~touchOsc.sendMsg("/Regression/TrainingClassLabelLabel", 0.2)