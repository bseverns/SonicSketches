// Hello_Glide_01.pde

// import the beads library (you must have installed it properly. as of this writing, it is not included with Processing)
import beads.*;

// create our AudioContext, which will oversee audio input/output
AudioContext ac;

// declare our unit generators (Beads) since we will need to access them throughout the program
WavePlayer wp;
Gain g;
Glide gainGlide;

void setup()
{
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  
  // create a WavePlayer
  wp = new WavePlayer(ac, 440, Buffer.SINE);
  
  // create the Glide object
  // Glide objects move smoothly from one value to another
  // 0.0 is the initial value contained by the Glide
  // it will take 50ms for it to transition to a new value
  gainGlide = new Glide(ac, 0.0, 50);
  
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
  text("Move the mouse to control the sine gain.", 100, 100); // tell the user what to do!
}

void draw()
{
  // in the draw routine, we will update our gain
  // since this routine is called repeatedly, this will continuously change the volume of the sine wave
  // based on the position of the mouse cursor within the Processing window
  gainGlide.setValue(mouseX / (float)width);
}
