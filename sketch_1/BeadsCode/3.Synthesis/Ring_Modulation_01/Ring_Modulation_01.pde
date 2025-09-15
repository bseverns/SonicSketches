// Ring_Modulation_01.pde

import beads.*; // import the beads library
AudioContext ac; // declare our AudioContext

// declare our unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;
Glide carrierFrequency;

Gain g; // our master gain

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create the modulator
  modulatorFrequency = new Glide(ac, 20, 30);
  modulator = new WavePlayer(ac, modulatorFrequency, Buffer.SINE);
  
  // create the carrier
  carrierFrequency = new Glide(ac, 20, 30);
  carrier = new WavePlayer(ac, carrierFrequency, Buffer.SINE);

  // a custom function for Ring Modulation
  // Remember, Ring Modulation = Modulator[t] * Carrier[t]
  Function ringModulation = new Function(carrier, modulator)
  {
    public float calculate() {
      // multiply the value of modulator by the value of the carrier
      return x[0] * x[1];
    }
  };

  g = new Gain(ac, 1, 0.5); // create a Gain object to make sure we don't peak

  // connect the ring modulation to the Gain input
  // IMPORTANT: Notice that a custom funtion can be used just like a UGen! This is very powerful!
  g.addInput(ringModulation);
  
  ac.out.addInput(g); // connect the Gain output to the AudioContext
  
  ac.start(); // start audio processing
}

void draw()
{
  // set the freqiencies of the carrier and the modulator based on the mouse position
  carrierFrequency.setValue(mouseY);
  modulatorFrequency.setValue(mouseX);
}
