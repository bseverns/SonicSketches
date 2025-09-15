// Custom_Beads_01.pde
// this program demonstrates how to create and use custom Beads objects in Processing

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext

// declare our unit generators
WavePlayer wavetableSynthesizer;
Glide frequencyGlide;

// our envelope and gain objects
Envelope gainEnvelope;
Gain synthGain;

void setup()
{
  size(800, 600);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create our Buffer
  Buffer wavetable = new DiscreteSummationBuffer().generateBuffer(4096, 15, 0.8);

  frequencyGlide = new Glide(ac, 200, 10);
  wavetableSynthesizer = new WavePlayer(ac, frequencyGlide, new DiscreteSummationBuffer().generateBuffer(44100));

  gainEnvelope = new Envelope(ac, 0.0); // create the envelope object that will control the gain
  synthGain = new Gain(ac, 1, gainEnvelope); // create a Gain object, connect it to the gain envelope
  synthGain.addInput(wavetableSynthesizer); // connect the synthesizer to the gain
  ac.out.addInput(synthGain); // connect the Gain output to the AudioContext

  ac.start(); // start audio processing
  
  background(0); // set the background to black
  drawBuffer(wavetable.buf);
  text("Click to trigger the wavetable synthesizer.", 100, 120); // tell the user what to do!
}

void draw()
{
  frequencyGlide.setValue(mouseX); // set the fundamental frequency
}

// this routine is triggered whenever a mouse button is pressed
void mousePressed()
{
  // when the mouse button is pressed, at a 50ms attack segment to the envelope
  // and a 300 ms decay segment to the envelope
  gainEnvelope.addSegment(0.8, 50); // over 50 ms rise to 0.8
  gainEnvelope.addSegment(0.0, 200); // over 300 ms return to 0.0
}

// draw a buffer on screen
void drawBuffer(float[] buffer)
{
  float currentIndex = 0.0;
  float stepSize = buffer.length / (float)width;
  
  color c = color(255, 0, 0);
  stroke(c);

  for( int i = 0; i < width; i++ )
  {
    set(i, (int)(buffer[(int)currentIndex] * (height / 2.0)) + (int)(height / 2.0), c);
    currentIndex += stepSize;
  }
}
