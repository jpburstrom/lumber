/**
 * Please note that support for SuperCollider on Bela is still experimental,
 * so feel free to report issues here: https://github.com/sensestage/supercollider/issues
 *
 * This script simply starts scsynth, which then waits for messages.
 * Use the code in remote-examples to interact with the board from
 * the SuperCollider IDE running on the host.
 */

// NOTE: the settings provided here may not be the most sensible in terms of gains.

s = Server.default;

s.options.numAnalogInChannels = 8;
s.options.numAnalogOutChannels = 8;
s.options.numDigitalChannels = 16;
s.options.maxLogins = 64;

s.options.pgaGainLeft = 10;     // sets the pga gain of the left channel to 4 dB
s.options.pgaGainRight = 0;    // sets the pga gain of the right channel to 5 dB
s.options.headphoneLevel = 0; // sets the headphone level to -8 dB
s.options.speakerMuted = 1;    // the speakers are muted 
s.options.dacLevel = 0;       // sets the gain of the dac to -5 dB
s.options.adcLevel = 0;       // sets the gain of the adc to -3 dB
s.options.numMultiplexChannels = 0; // do not enable multiplexer channels
s.options.belaPRU = 0;         // select the PRU on which Bela audio will run

s.options.blockSize = 16;
s.options.hardwareBufferSize = 16;
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;

s.options.postln;
/*
s.waitForBoot {
	1.wait;
	{ SinOsc.ar * Env.perc.ar(2) }.play;
}
*/
s.boot;



