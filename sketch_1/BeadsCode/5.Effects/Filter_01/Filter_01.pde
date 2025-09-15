// Filter_01.pde

import beads.*;

AudioContext ac;

String sourceFile; // this will hold the path to our audio file
SamplePlayer sp; // the SamplePlayer class will be used to play the audio file

// standard gain objects
Gain g;
Glide gainValue;

OnePoleFilter filter1; // this is our filter unit generator

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

  filter1 = new OnePoleFilter(ac, 200.0); // set up our new filter with a cutoff frequency of 200Hz
  filter1.addInput(sp); // connect the SamplePlayer to the filter

  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 20);
  g = new Gain(ac, 1, gainValue);
  g.addInput(filter1); // connect the filter to the gain

  ac.out.addInput(g); // connect the Gain to the AudioContext

  ac.start(); // begin audio processing
  
  background(0); // draw a black background
  text("Left click to hear a low pass filter in effect.", 50, 50); // tell the user what to do
  text("Right click to hear the original loop.", 50, 70); // tell the user what to do
}

// although we're not drawing to the screen, we need to have a draw function
// in order to wait for mousePressed events
void draw(){}

// this routine is called whenever a mouse button is pressed on the Processing sketch
void mousePressed()
{
  if( mouseButton == LEFT )
  {
    filter1.setFrequency(200.0); // set the filter frequency to cutoff at 200Hz
    gainValue.setValue((float)mouseX/(float)width); // set the gain based on mouse position
    sp.setToLoopStart(); // move the playback pointer to the first loop point (0.0)
    sp.start(); // play the audio file
  }
  // if the user right-clicks, then play the sound without a filter
  else
  {
    filter1.setFrequency(20000.0); // set the filter frequency to cutoff at 20kHz -> the top of human hearing
    gainValue.setValue((float)mouseX/(float)width); // set the gain based on mouse position
    sp.setToLoopStart(); // move the playback pointer to the first loop point (0.0)
    sp.start(); // play the audio file
  }
}










