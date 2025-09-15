// Frequency_Modulation_01.pde

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
WavePlayer modulator;
WavePlayer carrier;

Gain g;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create the modulator, this WavePlayer will control the frequency of the carrier
  modulator = new WavePlayer(ac, 40, Buffer.SINE);

  // this is a custom function
  // custom functions are a bit like custom Unit Generators (custom Beads)
  // but they only override the calculate function
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      // return x[0], which is the original value of the modulator signal (a sine wave)
      // multiplied by 50 to make the sine vary between -50 and 50
      // then add 200, so that it varies from 150 to 250
      return (x[0] * 50.0) + 200.0;
      //return x[0] * mouseX + mouseY;
    }
  };

  // create a second WavePlayer, but this time, control the frequency with the function created above
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);

  // create a Gain object to make sure we don't peak
  g = new Gain(ac, 1, 0.5);

  // connect the carrier to the Gain input
  g.addInput(carrier);
  
  // connect the Gain output to the AudioContext
  ac.out.addInput(g);
  
  // start audio processing
  ac.start();
}

