// MIDI_01.pde

// this is a basic MIDI example
// it is based in part on the MultipleBuses example from the mide bus library

import themidibus.*; //Import the MidiBus library

MidiBus busA; //The first MidiBus

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
  
  background(0); // set the background to black
  text("This program will not do anything if you do not have a MIDI device", 100, 100); // tell the user what to do!
  text("connected to your computer.", 100, 112); // tell the user what to do!
  text("This program simply displays Note-On messages and Note-Off Messages.", 100, 124); // tell the user what to do!
}

void draw() {}

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
}


