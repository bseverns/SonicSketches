// Granular_02.pde

// this granular synthesis program is similar to Granular_01, except we add a second granulator and a delay to fill out the texture
// this program is very complex, but it can be used to create an assortment of interesting sounds and textures

import beads.*; // import the beads library

AudioContext ac; // declare our parent AudioContext

// change this line to try the granulator on another sound file
// this granulator can be used to create a wide variety of sounds, depending on the input file
String sourceFile = "OrchTuning01.wav"; // what file will be granulated?

Gain masterGain; // our usual master gain
Glide masterGainValue;

// these unit generators will be connected to various granulation parameters
GranularSamplePlayer gsp1; // our first GranularSamplePlayer object
Gain g1;
Glide gainValue1;
Glide randomnessValue1;
Glide grainSizeValue1;
Glide positionValue1;
Glide intervalValue1;
Glide pitchValue1;

// we repeat the same unit generators for our second granulator
GranularSamplePlayer gsp2;
Gain g2;
Glide gainValue2;
Glide randomnessValue2;
Glide grainSizeValue2;
Glide positionValue2;
Glide intervalValue2;
Glide pitchValue2;

// we add a delay unit just to give the program a fuller sound
TapIn delayIn;
TapOut delayOut;
Gain delayGain;

Sample sourceSample = null; // this object will hold the audio data that will be granulated
float sampleLength = 0; // this float will hold the length of the audio data, so that we don't go out of bounds when setting the granulation position

// these variables will be used to store properties of the mouse cursor
int xChange = 0;
int yChange = 0;
int lastMouseX = 0;
int lastMouseY = 0;

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
  masterGainValue = new Glide(ac, 0.9, 100);
  masterGain = new Gain(ac, 1, masterGainValue);


  // these ugens will control aspects of the granular sample player
  // remember the arguments on the Glide constructor (AudioContext, Initial Value, Glide Time)
  gsp1 = new GranularSamplePlayer(ac, sourceSample); // initialize our GranularSamplePlayer
  randomnessValue1 = new Glide(ac, 80, 10);
  intervalValue1 = new Glide(ac, 100, 100);
  grainSizeValue1 = new Glide(ac, 100, 50);
  positionValue1 = new Glide(ac, 50000, 30);
  pitchValue1 = new Glide(ac, 1, 20);
  gainValue1 = new Glide(ac, 0.0, 30);
  g1 = new Gain(ac, 1, gainValue1);
  g1.addInput(gsp1);

  // connect all of our Glide objects to the previously created GranularSamplePlayer
  gsp1.setRandomness(randomnessValue1);
  gsp1.setGrainInterval(intervalValue1);
  gsp1.setGrainSize(grainSizeValue1);
  gsp1.setPosition(positionValue1);
  gsp1.setPitch(pitchValue1);

  // we will repeat the same Unit Generators for the second GranularSamplePlayer
  gsp2 = new GranularSamplePlayer(ac, sourceSample); // initialize our GranularSamplePlayer
  randomnessValue2 = new Glide(ac, 140, 10);
  intervalValue2 = new Glide(ac, 60, 50);
  grainSizeValue2 = new Glide(ac, 100, 20);
  positionValue2 = new Glide(ac, 50000, 30);
  pitchValue2 = new Glide(ac, 1, 50);
  gainValue2 = new Glide(ac, 0.0, 30);
  g2 = new Gain(ac, 1, gainValue2);
  g2.addInput(gsp2);

  // connect all of our Glide objects to the previously created GranularSamplePlayer
  gsp2.setRandomness(randomnessValue2);
  gsp2.setGrainInterval(intervalValue2);
  gsp2.setGrainSize(grainSizeValue2);
  gsp2.setPosition(positionValue2);
  gsp2.setPitch(pitchValue2);

  // set up our delay unit (this will be covered more thoroughly in a later example)
  delayIn = new TapIn(ac, 2000); // the TapIn object is the start of the delay
  delayOut = new TapOut(ac, delayIn, 200.0); // the TapOut object is the delay output object
  delayIn.addInput(g1); // connect the first GranularSamplePlayer to the delay input
  delayIn.addInput(g2); // connect the second GranularSamplePlayer to the delay input
  delayGain = new Gain(ac, 1, 0.15); // set the volume of the delay effect
  delayGain.addInput(delayOut); // connect the delay output to the gain input

  masterGain.addInput(g1); // connect the first GranularSamplePlayer to the master gain
  masterGain.addInput(g2); // connect the second GranularSamplePlayer to the master gain
  masterGain.addInput(delayGain); // connect our delay effect to the master gain
  gsp1.start(); // start the first granular sample player
  gsp2.start(); // start the second granular sample player

  ac.out.addInput(masterGain); // connect the master gain to the AudioContext's master output
  ac.start(); // begin audio processing
  
  background(0); // set the background to black
  text("Move the mouse to control granular synthesis.", 100, 120); // tell the user what to do!
}

// the main draw function
void draw()
{
 
  // get the location and speed of the mouse cursor
  xChange = abs(lastMouseX - mouseX);
  yChange = abs(lastMouseY - mouseY);
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  
  float newGain = (xChange + yChange) / 3.0;
  if( newGain > 1.0 ) newGain = 1.0;

  gainValue1.setValue(newGain);
  float pitchRange = yChange / 200.0;
  pitchValue1.setValue(random(1.0-pitchRange, 1.0+pitchRange));
  // set randomness to a nice random level
  randomnessValue1.setValue(random(100) + 1.0);
  // set the time interval value according to how much the mouse is moving horizontally
  intervalValue1.setValue(random(random(200, 1000) / (xChange+1)) );
  // grain size can be set by moving the mouse along the Y-axis
  grainSizeValue1.setValue((float)mouseY / 10);
  // and the X-axis is used to control the position in the wave file that is being granulated
  positionValue1.setValue((float)((float)mouseX / (float)this.getWidth()) * (sampleLength - 400));
  
  // set up the same relationships as with the first GranularSamplePlayer, but use slightly different numbers
  gainValue1.setValue(newGain * 0.8);
  pitchRange *= 3.0; // use a slightly larger pitch range
  pitchValue2.setValue(random(1.0-pitchRange, 1.0+pitchRange));
  randomnessValue2.setValue(random(150) + 1.0);
  intervalValue2.setValue(random(random(500, 1000) / (xChange+1)) ); // use a slightly longer interval value
  grainSizeValue2.setValue((float)mouseY / 5);
  positionValue2.setValue((float)((float)mouseX / (float)this.getWidth()) * (sampleLength - 400));

}


