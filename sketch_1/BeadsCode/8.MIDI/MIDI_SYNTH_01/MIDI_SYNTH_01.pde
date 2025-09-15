// MIDI_SYNTH_01.pde

// this example builds a simple midi synthesizer
// for each incoming midi note, we create a new set of beads (encapsulated by a class)
// these beads are stored in a vector
// and destroyed when we get a corresponding note-off message

import themidibus.*; //Import the MidiBus library
import beads.*;

MidiBus busA; // our parent MidiBus object

AudioContext ac;
Gain MasterGain;

ArrayList synthNotes = null;

void setup()
{
  size(600, 400);
  background(0);
	
  // the MidiBus constructor takes four arguments
  // 1 - the calling program (this)
  // 2 - the input device
  // 3 - the output device
  // 4 - the bus name
  // in this case, we just use the defaults
  busA = new MidiBus(this, 0, 0, "busA");

  synthNotes = new ArrayList();

  ac = new AudioContext();
  MasterGain = new Gain(ac, 1, 0.5);
  ac.out.addInput(MasterGain);
  ac.start();
  
  background(0); // set the background to black
  text("This program will not do anything if you do not have a MIDI device", 100, 100); // tell the user what to do!
  text("connected to your computer.", 100, 112); // tell the user what to do!
  text("This program plays sine waves in response to Note-On messages.", 100, 124); // tell the user what to do!
}

void draw()
{
  for( int i = 0; i < synthNotes.size(); i++ )
  {
    SimpleSynth s = (SimpleSynth)synthNotes.get(i);
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
  
  synthNotes.add(new SimpleSynth(pitch));
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
    SimpleSynth s = (SimpleSynth)synthNotes.get(i);
    if( s.pitch == pitch )
    {
      s.kill();
      synthNotes.remove(s);
      break;
    }
  }
}

// this is our simple synthesizer object
class SimpleSynth
{
  public WavePlayer wp = null;
  public Envelope e = null;
  public Gain g = null;
  public int pitch = -1;
  
  // the constructor for our sine wave synthesizer
  SimpleSynth(int midiPitch)
  {
    pitch = midiPitch;
    // set up the new WavePlayer, convert the MidiPitch to a frequency
    wp = new WavePlayer(ac, 440.0 * pow(2, ((float)midiPitch - 59.0)/12.0), Buffer.SINE);
    e = new Envelope(ac, 0.0);
    g = new Gain(ac, 1, e);
    g.addInput(wp); // connect the WavePlayer to the Gain
    MasterGain.addInput(g); // connect the Gain to the Master Gain
    e.addSegment(0.5, 300);
  }
  // when this note is killed, ramp the amplitude down to 0 over 300ms
  public void kill()
  {
    e.addSegment(0.0, 300, new KillTrigger(g));
  }
  // destroy the component beads so that they can be cleaned up by the java virtual machine
  public void destroy()
  {
    wp.kill();
    e.kill();
    g.kill();
    wp = null;
    e = null;
    g = null;
  }
}

