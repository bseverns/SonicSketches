// MIDI_SYNTH_02.pde

// this example builds a simple midi synthesizer
// for each incoming midi note, we create a new set of beads (encapsulated by a class)
// these beads are stored in a vector
// and destroyed when we get a corresponding note-off message

import themidibus.*; //Import the MidiBus library
import beads.*;

MidiBus busA; // The MidiBus object that will handle midi input
AudioContext ac; // the Beads AudioContext that will oversee audio production and output
Gain MasterGain; // our master gain object

// this ArrayList will hold synthesizer objects
// we will instantiate a new synthesizer object for each note
ArrayList synthNotes = null;

void setup()
{
  size(600,400);
  background(0);
	
  // List all available input devices
  println(); 
  println("Available MIDI Devices:"); 
  System.out.println("----------Input (from availableInputs())----------");
  String[] available_inputs = MidiBus.availableInputs(); //Returns an array of available input devices
  for(int i = 0;i < available_inputs.length;i++) System.out.println("["+i+"] \""+available_inputs[i]+"\"");

  //Create a first new MidiBus attached to the IncommingA Midi input device and the OutgoingA Midi output device.
  busA = new MidiBus(this, 0, 2, "busA");

  println();
  println("Inputs on busA");
  println(busA.attachedInputs()); //Print the devices attached as inputs to busA

  synthNotes = new ArrayList();

  ac = new AudioContext();
  MasterGain = new Gain(ac, 1, 0.3);
  ac.out.addInput(MasterGain);
  ac.start();
  
  background(0); // set the background to black
  text("This program will not do anything if you do not have a MIDI device", 100, 100); // tell the user what to do!
  text("connected to your computer.", 100, 112); // tell the user what to do!
  text("This program is a synthesizer that responds to Note-On Messages.", 100, 124); // tell the user what to do!
}

void draw()
{
  for( int i = 0; i < synthNotes.size(); i++ )
  {
    Synth s = (Synth)synthNotes.get(i);
    if( s.g.isDeleted() ) // if this bead has been killed
    {
      s.destroy(); // destroy the synth (set things to null so that memory cleanup can occur)
      synthNotes.remove(s); // then remove the parent synth
    }
  }
}

// respond to MIDI note-on messages
void noteOn(int channel, int pitch, int velocity, String bus_name)
{
  background(50);
  stroke(255); fill(255);
  text("Note On:", 100, 100);
  text("Channel:" + channel, 100, 120);
  text("Pitch:" + pitch, 100, 140);
  text("Velocity:" + velocity, 100, 160);
  text("Recieved on Bus:" + bus_name, 100, 180);
  
  synthNotes.add(new Synth(pitch));
}

// respond to MIDI note-off messages
void noteOff(int channel, int pitch, int velocity, String bus_name)
{
  background(0);
  stroke(255); fill(255);
  text("Note Off:", 100, 100);
  text("Channel:" + channel, 100, 120);
  text("Pitch:" + pitch, 100, 140);
  text("Velocity:" + velocity, 100, 160);
  text("Recieved on Bus:" + bus_name, 100, 180);
  
  for( int i = 0; i < synthNotes.size(); i++ )
  {
    Synth s = (Synth)synthNotes.get(i);
    if( s.pitch == pitch )
    {
      s.kill();
      break;
    }
  }
}

// this is our synthesizer object
class Synth
{
  public WavePlayer carrier = null;
  public WavePlayer modulator = null;
  public Envelope e = null;
  public Gain g = null;
  
  public int pitch = -1;
  
  // our filter and filter envelope
  LPRezFilter lowPassFilter;
  WavePlayer filterLFO;
  
  Synth(int midiPitch)
  {
    // get the midi pitch and create a couple holders for the midi pitch
    pitch = midiPitch;
    float fundamentalFrequency = 440.0 * pow(2, ((float)midiPitch - 59.0)/12.0);
    Static ff = new Static(ac, fundamentalFrequency);
    
    // instantiate the modulator WavePlayer
    modulator = new WavePlayer(ac, 0.5 * fundamentalFrequency, Buffer.SINE);
    // create our frequency modulation function
    Function frequencyModulation = new Function(modulator, ff)
    {
      public float calculate() {
        // the x[1] here is the value of a sine wave oscillating at the fundamental frequency
        return (x[0] * 1000.0) + x[1];
      }
    };
    // instantiate the carrier WavePlayer
    carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE); // set up the carrier to be controlled by the frequency of the modulator
    
    // set up the filter and LFO
    filterLFO = new WavePlayer(ac, 8.0, Buffer.SINE);
    Function filterCutoff = new Function(filterLFO)
    {
      public float calculate() {
        // set the filter cutoff to oscillate between 1500Hz and 2500Hz
        return ((x[0] * 500.0) + 2000.0);
      }
    };
    lowPassFilter = new LPRezFilter(ac, filterCutoff, 0.96);
    lowPassFilter.addInput(carrier);
    
    // set up and connect the gains
    e = new Envelope(ac, 0.0);
    g = new Gain(ac, 1, e);
    g.addInput(lowPassFilter);
    MasterGain.addInput(g);
    
    e.addSegment(0.5, 300); // add a segment to our gain envelope
  }
  public void kill()
  {
    e.addSegment(0.0, 300, new KillTrigger(g));
  }
  public void destroy()
  {
    carrier.kill(); modulator.kill(); lowPassFilter.kill(); filterLFO.kill();
    e.kill(); g.kill();
    carrier = null; modulator = null; lowPassFilter = null; filterLFO = null;
    e = null; g = null;
  }
}


