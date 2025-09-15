// MorphingWavePlayer.pde
// this file demonstrates the creation of custom beads for use in Processing
// it expands upon the standard WavePlayer by allowing the programmer to mix between two buffers

import beads.AudioContext;
import beads.UGen;
import beads.Buffer;
import beads.SawBuffer;
import beads.SineBuffer;
import beads.SquareBuffer;

public class MorphingWavePlayer extends UGen
{
  private double phase; /** The playback point in the Buffer, expressed as a fraction. */
  private UGen frequencyEnvelope; /** The frequency envelope. */
  private UGen phaseEnvelope; /** The phase envelope. */

  // the buffers that will be mixed
  private Buffer buffer1;
  private Buffer buffer2;

  // the unit generators that will control the mixing
  private UGen mixEnvelope;
  private float mix;
  private boolean isMixStatic = true; // default to true
  
  private float frequency; /** The oscillation frequency. */
  private boolean isFreqStatic;
  
  private float one_over_sr; /** To store the inverse of the sampling frequency. */

  // constructors
  private MorphingWavePlayer(AudioContext context, Buffer newBuffer1, Buffer newBuffer2)
  {
    super(context, 1);
    this.buffer1 = newBuffer1;
    this.buffer2 = newBuffer2;
    mix = 0.5f;
    phase = 0;
    one_over_sr = 1f / context.getSampleRate();
  }
  public MorphingWavePlayer(AudioContext context, UGen frequencyController,
      Buffer newBuffer1, Buffer newBuffer2) {
    this(context, newBuffer1, newBuffer2);
    setFrequency(frequencyController);
  }
  public MorphingWavePlayer(AudioContext context, float frequency, Buffer newBuffer1, Buffer newBuffer2) {
    this(context, newBuffer1, newBuffer2);
    setFrequency(frequency);
  }

  public void start() {
    super.start();
    phase = 0;
  }

  // this is the key to this object
  // overriding the calculateBuffer routine allows us to calculate new audio data and pass it back to the calling program
  @Override public void calculateBuffer()
  {
    frequencyEnvelope.update();
    
    if( mixEnvelope != null ) mixEnvelope.update();
    float inverseMix = 1.0f - mix;
    
    float[] bo = bufOut[0];
    if (phaseEnvelope == null)
    {
      for (int i = 0; i < bufferSize; i++)
      {
        frequency = frequencyEnvelope.getValue(0, i);
        if( mixEnvelope != null )
        {
          mix = mixEnvelope.getValue(0, i);
          inverseMix = 1.0f - mix;
        }
        phase = (((phase + frequency * one_over_sr) % 1.0f) + 1.0f) % 1.0f;
        bo[i] = (mix * buffer1.getValueFraction((float) phase)) + (inverseMix * buffer2.getValueFraction((float) phase));
      }
    }
    else
    {
      phaseEnvelope.update();
      
      for (int i = 0; i < bufferSize; i++)
      {
        if( mixEnvelope != null )
        {
          mix = mixEnvelope.getValue(0, i);
          inverseMix = 1.0f - mix;
        }
        bo[i] = (mix * buffer1.getValueFraction(phaseEnvelope.getValue(0, i))) + (inverseMix * buffer2.getValueFraction(phaseEnvelope.getValue(0, i))) ;
      }
    }
  }

  @Deprecated
  public UGen getFrequencyEnvelope() {
    return frequencyEnvelope;
  }
  public UGen getFrequencyUGen() {
    if (isFreqStatic) {
      return null;
    } else {
      return frequencyEnvelope;
    }
  }
  public float getFrequency() {
    return frequency;
  }

  @Deprecated
  public void setFrequencyEnvelope(UGen frequencyEnvelope) {
    setFrequency(frequencyEnvelope);
  }
  public MorphingWavePlayer setFrequency(UGen frequencyUGen) {
    if (frequencyUGen == null) {
      setFrequency(frequency);
    } else {
      this.frequencyEnvelope = frequencyUGen;
      isFreqStatic = false;
    }
    return this;
  }
  public MorphingWavePlayer setFrequency(float frequency) {
    if (isFreqStatic) {
      ((beads.Static) frequencyEnvelope).setValue(frequency);
    } else {
      frequencyEnvelope = new beads.Static(context, frequency);
      isFreqStatic = true;
    }
    this.frequency = frequency;
    return this;
  }
  
  // these two routines control access to the mix parameter
  public UGen getMixUGen() {
    if (isMixStatic) {
      return null;
    } else {
      return mixEnvelope;
    }
  }
  public float getMix() {
    return mix;
  }

  // these two routines give access to the mix parameter via float or UGen
  public MorphingWavePlayer setMix(UGen mixUGen) {
    if (mixUGen == null) {
      setMix(mix);
    } else {
      this.mixEnvelope = mixUGen;
      isMixStatic = false;
    }
    return this;
  }
  public MorphingWavePlayer setMix(float newMix) {
    if (isMixStatic) {
      ((beads.Static) mixEnvelope).setValue(newMix);
    } else {
      mixEnvelope = new beads.Static(context, newMix);
      isMixStatic = true;
    }
    this.mix = newMix;
    return this;
  }

  @Deprecated
  public UGen getPhaseEnvelope() {
    return phaseEnvelope;
  }
  public UGen getPhaseUGen() {
    return phaseEnvelope;
  }
  public float getPhase() {
    return (float) phase;
  }

  @Deprecated
  public void setPhaseEnvelope(UGen phaseEnvelope) {
    setPhase(phaseEnvelope);
  }
  public MorphingWavePlayer setPhase(UGen phaseController) {
    this.phaseEnvelope = phaseController;
    if (phaseController != null) {
      phase = phaseController.getValue();
    }
    return this;
  }
  public MorphingWavePlayer setPhase(float phase) {
    this.phase = phase;
    this.phaseEnvelope = null;
    return this;
  }

  // GET / SET BUFFER1
  public MorphingWavePlayer setBuffer1(Buffer b) {
    this.buffer1 = b;
    return this;
  }
  public Buffer getBuffer1() {
    return this.buffer1;
  }

  // get / set buffer2
  public MorphingWavePlayer setBuffer2(Buffer b) {
    this.buffer2 = b;
    return this;
  }
  public Buffer getBuffer2() {
    return this.buffer2;
  }
  


}
