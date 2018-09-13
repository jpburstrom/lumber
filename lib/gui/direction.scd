~direction = Proto {

    ~val = 0.0;

    ~makeView = {
        var view = UserView();
        view.drawFunc = { |v|
            var center = v.bounds.extent * 0.5;
            Pen.color = Color.black;
            Pen.addAnnularWedge(center, 1, center.x - 10, (~val * 2pi) - 0.55pi, 0.1pi);
            Pen.fill;
        }.inEnvir;
        view
    };

    ~view = ~makeView.value;

    ~front = { ~view.front };
    ~close = { ~view.close };

    ~value_ = { |val|
        ~val = val;
        if (~view.isClosed.not) {
            ~view.refresh;
        };
        currentEnvironment.changed(\value, val)
    };

    ~value = { ~val };


};

~direction.makeView.front
~direction.close;

~direction.value = 0.1

