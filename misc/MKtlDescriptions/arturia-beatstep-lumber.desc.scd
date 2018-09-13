(
deviceName: "Arturia BeatStep",
protocol: \midi,
deviceType: \multiController,
elementTypes: [\encoder, \button],
status: (
	linux: "unknown",
	osx: "tested and working. 2015-03-15, adc",
	win: "unknown"),

idInfo: "Arturia BeatStep",

deviceInfo: (
	vendorURI: "https://www.arturia.com/products/hybrid-synths/beatstep",
	manualURI: "http://downloads.arturia.com/products/beatstep/manual/BeatStep_Manual_1_0_1_EN.pdf",
	// description: "",
	features: [
		"16 drum pads with velocity and polyphonic aftertouch",
		"16 rotary encoders; supporting absolute and dec/inc mode",
		"1  BIG rotary encoder; supporting absolute and dec/inc mode",
		"2  Buttons: play, pause, that send MMC by default",
	],
	notes:
	"",
	longName: "Arturia Beatstep (CC pads custom)."

),

specs: (midiCCrel_64_22: [42, 86, \lin, 1].asSpec), // absolute maxima with fast accel.

elementsDesc: (
	elements: (0..15).collect { |chan, i|
		(
			shared: (midiChan: chan, page: i),


			elements: [
				(
					key: \stop,
					shared: (elementType: 'button', midiNum: 1, spec: \midiBut),
					elements: [
						(
							key: \on, midiMsgType: 'noteOn',
							style: (row: 2, column: 0, height: 0.5, showLabel: true)
						),
						(
							key: \off, midiMsgType: 'noteOff',
							style: (row: 2.5, column: 0, height: 0.5, showLabel: true)
						)
					],
				),
				(
					key: \play,
					shared: (elementType: 'button', midiNum: 2, spec: \midiBut),
					elements: [
						(
							key: \on, midiMsgType: 'noteOn',
							style: (row: 2.0, column: 1, height: 0.5, showLabel: true)
						),
						(
							key: \off, midiMsgType: 'noteOff',
							style: (row: 2.5, column: 1, height: 0.5, showLabel: true)
						)
					],
				),

				(
					key: \pad,
                    shared: (elementType: 'pad', spec: 'midiVel'),
                    elements: (0x70..0x7F).collect { |num,i|
						(
							shared: (midiNum: num, ioType: \inout),
							elements: [
								(
									key: \on, midiMsgType: \noteOn,
									style: (row: (i div: 8 * 2 + 2), column: i % 8 + 2,
										height: 0.5, showLabel: true)
								),
								(
									key: \off, midiMsgType: \noteOff,
									style: (row: (i div: 8 * 2 + 2.5), column: i % 8 + 2,
										height: 0.5, showLabel: true)
								),
								(
									key: \touch, midiMsgType: \polytouch,
									style: (row: (i div: 8 * 2 + 3), column: i % 8 + 2,
										height: 0.5, showLabel: true)
								)
							]
						)
					}
				),
				(
					// relative - inc/dec !
					key: \kn,
					shared: (midiMsgType: 'cc', elementType: 'encoder',
						spec: 'midiCCrel_64_22'),
                    elements: (0x20..0x2F).flat.collect { |num, i|
						( midiNum:  num,
							style: (row: (i div: 8), column: i % 8 + 2, showLabel: true)
						)
					}

				),
				(
					// relative - inc/dec !
					key: \bigKnob, midiMsgType: 'cc', elementType: 'encoder',
					spec: 'midiCCrel_64_22', // [56, 72, \lin, 1].asSpec,
					midiNum: 0x30,  // big knob
					style: (row: 0, column: 0, height: 2, showLabel: true)
				)
			]
		)
	}
)
)