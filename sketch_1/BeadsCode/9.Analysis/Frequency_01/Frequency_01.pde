// Frequency_01.pde

// this example attempts to guess the strongest frequency in the signal that comes in via the microphone
// then it plays a sine wave at that frequency
// unfortunately, this doesn't work very well for singing
// but it works quite well for whistling (in my testing)

import beads.*;

AudioContext ac;
PowerSpectrum ps;
Frequency f;

Glide frequencyGlide;
WavePlayer wp;
float meanFrequency = 400.0;

color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{
  size(600,600);
  
  ac = new AudioContext(); // set up the parent AudioContext object
  
  // set up a master gain object
  Gain g = new Gain(ac, 2, 0.5);
  ac.out.addInput(g);
  
  UGen microphoneIn = ac.getAudioInput(); // get a microphone input unit generator

  // set up the WavePlayer and the Glide that will control its frequency
  frequencyGlide = new Glide(ac, 50, 10);
  wp = new WavePlayer(ac, frequencyGlide, Buffer.SINE);
  g.addInput(wp); // connect the WavePlayer to the master gain

  // in this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, descrete chunks
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(microphoneIn); // connect the microphone input to the ShortFrameSegmenter

  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  sfs.addListener(fft); // connect the ShortFramSegmenter object to the FFT
  
  ps = new PowerSpectrum(); // the PowerSpectrum turns the raw FFT output into proper audio data
  fft.addListener(ps); // connect the FFT to the PowerSpectrum
  
  // the Frequency object tries to guess the strongest frequency for the incoming data
  // this is a tricky calculation, as there are many frequencies in any real world sound
  // Further, the incoming frequencies are effected by the microphone being used, and the cables and electronics that the signal flows through
  f = new Frequency(44100.0f);
  ps.addListener(f); // connect the PowerSpectrum to the Frequency object

  ac.out.addDependent(sfs); // list the frame segmenter as a dependent, so that the AudioContext knows when to update it
  ac.start(); // start processing audio
}

// in the draw routine, we will write the current frequency on the screen
// and set the frequency of our sine wave
void draw()
{
  background(back);
  stroke(fore);
  text(" Input Frequency: " + meanFrequency, 100, 100); // draw the average frequency on screen
  
  // get the data from the Frequency object
  // only run this 1/4 frames so that we don't overload the Glide object with frequency changes
  if( f.getFeatures() != null && random(1.0) > 0.75)
  {
    float inputFrequency = f.getFeatures(); // get the data from the Frequency object

    // only use frequency data that is under 3000Hz - this will include all the fundamentals of most instruments
    // in other words, data over 3000Hz will usually be erroneous (if we are using microphone input and instrumental/vocal sounds)
    if( inputFrequency < 3000)
    {
      meanFrequency = (0.4 * inputFrequency) + (0.6 * meanFrequency); // store a running average
      frequencyGlide.setValue(meanFrequency); // set the frequency stored in the Glide object
    }
  }

}
