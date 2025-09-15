// Resynthesis_01.pde

// this example resynthesizes a tone using additive synthesis and the SpectralPeaks object
// the result should be a very simple, low-fidelity vocoder

import beads.*;

int numPeaks = 32; // how many peaks to track and resynth

AudioContext ac;
Gain masterGain;
PowerSpectrum ps;
SpectralPeaks sp;


Gain[] g;
Glide[] gainGlide;
Glide[] frequencyGlide;
WavePlayer[] wp;
float meanFrequency = 400.0;

color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{
  size(600,600);
  
  ac = new AudioContext(); // set up the parent AudioContext object
  
  // set up a master gain object
  masterGain = new Gain(ac, 2, 0.5);
  ac.out.addInput(masterGain);
  
  UGen microphoneIn = ac.getAudioInput(); // get a microphone input unit generator

  frequencyGlide = new Glide[numPeaks];
  wp = new WavePlayer[numPeaks];
  g = new Gain[numPeaks];
  gainGlide = new Glide[numPeaks];
  for( int i = 0; i < numPeaks; i++ )
  {
    // set up the WavePlayer and the Glides that will control its frequency and gain
    frequencyGlide[i] = new Glide(ac, 440, 1);
    wp[i] = new WavePlayer(ac, frequencyGlide[i], Buffer.SINE);
    gainGlide[i] = new Glide(ac, 0.0, 1);
    g[i] = new Gain(ac, 1, gainGlide[i]);
    g[i].addInput(wp[i]); // connect the WavePlayer to the master gain
    masterGain.addInput(g[i]);
  }

  // in this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, descrete chunks
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(microphoneIn); // connect the microphone input to the ShortFrameSegmenter

  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  sfs.addListener(fft); // connect the ShortFramSegmenter object to the FFT
  
  ps = new PowerSpectrum(); // the PowerSpectrum turns the raw FFT output into proper audio data
  fft.addListener(ps); // connect the FFT to the PowerSpectrum
  
  // the SpectralPeaks object stores the N highest Peaks
  sp = new SpectralPeaks(ac, numPeaks);
  ps.addListener(sp); // connect the PowerSpectrum to the Frequency object

  ac.out.addDependent(sfs); // list the frame segmenter as a dependent, so that the AudioContext knows when to update it
  ac.start(); // start processing audio
}

// in the draw routine, we will write the current frequency on the screen
// and set the frequency of our sine wave
void draw()
{
  background(back);
  stroke(fore);
  text("Use the microphone to trigger resynthesis", 100, 100); // draw the average frequency on screen
  
  // get the data from the SpectralPeaks object
  // only run this 1/4 frames so that we don't overload the Glide object with frequency changes
  if( sp.getFeatures() != null && random(1.0) > 0.5)
  {
    float[][] features = sp.getFeatures(); // get the data from the SpectralPeaks object
    for( int i = 0; i < numPeaks; i++ )
    {
      if(features[i][0] < 10000.0) frequencyGlide[i].setValue(features[i][0]);
      
      if(features[i][1] > 0.01) gainGlide[i].setValue(features[i][1]);
      else gainGlide[i].setValue(0.0);
    }
  }

}
