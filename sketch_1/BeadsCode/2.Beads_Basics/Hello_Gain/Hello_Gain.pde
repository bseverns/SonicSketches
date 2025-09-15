// Hello_Gain.pde

// import the beads library (you must have installed it properly. as of this writing, it is not included with Processing)
import beads.*;

// create our AudioContext, which will oversee audio input/output
AudioContext ac;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create a WavePlayer
  // WavePlayer objects generate a waveform, in this case, a sine wave at 440 Hz
  WavePlayer wp = new WavePlayer(ac, 440, Buffer.SINE);
  
  // create a Gain object
  // Gain objects set the volume of whatever they are connected to
  // Here, we create a Gain with 1 input and output, with a fixed volume of 0.2 (50%)
  Gain g = new Gain(ac, 1, 0.2);

  // connect the WavePlayer output to the Gain input
  g.addInput(wp);
  
  // connect the Gain output to the AudioContext
  ac.out.addInput(g);
  
  // start audio processing
  ac.start();
}
