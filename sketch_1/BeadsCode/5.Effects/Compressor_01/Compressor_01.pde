// Compressor_01.pde

// this example demonstrates how to use the Compressor object

import beads.*;

AudioContext ac;

String sourceFile; // this will hold the path to our audio file
SamplePlayer sp; // the SamplePlayer class will be used to play the audio file

// standard gain objects
Gain g;
Glide gainValue;

Compressor c; // our Compressor unit generator

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

  // set up our compressor
  c = new Compressor(ac, 1); // create a new compressor with a single output channel
  
  c.setAttack(30); // the attack is how long it takes for compression to ramp up, once the threshold is crossed
  c.setDecay(200); // the decay is how long it takes for compression to trail off, once the threshold is crossed in the opposite direction
  
  // the ratio and the threshold work together to determine how much a signal is squashed
  // the ratio is the NUMERATOR of the compression amount 2.0 = 2:1 = for every two decibels above the threshold, a single decibel will be output
  // the threshold is the loudness at which compression can begin
  
  // Expansion
  //c.setRatio(0.9);
  //c.setThreshold(-16.0);
  
  // Compression
  c.setRatio(4.0);
  c.setThreshold(0.6);
  
  //c.setKnee(0.5); // the knee is an advanced setting that you should leave alone unless you know what you are doing
  
  c.addInput(sp); // connect the SamplePlayer to the compressor

  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 20);
  g = new Gain(ac, 1, gainValue);
  g.addInput(c); // connect the Compressor to the gain

  ac.out.addInput(c); // connect the Compressor to the AudioContext
  ac.start(); // begin audio processing
  
  background(0); // draw a black background
  text("Click to hear the Compressor object in action.", 50, 50); // tell the user what to do
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










