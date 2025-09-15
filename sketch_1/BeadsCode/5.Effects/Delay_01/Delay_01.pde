// Delay_01.pde
// This is an extension of Frequency_Modulation_03.pde

// this example creates a simple FM synthesizer and adds a 400ms delay

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;

// our envelope and gain objects
Envelope gainEnvelope;
Gain synthGain;

// our delay objects
TapIn delayIn;
TapOut delayOut;
Gain delayGain;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create the modulator, this WavePlayer will control the frequency of the carrier
  modulatorFrequency = new Glide(ac, 20, 30);
  modulator = new WavePlayer(ac, modulatorFrequency, Buffer.SINE);

  // create a custom frequency modulation function
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate frequency range
      return (x[0] * 100.0) + mouseY;
    }
  };

  // create a second WavePlayer, control the frequency with the function created above
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);

  gainEnvelope = new Envelope(ac, 0.0); // create the envelope object that will control the gain
  synthGain = new Gain(ac, 1, gainEnvelope); // create a Gain object, connect it to the gain envelope
  synthGain.addInput(carrier); // connect the carrier to the Gain input

  // set up our delay
  delayIn = new TapIn(ac, 2000); // create the delay input - the second parameter sets the maximum delay time in milliseconds
  delayIn.addInput(synthGain); // connect the synthesizer to the delay
  delayOut = new TapOut(ac, delayIn, 500.0); // create the delay output - the final parameter is the length of the initial delay time in milliseconds
  delayGain = new Gain(ac, 1, 0.50); // the gain for our delay
  delayGain.addInput(delayOut); // connect the delay output to the gain
  
  // to feed the delay back into itself, simply uncomment this line
  //delayIn.addInput(delayGain);
  
  ac.out.addInput(synthGain); // connect the Gain output to the AudioContext
  ac.out.addInput(delayGain); // connect the delay output to the AudioContext
  ac.start(); // start audio processing
  
  background(0); // set the background to black
  text("Click me to demonstrate delay!", 100, 100); // tell the user what to do!
}

void draw()
{
  modulatorFrequency.setValue(mouseX); // set the modulator frequency
}

// this routine is triggered whenever a mouse button is pressed
void mousePressed()
{
  // when the mouse button is pressed, at a 50ms attack segment to the envelope
  // and a 300 ms decay segment to the envelope
  gainEnvelope.addSegment(0.7, 50); // over 50 ms rise to 0.8
  gainEnvelope.addSegment(0.0, 300); // over 300 ms return to 0.0
}
