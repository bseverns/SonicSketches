//Granulating_Input_01.pde

// This example is just like the previous example, except when we initiate playback, we use a GranularSamplePlayer
// if you want to automate the recording and granulation process, then you could use a clock object

import beads.*; // import the beads library
import javax.sound.sampled.AudioFormat; // we need to import the java sound audio format definitions

AudioContext ac; // declare the parent AudioContext
Gain g; // our master gain
RecordToSample rts; // this object is used to start and stop recording
Sample targetSample; // this object will hold our audio data

boolean recording = false; // are we currently recording a sample?

void setup() {
  size(800,800);
  
  ac = new AudioContext(); // initialize the AudioContext
  
  // get an AudioInput UGen from the AudioContext
  // this will setup an input from whatever input is your default audio input (usually the microphone in)
  UGen microphoneIn = ac.getAudioInput();

  // setup the recording unit generator
  try{
    AudioFormat af = new AudioFormat(44100.0f, 16, 1, true, true); // setup a recording format
    targetSample = new Sample(af, 44100); // create a holder for audio data
    rts = new RecordToSample(ac, targetSample, RecordToSample.Mode.INFINITE); // initialize the RecordToSample object
  }
  catch(Exception e){ // if there is an error, then stop program execution
    e.printStackTrace();
    exit();
  }
  rts.addInput(microphoneIn); // connect the microphone input to the RecordToSample object
  ac.out.addDependent(rts); // tell the AudioContext to work with the RecordToSample object
  rts.pause(true); // pause the RecordToSample object

  // set up our usual master gain object
  g = new Gain(ac, 1, 0.5);
  g.addInput(microphoneIn);
  ac.out.addInput(g);
  
  ac.start(); // begin working with audio
}

void draw()
{
  background(0); // set the background to black
  text("Left click to start/stop recording. Right click to granulate.", 100, 100); // tell the user what to do!
  if( recording ) text("Recording...", 100, 120); // if we are currently recording, then say so
}

// this routine is triggered whenever a mouse button is pressed
void mousePressed()
{
  if( mouseButton == LEFT ) // when the user left-clicks
  {
    if( rts.isPaused() ) // if the RecordToSample object is currently paused
    {
      recording = true; // note that we are now recording
      targetSample.clear(); // clear the target sample
      rts.start(); // and start recording
    }
    else // if the RecordToSample is recording
    {
      recording = false; // note that we are no longer recording
      rts.pause(true); // and stop recording
    }
  }
  else // if the user right-clicks
  {
    GranularSamplePlayer gsp = new GranularSamplePlayer(ac, targetSample); // instantiate a new SamplePlayer with the recorded sample
    gsp.setGrainInterval(new Static(ac, 20f)); // set the grain interval to about 20ms between grains
    gsp.setGrainSize(new Static(ac, 50f)); // set the grain size to about 50ms (smaller is sometimes a bit too grainy for my taste)
    gsp.setRandomness(new Static(ac, 50f)); // set the randomness, which will add variety to all the parameters
    g.addInput(gsp); // connect the GranularSamplePlayer to the Gain
    gsp.setKillOnEnd(true); // tell the GranularSamplePlayer to destroy itself when it finishes
    gsp.start(); // and begin playback
  }
}

