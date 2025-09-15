// WaveShaper_01.pde

// this example demonstrates a WaveShaper, which maps an incoming signal onto a specified wave shape
// you can specify wave shape using an array of floats, or by using a short audio file
// in this example we use an array of floats

import beads.*;

AudioContext ac;

String sourceFile; // this will hold the path to our audio file
SamplePlayer sp; // the SamplePlayer class will be used to play the audio file

// standard gain objects
Gain g;
Glide gainValue;

WaveShaper ws; // our WaveShaper unit generator

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

  // this wave shape more or less maximizes the drum loop
  //float[] WaveShape1 = {0.9, 0.9, 0.9, 0.9, 0.9, 0.0, -0.9, -0.9, -0.9, -0.9, -0.9}; // create the array that will be indexed by the WaveShaper
  
  // this wave shape applies a strange-sounding distortion
  float[] WaveShape1 = {0.0, 0.9, 0.1, 0.9, -0.9, 0.0, -0.9, 0.9, -0.3, -0.9, -0.5}; // create the array that will be indexed by the WaveShaper
  
  // this WaveShape adds a bit-crush type distortion effect to a sound
  //float[] WaveShape1 = {0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.0, -0.9, -0.9, -0.9, -0.9, -0.9, -0.9, -0.9, -0.9, -0.9, -0.9};
  //ws.setPreGain(4.0);
  //ws.setPostGain(4.0);
  
  ws = new WaveShaper(ac, WaveShape1); // instantiate the WaveShaper
  ws.addInput(g); // connect the gain to the WaveShaper


  ac.out.addInput(ws); // connect the WaveShaper to the AudioContext
  ac.start(); // begin audio processing
  
  background(0); // draw a black background
  text("Click to hear a WaveShaper in action.", 50, 50); // tell the user what to do
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










