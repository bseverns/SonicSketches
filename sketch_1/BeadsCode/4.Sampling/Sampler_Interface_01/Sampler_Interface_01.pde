// Sampler_Interface_01.pde

// this is a complex, mouse-driven sampler
// make sure that you understand the examples in Sampling_01, Sampling_02 and Sampling_03 before trying to tackle this

// import the java File library
// this will be used to locate the audio files that will be loaded into our sampler
import java.io.File;

import beads.*; // import the beads library

AudioContext ac; // and declare our parent AudioContext as usual

// these variables store mouse position and change in mouse position along each axis
int xChange = 0;
int yChange = 0;
int lastMouseX = 0;
int lastMouseY = 0;

int numSamples = 0; // how many samples are being loaded?
int sampleWidth = 0; // how much space will a sample take on screen? how wide will be the invisible trigger area?
String sourceFile[]; // an array that will contain our sample filenames
Gain g[]; // an array of Gains
Glide gainValue[];
Glide rateValue[];
Glide pitchValue[];
SamplePlayer sp[]; // an array of SamplePlayer

// these objects allow us to add a delay effect
TapIn delayIn;
TapOut delayOut;
Gain delayGain;

void setup()
{
  size(800, 600); // create a reasonably-sized playing field for our sampler
  
  ac = new AudioContext(); // initialize our AudioContext

  // this block of code counts the number of samples in the /samples subfolder
  File folder = new File(sketchPath("") + "samples/");
  File[] listOfFiles = folder.listFiles();
  for (int i = 0; i < listOfFiles.length; i++)
  {
      if (listOfFiles[i].isFile())
      {
        if( listOfFiles[i].getName().endsWith(".wav") )
        {
          numSamples++;
        }
      }
  }
  
  // if no samples are found, then end
  if( numSamples <= 0 )
  {
    println("no samples found in " + sketchPath("") + "samples/");
    println("exiting...");
    exit();
  }
    
  sampleWidth = (int)(this.getWidth() / (float)numSamples); // how many pixels along the x-axis will each sample occupy?
  
  // this block of code reads and stores the filename for each sample
  sourceFile = new String[numSamples];
  int count = 0;
  for (int i = 0; i < listOfFiles.length; i++)
  {
      if (listOfFiles[i].isFile())
      {
        if( listOfFiles[i].getName().endsWith(".wav") )
        {
          sourceFile[count] = listOfFiles[i].getName();
          count++;
        }
      }
  }
  
  // set the size of our arrays of unit generators in order to accomodate the number of samples that will be loaded
  g = new Gain[numSamples];
  gainValue = new Glide[numSamples];
  rateValue = new Glide[numSamples];
  pitchValue = new Glide[numSamples];
  sp = new SamplePlayer[numSamples];

  // set up our delay - this is just for taste, to fill out the texture  
  delayIn = new TapIn(ac, 2000);
  delayOut = new TapOut(ac, delayIn, 200.0);
  delayGain = new Gain(ac, 1, 0.15);
  delayGain.addInput(delayOut);
  
  ac.out.addInput(delayGain); // connect the delay to the master output

  // enclose the file-loading in a try-catch block
  try {  
    // run through each file
    for( count = 0; count < numSamples; count++ )
    {
      println("loading " + sketchPath("") + "samples/" + sourceFile[count]); // print a message to show which file we are loading
      
      // create the SamplePlayer that will run this particular file
      sp[count] = new SamplePlayer(ac, new Sample(sketchPath("") + "samples/" + sourceFile[count]));
      //sp[count].setLoopPointsFraction(0.0, 1.0);
      sp[count].setKillOnEnd(false);

      // these unit generators will control aspects of the sample player
      gainValue[count] = new Glide(ac, 0.0);
      gainValue[count].setGlideTime(20);
      g[count] = new Gain(ac, 1, gainValue[count]);
      rateValue[count] = new Glide(ac, 1);
      rateValue[count].setGlideTime(20);
      pitchValue[count] = new Glide(ac, 1);
      pitchValue[count].setGlideTime(20);

      sp[count].setRate(rateValue[count]);
      sp[count].setPitch(pitchValue[count]);
      g[count].addInput(sp[count]);

      // finally, connect this chain to the delay and to the main out    
      delayIn.addInput(g[count]);
      ac.out.addInput(g[count]);
    }
  }
  // if there is an error while loading the samples
  catch(Exception e)
  {
    // show that error in the space underneath the processing code
    println("Exception while attempting to load sample!");
    e.printStackTrace();
    exit();
  }

  ac.start(); // begin audio processing
  
  background(0); // set the background to black
  text("Move the mouse quickly to trigger playback.", 100, 100); // tell the user what to do!
  text("Faster movement will trigger more and louder sounds.", 100, 120); // tell the user what to do!
}

// the main draw function
void draw()
{
  background(0);

  // calculate the mouse speed and location
  xChange = abs(lastMouseX - mouseX);
  yChange = lastMouseY - mouseY;
  lastMouseX = mouseX;
  lastMouseY = mouseY;

  // calculate the gain of newly triggered samples
  float newGain = (abs(yChange) + xChange) / 2.0;
  newGain /= this.getWidth();
  if( newGain > 1.0 ) newGain = 1.0;

  // calculate the pitch range  
  float pitchRange = yChange / 200.0;
  
  // should we trigger the sample that the mouse is over?
  if( newGain > 0.09 )
  {
    // get the index of the sample that is coordinated with the mouse location
    int currentSampleIndex = (int)(mouseX / sampleWidth);
    if( currentSampleIndex < 0 ) currentSampleIndex = 0;
    else if( currentSampleIndex >= numSamples ) currentSampleIndex = numSamples;
    
    // trigger that sample
    // if the mouse is moving upwards, then play it in reverse
    triggerSample(currentSampleIndex, (boolean)(yChange < 0), newGain, pitchRange);
  }
  
  // randomly trigger other samples, based loosely on the mouse speed
  // loop through each sample
  for( int currentSample = 0; currentSample < numSamples; currentSample++ )
  {
    // if a random number is less than the current gain
    if( random(1.0) < (newGain / 2.0) )
    {
      // trigger that sample
      triggerSample(currentSample, (boolean)(yChange < 0 && random(1.0) < 0.33), newGain, pitchRange);
    }
  }
  


}

// trigger a sample
void triggerSample(int index, boolean reverse, float newGain, float pitchRange)
{
  if( index >= 0 && index < numSamples )
  {
    println("triggering sample " + index); // show a message that indicates which sample we are triggering
  
    gainValue[index].setValue(newGain); // set the gain value
    pitchValue[index].setValue(random(1.0-pitchRange, 1.0+pitchRange)); // and set the pitch value (which is really just another rate controller)
  
    // if we should play the sample in reverse
    if( reverse )
    {
      if( !sp[index].inLoop() )
      {
        rateValue[index].setValue(-1.0);
        sp[index].setToEnd();
      }
    }
    else // if we should play the sample forwards
    {
      if( !sp[index].inLoop() )
      {
        rateValue[index].setValue(1.0);
        sp[index].setToLoopStart();
      }
    }

    sp[index].start();
  }
}










