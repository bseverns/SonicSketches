// Panner_01.pde

// this example demonstrates how to use the Panner object

import beads.*;

AudioContext ac;

String sourceFile; // this will hold the path to our audio file
SamplePlayer sp; // the SamplePlayer class will be used to play the audio file

// standard gain objects
Gain g;
Glide gainValue;

Panner p; // our Panner will control the stereo placement of the sound
WavePlayer panLFO; // a Low-Frequency-Oscillator for the panner

void setup()
{
  size(800, 600);
  
  ac = new AudioContext(); // create our AudioContext

  sourceFile = sketchPath("") + "Drum_Loop_01.wav";

  // Try/Catch blocks will inform us if the file can't be found
  try {  
    // initialize our SamplePlayer, loading the file indicated by the sourceFile string
    sp = new SamplePlayer(ac, new Sample(sourceFile));
   }
  catch(Exception e)
  {
    // if there is an error, show an error message (at the bottom of the processing window)
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }
  
  // we would like to play the sample multiple times, so we set KillOnEnd to false
  sp.setKillOnEnd(false);

  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 20);
  g = new Gain(ac, 1, gainValue);
  g.addInput(sp); // connect the filter to the gain

  // in this block of code, we create an LFO - a Low Frequency Oscillator - and connect it to our panner
  // a low frequency oscillator is just like any other oscillator EXCEPT the frequency is subaudible - under 20Hz
  // here, the LFO controls pan position
  panLFO = new WavePlayer(ac, 0.33, Buffer.SINE); // initialize the LFO at a frequency of 0.33Hz
  p = new Panner(ac, panLFO); // initialize the panner. to set a constant pan position, merely replace "panLFO" with a number between -1.0 (LEFT) and 1.0 (RIGHT)
  p.addInput(g); // connect the gain to the panner

  ac.out.addInput(p); // connect the Panner to the AudioContext
  ac.start(); // begin audio processing
  
  background(0); // draw a black background
  text("Click to hear a Panner object connected to an LFO.", 50, 50); // tell the user what to do
}

// although we're not drawing to the screen, we need to have a draw function
// in order to wait for mousePressed events
void draw(){}

// this routine is called whenever a mouse button is pressed on the Processing sketch
void mousePressed()
{
    gainValue.setValue((float)mouseX/(float)width); // set the gain based on mouse position
    sp.setToLoopStart(); // move the playback pointer to the first loop point (0.0)
    sp.start(); // play the audio file
}










