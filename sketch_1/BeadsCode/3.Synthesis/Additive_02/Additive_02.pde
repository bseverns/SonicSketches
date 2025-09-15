// Additive_02.pde

// this is a more serious additive synthesizer
// understanding this code requires a basic understanding of arrays, as they are used in Processing

// import the beads library (you must have installed it properly. as of this writing, it is not included with Processing)
import beads.*;

// create our AudioContext, which will oversee audio input/output
AudioContext ac;

float baseFrequency = 200.0f; // the frequency of the fundamental (the lowest sine wave in the additive tone)
int sineCount = 10; // how many sine waves will be present in our additive tone?

// declare our unit generators
// notice that with the brackets [] we are creating arrays of beads
WavePlayer sineTone[];
Glide sineFrequency[];
Gain sineGain[];

// our master gain object (all sine waves will eventually be routed here)
Gain masterGain;

void setup()
{
  size(400, 300);

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
      sineFrequency[i] = new Glide(ac, baseFrequency * (i + 1), 30); // create the glide that will control this WavePlayer's frequency
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
  // update the fundamental frequency based on mouse position
  baseFrequency = 20.0f + mouseX; // add 20 to the frequency because below 20Hz is inaudible to humans
  
  // update the frequency of each sine tone
  for( int i = 0; i < sineCount; i++)
  {
      sineFrequency[i].setValue(baseFrequency * (i + 1));
  }
}
