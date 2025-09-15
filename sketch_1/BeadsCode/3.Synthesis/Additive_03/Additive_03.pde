// Additive_03.pde

// this is a more serious additive synthesizer
// understanding this code requires a basic understanding of arrays, as they are used in Processing

import beads.*; // import the beads library
AudioContext ac; // declare our AudioContext, which will oversee audio input/output

float baseFrequency = 200.0f; // the frequency of the fundamental (the lowest sine wave in the additive tone)
int sineCount = 10; // how many sine waves will be present in our additive tone?

// declare our unit generators
// notice that with the brackets [] we are creating arrays of beads
WavePlayer sineTone[];
Glide sineFrequency[];
Gain sineGain[];

// our master gain object (all sine waves will eventually be routed here)
Gain masterGain;

// this is a ball that will bounce around the screen
bouncer b;

void setup()
{
  size(400, 300);
  
  // initialize our bouncy bal
  b = new bouncer();

  // initialize our AudioContext
  ac = new AudioContext();
  
  // set up our master gain object
  masterGain = new Gain(ac, 1, 0.5);
  ac.out.addInput(masterGain);

  // initialize our arrays of objects
  sineFrequency = new Glide[sineCount];
  sineTone = new WavePlayer[sineCount];
  sineGain = new Gain[sineCount];

  float currentGain = 1.0f;
  for( int i = 0; i < sineCount; i++)
  {
      sineFrequency[i] = new Glide(ac, baseFrequency * i, 30); // create the glide that will control this WavePlayer's frequency
      sineTone[i] = new WavePlayer(ac, sineFrequency[i], Buffer.SINE); // create the WavePlayer
      
      sineGain[i] = new Gain(ac, 1, currentGain); // create the gain object
      sineGain[i].addInput(sineTone[i]); // then connect the waveplayer to the gain
      
      // finally, connect the gain to the master gain
      masterGain.addInput(sineGain[i]);
      
      currentGain -= (1.0 / (float)sineCount); // lower the gain for the next tone in the additive complex
  }

  // start audio processing
  ac.start();
}

void draw()
{
  background(0); // fill the background with black
  
  b.move(); // move the bouncer
  b.draw(); // draw the bouncer
 
  // update the fundamental frequency based on mouse position
  baseFrequency = 20.0f + b.x; // add 20 to the frequency because below 20Hz is inaudible to humans
  
  // update the frequency of each sine tone
  for( int i = 0; i < sineCount; i++)
  {
      sineFrequency[i].setValue(baseFrequency * ((float)(i+1) * (b.y/height)));
  }
}

// this class encapsulates a simple circle that will bounce around the Processing window
class bouncer
{
  public float x = 10.0;
  public float y = 10.0;
  float xSpeed = 1.0;
  float ySpeed = 1.0;
  
  void bouncer() { }
  
  void move()
  {
    x += xSpeed;
    if( x <= 0 ) xSpeed = 1.0;
    else if( x >= width - 10 ) xSpeed = -1.0;
    
    y += ySpeed;
    if( y <= 0 ) ySpeed = 1.0;
    else if( y >= height - 10 ) ySpeed = -1.0;
  }
  
  void draw()
  {
    noStroke();
    fill(255);
    ellipse(x, y, 10, 10);
  }
}
