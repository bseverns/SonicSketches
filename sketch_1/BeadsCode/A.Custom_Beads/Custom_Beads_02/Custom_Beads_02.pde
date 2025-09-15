// Custom_Beads_02.pde

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
MorphingWavePlayer mwp;
Glide frequencyGlide;
Glide mixGlide;

Gain masterGain;

void setup()
{
  size(800, 600);

  // initialize our AudioContext
  ac = new AudioContext();
  
  frequencyGlide = new Glide(ac, 200, 10);
  mixGlide = new Glide(ac, 0.5, 10);
  mwp = new MorphingWavePlayer(ac, frequencyGlide, Buffer.SINE, Buffer.TRIANGLE);
  mwp.setMix(mixGlide);

  masterGain = new Gain(ac, 1, 0.8); // create a Gain object
  masterGain.addInput(mwp); // connect the DualWavePlayer to the Gain
  ac.out.addInput(masterGain); // connect the Gain output to the AudioContext

  ac.start(); // start audio processing
  
  background(0); // set the background to black
  text("Move the mouse to set the frequency and the mix of the MorphingWavePlayer.", 100, 120); // tell the user what to do!
}

void draw()
{
  frequencyGlide.setValue(mouseX);
  mixGlide.setValue(mouseY/(float)height);
}


