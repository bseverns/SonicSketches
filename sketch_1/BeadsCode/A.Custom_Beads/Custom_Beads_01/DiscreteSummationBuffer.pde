// DiscreteSummationBuffer.pde
// this is a custom Buffer class that implements the Discrete Summation equations
// as outlines by Moorer, with the Dodge & Jerse modification

// if you want this code to compile within the Beads source, then you would use these includes
//import net.beadsproject.beads.data.Buffer;
//import net.beadsproject.beads.data.BufferFactory;

import beads.Buffer;
import beads.BufferFactory;

public class DiscreteSummationBuffer extends BufferFactory
{
  // this is the generic form of generateBuffer that is required by Beads
  public Buffer generateBuffer(int bufferSize)
  {
    return generateBuffer(bufferSize, 10, 0.9f); // are these good default values?
  }
  // this is a fun version of generateBuffer that will allow us to really employ the Discrete Summation equation
  public Buffer generateBuffer(int bufferSize, int numberOfHarmonics, float amplitude)
  {
    Buffer b = new Buffer(bufferSize);
    
    double amplitudeCoefficient = amplitude / (2.0 * (double)numberOfHarmonics);
    double theta = 0.0;
    double delta = (double)(2.0 * Math.PI) / (double)b.buf.length;
    for( int j = 0; j < b.buf.length; j++ )
    {
      //increment theta
      // we do this first, because the discrete summation equation runs from 1 to n, not from 0 to n-1 ...this is important
      theta += delta;
      
      // do the math with double precision (64-bit) then cast to a float (32-bit) ... this is probably unnecessary if we want to worry about memory (nom nom nom)
      double numerator = (double)Math.sin( (double)(theta / 2.0) * ((2.0 * (double)numberOfHarmonics) + 1.0) );
      double denominator = (double)Math.sin( theta / 2.0);
      float newValue = (float)(amplitudeCoefficient * ((numerator / denominator) - 1.0));
      
      // set the value for the new buffer
      b.buf[j] = newValue;
    }
    return b;
  }

  // we must implement this method when we inherit from BufferFactory
  public String getName() {
    return "DiscreteSummation";
  }

};
