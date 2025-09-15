// Granular_01.pde

// in this granular synthesis demonstration, the mouse controls the position and grain size parameters
// the position within the source audio file is controlled by the X-axis
// the grain size is controlled by the Y-axis

import beads.*; // import the beads library

AudioContext ac; // declare our parent AudioContext

String sourceFile = "OrchTuning01.wav"; // what file will be granulated?

Gain masterGain; // our usual master gain

GranularSamplePlayer gsp; // our GranularSamplePlayer object

// these unit generators will be connected to various granulation parameters
Glide gainValue;
Glide randomnessValue;
Glide grainSizeValue;
Glide positionValue;
Glide intervalValue;
Glide pitchValue;

Sample sourceSample = null; // this object will hold the audio data that will be granulated
float sampleLength = 0; // this float will hold the length of the audio data, so that we don't go out of bounds when setting the granulation position

void setup()
{
  size(800, 600); // set a reasonable window size
  
  ac = new AudioContext(); // initialize our AudioContext

  // again, we encapsulate the file-loading in a try-catch block, just in case there is an error with file access
  try {
    // load the audio file which will be used in granulation - notice the use of the sketchPath function
    sourceSample = new Sample(sketchPath("") + sourceFile);
  }
  // catch any errors that occur in file loading
  catch(Exception e) {
    println("Exception while attempting to load sample!");
    e.printStackTrace();
    exit();
  }
  sampleLength = sourceSample.getLength(); // store the sample length - this will be used when determining where in the file we want to position our granulation pointer

  // set up our master gain
  gainValue = new Glide(ac, 0.5, 100);
  masterGain = new Gain(ac, 1, gainValue);

  gsp = new GranularSamplePlayer(ac, sourceSample); // initialize our GranularSamplePlayer

  // these ugens will control aspects of the granular sample player
  // remember the arguments on the Glide constructor (AudioContext, Initial Value, Glide Time)
  randomnessValue = new Glide(ac, 80, 10);
  intervalValue = new Glide(ac, 100, 100);
  grainSizeValue = new Glide(ac, 100, 50);
  positionValue = new Glide(ac, 50000, 30);
  pitchValue = new Glide(ac, 1, 20);

  // connect all of our Glide objects to the previously created GranularSamplePlayer
  gsp.setRandomness(randomnessValue);
  gsp.setGrainInterval(intervalValue);
  gsp.setGrainSize(grainSizeValue);
  gsp.setPosition(positionValue);
  gsp.setPitch(pitchValue);

  masterGain.addInput(gsp); // connect our GranularSamplePlayer to the master gain
  gsp.start(); // start the granular sample player

  ac.out.addInput(masterGain); // connect the master gain to the AudioContext's master output
  ac.start(); // begin audio processing
  
  background(0); // set the background to black
  text("Move the mouse to control granular synthesis.", 100, 120); // tell the user what to do!
}

// the main draw function
void draw()
{
  background(0, 0, 0);

  // grain size can be set by moving the mouse along the Y-axis
  grainSizeValue.setValue((float)mouseY / 5);

  // and the X-axis is used to control the position in the wave file that is being granulated
  // the equation used here looks complex, but it really isn't
  // all we're doing is translating on-screen position into position in the audio file
  // this: (float)mouseX / (float)this.getWidth() calculates a 0.0 to 1.0 value for position along the x-axis
  // then we multiply it by sampleLength (minus a little buffer for safety) to get the position in the audio file
  positionValue.setValue((float)((float)mouseX / (float)this.getWidth()) * (sampleLength - 400));
}


