// Clock_01.pde

// this example builds a simple midi synthesizer
// then we trigger random notes using the Clock class

import beads.*;

AudioContext ac; // the Beads AudioContext that will oversee audio production and output
Gain MasterGain; // our master gain object

// this ArrayList will hold synthesizer objects
// we will instantiate a new synthesizer object for each note
ArrayList synthNotes = null;

Clock beatClock = null; // our clock object will control timing

void setup()
{
  size(600,400);
  background(0);
	
  synthNotes = new ArrayList();

  ac = new AudioContext();

  beatClock = new Clock(ac, 1000);
  beatClock.setTicksPerBeat(4);
  ac.out.addDependent(beatClock); // this tell the AudioContext when to update the Clock
  
  Bead noteGenerator = new Bead () {
    public void messageReceived(Bead message)
    {
        synthNotes.add(new Synth(20 + (int)random(88)));
    }
  };
  beatClock.addMessageListener(noteGenerator);
  
  MasterGain = new Gain(ac, 1, 0.3);
  ac.out.addInput(MasterGain);
  ac.start();
  
  background(0); // set the background to black
  text("This program generates randomized synth notes.", 100, 100); // tell the user what to do!
}

void draw()
{
  for( int i = 0; i < synthNotes.size(); i++ )
  {
    Synth s = (Synth)synthNotes.get(i);
    if( s.g.isDeleted() )
    {
      synthNotes.remove(i); // then remove the parent synth
      s = null;
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
  
  public boolean alive = true;
  
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
    
    // set up the filter and LFO (randomized LFO frequency)
    filterLFO = new WavePlayer(ac, 1.0 + random(100), Buffer.SINE);
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
    
    // create a randomized Gain envelope for this note
    e.addSegment(0.5, 10 + (int)random(500));
    e.addSegment(0.4, 10 + (int)random(500));
    e.addSegment(0.0, 10 + (int)random(500), new KillTrigger(g));
  }
  public void destroyMe()
  {
    carrier.kill(); modulator.kill(); lowPassFilter.kill(); filterLFO.kill();
    e.kill(); g.kill();
    carrier = null; modulator = null; lowPassFilter = null; filterLFO = null;
    e = null; g = null;
    alive = false;
  }
}


