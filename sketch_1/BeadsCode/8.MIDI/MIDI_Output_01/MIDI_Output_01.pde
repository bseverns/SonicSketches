// MIDI_Output_01.pde

// As of this writing, Beads doesn't include functions for MIDI output
// Hence, this example doesn't relate to Beads, it's simply a demonstration of how to use The MIDI Bus to send 
// MIDI messages. It's based on the Basic.pde example from The MIDI Buss

import themidibus.*; // Import the midibus library
MidiBus myBus; // declare The MidiBus

void setup()
{
  size(600, 400);
  background(0);

  // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  myBus = new MidiBus(this, -1, "Java Sound Synthesizer");
  
  background(0); // set the background to black
  text("This program plays random MIDI notes using the Java Sound Synthesizer.", 100, 100); // tell the user what to do!
}

void draw()
{
  int channel = 0;
  int pitch = 48 + (int)random(48);
  int velocity = 64 + (int)random(64);
	
  myBus.sendNoteOn(channel, pitch, velocity); // start a midi pitch
  delay(100); // wait for 100ms
  myBus.sendNoteOff(channel, pitch, velocity); // then stop the note we just started
	
  // change the midi instrument
  int status_byte = 0xC0; // This is the status byte for a program change
  int byte1 = (int)random(128); // This will be the preset you are sending with your program change
  int byte2 = 0; // This is not used for program change so ignore it and set it to 0
  myBus.sendMessage(status_byte, channel, byte1, byte2); //Send the custom message

  // we could control pitch bend and other parameters using this call
  //int number = 0;
  //int value = 90;
  //myBus.sendControllerChange(channel, number, value); // Send a controllerChange
  
  delay((int)random(400)); // wait for a random amount of time less than 400ms
}
