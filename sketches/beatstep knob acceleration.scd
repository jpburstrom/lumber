//Input
~art = MKtl('art', "*beatstep-rel-16");

~cv = { CV([0,100]) } ! 8;
~win = Window().layout_(HLayout()).front;
~sl = { Slider(~win) } ! 8;


(
~cv.do { |cv, i|
    var time = 0;
    var timeDelta, acc, delta;

    cv.connect(~sl[i]);

    ~art.elAt(\1, \kn, i).action = { |el|
        //Get delta, and multiply with magic factor
        delta = (el.value - 0.5) * 0.4;
        //Get previous time diff
        timeDelta = thisThread.seconds - time;
        time = thisThread.seconds;

        //Filter out really small timeDeltas
        //If less than 0.003, it's probably a sensor glitch
        if (timeDelta > 0.003) {
            //Get a decent acceleration value
            acc = timeDelta.linexp(0.003, 0.5, 2, 0.01);
            cv.input_(cv.input + (delta * acc));
        }
    }
}
)
