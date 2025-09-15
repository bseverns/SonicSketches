/*
This is a saw-wave oscillator. The method .play() starts the oscillator. There
 are several setters like .amp(), .freq(), .pan() and .add(). If you want to set all of them at
 the same time use .set(float freq, float amp, float add, float pan)
 */

import processing.sound.*;

SqrOsc[] sqr;
SawOsc saw;

int numSqr = 5;

float[] sqrVol;

void setup() {
  size(640, 360);
  background(255);

  // Create the sine oscillator.
  saw = new SawOsc(this);

  // Create and start the sine oscillator.
  sqr = new SqrOsc[numSqr];
  sqrVol = new float[numSqr];
  
for (int i= 0; i < numSqr; i++) {
  
  sqrVol[i] = (1.0/numSqr) / (i +1);
  //Start the Sine Oscillator. There will be no sound in the beginning
  //unless the mouse enters the
  sqr[i] = new SqrOsc(this);
  sqr[i].play();
}
  
  //Start the Sine Oscillator. There will be no sound in the beginning
  //unless the mouse enters the   
  saw.play();
}

void draw() {
  //// Map mouseY from 0.0 to 1.0 for amplitude
  //sqr.amp(map(mouseY, 0, height, 1.0, 0.0));
  //// Map mouseX from 20Hz to 1000Hz for frequency  
  //sqr.freq(map(mouseX, 0, width, 80.0, 200.0));
  //// Map mouseX from -1.0 to 1.0 for left to right 
  //sqr.pan(map(mouseX, 0, width, -1.0, 1.0));
    // Map mouseY to get values from 0.0 to 1.0
    
    
  float yoffset = (height - mouseY) / float(height);
  
  
  // Map that value logarithmically to 150 - 1150 Hz
  float frequency = pow(1000, yoffset) + 150; 
  // Map mouseX from -0.5 to 0.5 to get a multiplier for detuning the oscillators
  float detune = float(mouseX) / width - 0.5;
  // Map mouseY from 0.0 to 1.0 for amplitude
  saw.amp(map(mouseY, 0, height, 1.0, 0.0));
  // Map mouseX from 20Hz to 1000Hz for frequency  
  saw.freq(map(mouseX, 0, width, 80.0, 200.0));
  // Map mouseX from -1.0 to 1.0 for left to right 
  saw.pan(map(mouseX, 0, width, -1.0, 1.0));
  
   // Set the frequencies, detuning and volume
  for (int i = 0; i < numSqr; i++) { 
    sqr[i].freq(frequency * (i + 1 + i * detune));
    sqr[i].amp(sqrVol[i]);

  }
}
