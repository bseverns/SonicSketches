// Filter_02.pde

// This is an extension of Frequency_Modulation_03.pde
// this adds a low pass filter controlled by an envelope

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our FM Synthesis unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;

// our gain and gain envelope
Envelope gainEnvelope;
Gain synthGain;

// our filter and filter envelope
LPRezFilter lowPassFilter;
Envelope filterCutoffEnvelope;

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
      return (x[0] * 500.0) + mouseY;
    }
  };

  // create a second WavePlayer, control the frequency with the function created above
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);

  // set up our low pass filter
  filterCutoffEnvelope = new Envelope(ac, 00.0); // create the envelope that will control the cutoff frequency
  lowPassFilter = new LPRezFilter(ac, filterCutoffEnvelope, 0.97); // create the LP Rez filter
  lowPassFilter.addInput(carrier); // connect the synthesizer to the filter
  
  // set up our gain envelope objects
  gainEnvelope = new Envelope(ac, 0.0);
  synthGain = new Gain(ac, 1, gainEnvelope); // create a Gain object, connect it to the gain envelope
  synthGain.addInput(lowPassFilter); // connect the carrier to the Gain input
  
  ac.out.addInput(synthGain); // connect the filter output to the AudioContext
  ac.start(); // start audio processing
  
  background(0); // set the background to black
  text("Click me to demonstrate a filter sweep!", 100, 100); // tell the user what to do!
}

void draw()
{
  modulatorFrequency.setValue(mouseX); // set the modulator frequency
}

// this routine is triggered whenever a mouse button is pressed
void mousePressed()
{
  // add some points to the gain envelope ... make it look a bit like this: /-\
  gainEnvelope.addSegment(0.7, 500);
  gainEnvelope.addSegment(0.7, 1000);
  gainEnvelope.addSegment(0.0, 500);
  
  // add points to the filter envelope sweep the frequency up to 500Hz, then back down to 0
  filterCutoffEnvelope.addSegment(800.0, 1000);
  filterCutoffEnvelope.addSegment(00.0, 1000);
}
