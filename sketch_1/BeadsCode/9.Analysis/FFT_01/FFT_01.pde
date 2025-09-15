// FFT_01.pde

// this example is based in part on an example included with the Beads download originally written by Beads creator Ollie Brown
// it draws the frequency information for a sound on screen

import beads.*;

AudioContext ac;
PowerSpectrum ps;

color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{
  size(600,600);
  
  ac = new AudioContext(); // set up the parent AudioContext object
  
  // set up a master gain object
  Gain g = new Gain(ac, 2, 0.3);
  ac.out.addInput(g);
  
  // load up a sample included in code download
  SamplePlayer player = null;
  try
  {
    player = new SamplePlayer(ac, new Sample(sketchPath("") + "Drum_Loop_01.wav")); // load up a new SamplePlayer using an included audio file
    g.addInput(player); // connect the SamplePlayer to the master Gain
  }
  catch(Exception e)
  {
    e.printStackTrace(); // if there is an error, print the steps that got us to that error
  }

  // in this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, descrete chunks
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);
  
  // FFT stands for Fast Fourier Transform
  // all you really need to know about the FFT is that it lets you see what frequencies are present in a sound
  // the waveform we usually look at when we see a sound displayed graphically is time domain sound data
  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  sfs.addListener(fft); // connect the FFT object to the ShortFrameSegmenter
  
  ps = new PowerSpectrum(); // the PowerSpectrum pulls the Amplitude information from the FFT calculation (essentially)
  fft.addListener(ps); // connect the PowerSpectrum to the FFT

  ac.out.addDependent(sfs); // list the frame segmenter as a dependent, so that the AudioContext knows when to update it
  ac.start(); // start processing audio
}

// in the draw routine, we will interpret the FFT results and draw them on screen
void draw()
{
  background(back);
  stroke(fore);
  
  // the getFeatures() function is a key part of the Beads analysis library
  // it returns an array of floats
  // how this array of floats is defined (1 dimension, 2 dimensions ... etc) is based on the calling unit generator
  // in this case, the PowerSpectrum returns an array with the power of 256 spectral bands
  float[] features = ps.getFeatures(); // get the data from the PowerSpectrum object
  
  // if any features are returned
  if(features != null)
  {
    // for each x coordinate in the Processing window
    for(int x = 0; x < width; x++)
    {
      // draw a vertical line corresponding to the frequency represented by this x-position
      int featureIndex = (x * features.length) / width; // figure out which featureIndex corresponds to this x-position
      int barHeight = Math.min((int)(features[featureIndex] * height), height - 1); // calculate the bar height for this feature
      line(x, height, x, height - barHeight); // draw on screen
    }
  }
}
