// Frequency_Modulation_02.pde

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;

Gain g;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create the modulator, this WavePlayer will control the frequency of the carrier
  modulatorFrequency = new Glide(ac, 20, 30);
  modulator = new WavePlayer(ac, modulatorFrequency, Buffer.SINE);

  // this is a custom function
  // custom functions are a bit like custom Unit Generators (custom Beads)
  // but they only override the calculate function
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      // return x[0], which is the original value of the modulator signal (a sine wave)
      // multiplied by 200.0 to make the sine vary between -200 and 200
      // the number 200 here is called the "Modulation Index"
      // the higher the Modulation Index, the louder the sidebands
      // then add mouseY, so that it varies from mouseY - 200 to mouseY + 200
      return (x[0] * 200.0) + mouseY;
    }
  };

  // create a second WavePlayer, control the frequency with the function created above
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);

  g = new Gain(ac, 1, 0.5); // create a Gain object to make sure we don't peak

  g.addInput(carrier); // connect the carrier to the Gain input
  
  ac.out.addInput(g); // connect the Gain output to the AudioContext
  
  ac.start(); // start audio processing
}

void draw()
{
  modulatorFrequency.setValue(mouseX);
}
