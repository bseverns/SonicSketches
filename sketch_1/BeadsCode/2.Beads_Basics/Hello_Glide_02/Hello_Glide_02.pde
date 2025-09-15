// Hello_Glide_02.pde

// import the beads library (you must have installed it properly. as of this writing, it is not included with Processing)
import beads.*;

// create our AudioContext, which will oversee audio input/output
AudioContext ac;

// declare our unit generators (Beads) since we will need to access them throughout the program
WavePlayer wp;
Gain g;
Glide gainGlide;
Glide frequencyGlide;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create the gain Glide object
  // 0.0 is the initial value contained by the Glide
  // it will take 50ms for it to transition to a new value
  gainGlide = new Glide(ac, 0.0, 50);
  
  // create frequency glide object
  // give it a starting value of 20 (Hz)
  // and a transition time of 50ms
  frequencyGlide = new Glide(ac, 20, 50);
  
  // create a WavePlayer
  // attach the frequency to frequencyGlide
  wp = new WavePlayer(ac, frequencyGlide, Buffer.SINE);

  // create a Gain object
  // this time, we will attach the gain amount to the glide object created above
  g = new Gain(ac, 1, gainGlide);

  // connect the WavePlayer output to the Gain input
  g.addInput(wp);
  
  // connect the Gain output to the AudioContext
  ac.out.addInput(g);
  
  // start audio processing
  ac.start();
  
  background(0); // set the background to black
  text("The mouse X-Position controls volume.", 100, 100); // tell the user what to do!
  text("The mouse Y-Position controls frequency.", 100, 120); // tell the user what to do!

}

void draw()
{
  // update the gain based on the position of the mouse cursor within the Processing window
  gainGlide.setValue(mouseX / (float)width);

  // update the frequency based on the position of the mouse cursor within the Processing window
  frequencyGlide.setValue(mouseY);
}
