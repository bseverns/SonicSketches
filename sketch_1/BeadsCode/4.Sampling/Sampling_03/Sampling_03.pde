// Sampling_03.pde

// this is a more complex sampler
// clicking somewhere on the window initiates sample playback
// moving the mouse controls the playback rate

import beads.*;

AudioContext ac;

SamplePlayer sp1;

// we can run both SamplePlayers through the same Gain
Gain sampleGain;
Glide gainValue;

Glide rateValue;

void setup()
{
  size(800, 600);
  
  ac = new AudioContext(); // create our AudioContext

  // whenever we load a file, we need to enclose the code in a Try/Catch block
  // Try/Catch blocks will inform us if the file can't be found
  try {  
    // initialize the SamplePlayer
    sp1 = new SamplePlayer(ac, new Sample(sketchPath("") + "Drum_Loop_01.wav"));
   }
  catch(Exception e)
  {
    // if there is an error, show an error message (at the bottom of the processing window)
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }
  
  // note that we want to play the sample multiple times
  sp1.setKillOnEnd(false);
  
  rateValue = new Glide(ac, 1, 30); // initialize our rateValue Glide object
  sp1.setRate(rateValue); // connect it to the SamplePlayer
  
  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 30);
  sampleGain = new Gain(ac, 1, gainValue);
  sampleGain.addInput(sp1);

  ac.out.addInput(sampleGain); // connect the Gain to the AudioContext

  ac.start(); // begin audio processing
  
  background(0); // set the background to black
  stroke(255);
  line(width/2, 0, width/2, height); // draw a line in the middle
  text("Click to begin playback.", 100, 100); // tell the user what to do!
  text("Move the mouse to control playback speed.", 100, 120); // tell the user what to do!
}

// although we're not drawing to the screen, we need to have a draw function
// in order to wait for mousePressed events
void draw()
{
  float halfWidth = width / 2.0;

  gainValue.setValue((float)mouseY / (float)height); // set the gain based on mouse position along the Y-axis
  rateValue.setValue(((float)mouseX - halfWidth)/halfWidth); // set the rate based on mouse position along the X-axis
}

// this routine is called whenever a mouse button is pressed on the Processing sketch
void mousePressed()
{
   // if the left mouse button is clicked, then play the sound
  if( mouseX > width / 2.0 )
  {
    sp1.setPosition(000); // set the start position to the beginning
    sp1.start(); // play the audio file
  }
  // if the right mouse button is clicked, then play the bass drum sample backwards
  else 
  {
    sp1.setToEnd(); // set the start position to the end of the file
    sp1.start(); // play the file in reverse (rate set in the draw routine)

  }
}










