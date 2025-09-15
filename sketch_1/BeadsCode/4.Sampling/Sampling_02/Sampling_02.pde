// Sampling_02.pde

// in this example, we load and play two samples
// one forward, and one in reverse

import beads.*;

AudioContext ac;

SamplePlayer sp1;

// declare our second SamplePlayer, and the Glide that will be used to control the rate
SamplePlayer sp2;
Glide rateValue;

// we can run both SamplePlayers through the same Gain
Gain g;
Glide gainValue;

void setup()
{
  size(800, 600);
  
  ac = new AudioContext(); // create our AudioContext

  // whenever we load a file, we need to enclose the code in a Try/Catch block
  // Try/Catch blocks will inform us if the file can't be found
  try {  
    // initialize the first SamplePlayer
    sp1 = new SamplePlayer(ac, new Sample(sketchPath("") + "DrumMachine/Snaredrum 1.wav"));
    sp2 = new SamplePlayer(ac, new Sample(sketchPath("") + "DrumMachine/Soft bassdrum.wav"));
   }
  catch(Exception e)
  {
    // if there is an error, show an error message (at the bottom of the processing window)
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }
  
  // for both SamplePlayers, note that we want to play the sample multiple times
  sp1.setKillOnEnd(false);
  sp2.setKillOnEnd(false);
  
  // initialize our rateValue Glide object
  // a rate of -1 indicates that this sample will be played in reverse
  rateValue = new Glide(ac, 1, -1);
  sp2.setRate(rateValue);

  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 20);
  g = new Gain(ac, 1, gainValue);
  g.addInput(sp1);
  g.addInput(sp2);

  ac.out.addInput(g); // connect the Gain to the AudioContext

  ac.start(); // begin audio processing
  
  background(0); // set the background to black
  text("Left click to play a snare sound.", 100, 100); // tell the user what to do!
  text("Right click to play a reversed kick drum sound.", 100, 120); // tell the user what to do!
}

// although we're not drawing to the screen, we need to have a draw function
// in order to wait for mousePressed events
void draw(){}

// this routine is called whenever a mouse button is pressed on the Processing sketch
void mousePressed()
{
  gainValue.setValue((float)mouseX/(float)width); // set the gain based on mouse position
  
  // if the left mouse button is clicked, then play the snare drum sample
  if( mouseButton == LEFT )
  {
    sp1.setToLoopStart(); // move the playback pointer to the beginning of the sample
    sp1.start(); // play the audio file
  }
  // if the right mouse button is clicked, then play the bass drum sample backwards
  else 
  {
    sp2.setToEnd(); // set the playback pointer to the end of the sample
    rateValue.setValue(-1.0); // set the rate to -1 to play backwards
    sp2.start(); // play the audio file

  }
}










