// Panner_01.pde

// this example demonstrates how to use the Panner object

import beads.*;

AudioContext ac;

String sourceFile; // this will hold the path to our audio file
SamplePlayer sp; // the SamplePlayer class will be used to play the audio file

// standard gain objects
Gain g;
Glide gainValue;

Reverb r; // our Reverberation unit generator

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

  r = new Reverb(ac, 1); // create a new reverb with a single output channel
  r.setSize(0.7); // set the room size (between 0 and 1) 0.5 is the default
  r.setDamping(0.5); // set the damping (between 0 and 1) - the higher the dampening, the fewer resonant high frequencies
  // You can also control a Reverb's early reflections and late reverb
  // to do so, use r.setEarlyReflectionsLevel(0-1); or r.setLateReverbLevel(0-1);
  r.addInput(g); // connect the gain to the reverb


  ac.out.addInput(r); // connect the Reverb to the AudioContext
  
  // remember, the reverb unit only outputs a reverberated signal
  // so if we want to hear the dry drums as well, then we will also need to connect
  // the SamplePlayer to the output
  ac.out.addInput(g); // connect the sp gain to the output
  
  ac.start(); // begin audio processing
  
  background(0); // draw a black background
  text("Click to hear a Reverb object in action.", 50, 50); // tell the user what to do
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










