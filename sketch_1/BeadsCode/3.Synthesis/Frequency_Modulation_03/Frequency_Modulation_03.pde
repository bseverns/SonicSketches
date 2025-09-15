// Frequency_Modulation_03.pde

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;

// our envelope and gain objects
Envelope gainEnvelope;
Gain synthGain;

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
  
  ac.out.addInput(synthGain); // connect the Gain output to the AudioContext
  
  ac.start(); // start audio processing
  
  background(0); // set the background to black
  text("Click to trigger the gain envelope.", 100, 120); // tell the user what to do!
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
  gainEnvelope.addSegment(0.8, 50); // over 50 ms rise to 0.8
  gainEnvelope.addSegment(0.0, 300); // over 300 ms return to 0.0
}
