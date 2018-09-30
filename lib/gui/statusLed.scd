p = Proto {

	~radius = 8;

	~active = false;
	~states = IdentityDictionary[
		\active -> Color.green,
		\inactive -> Color.gray,
	];

	~color = ~states[\inactive];

	~makeGUI = { |parent, bounds|
		var pixels = ~radius * 2;
		bounds = bounds ?? { Rect(0, 0, pixels, pixels) };
		~view = UserView().fixedSize_(Size(pixels, pixels)).drawFunc_({
			Pen.fillColor = ~color;
			Pen.fillOval(Rect(0, 0, pixels, pixels).center_(bounds.center));
		}.inEnvir);

	};

	~setState = { |state|
		~states[state] !? { |c|
			~color = c;
		};
		{ ~view !? { ~view.refresh } }.inEnvir.defer;
	};

	~setActive = { |active=true|
		if (active) {
			~color = ~states[\active];
		} {
			~color = ~states[\inactive];
		};
		{ ~view !? { ~view.refresh } }.inEnvir.defer;
	};

	~setColor = { |color|
		if (color.isKindOf(Color)) {
			~color = color;
		} {
			~color = Color.tryPerform(color) ? ~color;
		};
		{ ~view !? { ~view.refresh } }.inEnvir.defer;
	}


}
