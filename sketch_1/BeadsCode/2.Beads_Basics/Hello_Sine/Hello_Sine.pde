// Hello_Sine.pde

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
  
  // connect the WavePlayer to the AudioContext
  ac.out.addInput(wp);
  
  // start audio processing
  ac.start();
}
