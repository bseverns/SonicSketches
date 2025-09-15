/* B.Severns | 2018
 MAKE SURE TO HAVE THE SWITCH "OFF" BEFORE STARTING ANYTHING!
 */

////////////////////////////// libraries ///////////////////////////////
import themidibus.*;
import processing.video.*;
import processing.serial.*;

///////////////////////////Video variables////////////////////////
Capture video;
int numPixels;
int[] backgroundPixels;
boolean bkImg = false;

//vairables for mapping bus2         CHANGE THESE TO ADJUST ACTION--->midiAMOUNT
int lowMAP = 25; // raise???
int highMAP = 220; //guh
//kill switch midi
int on = 255;
int off = 0;
//note midi
int lastMes = 0;
int msg2;

///////////////////////////// MIDI /////////////////////////////////////////
MidiBus bus1; //kill rst Midi
MidiBus bus2; //frame dif
MidiBus bus3; //kill switch

//////////////////////////// SERIAL /////////////////////////////////////////
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

///////////////////////////////// Setup //////////////////////////////////////
void setup() {
  //frameRate(10);
  size(400, 400);
  background(0);

  // Instantiate the MidiBus
  bus1 = new MidiBus(this, 0, "Bus 1");
  bus2 = new MidiBus(this, 1, "Bus 2");
  bus3 = new MidiBus(this, 2, "Bus 3");

  //VIDEO STUFF
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height); 
  noStroke();
  smooth();
  numPixels = video.width * video.height; 
  // Create array to store the background image
  backgroundPixels = new int[numPixels];  

  //Serial things       
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
}

///////////////////////////////////// Draw //////////////////////////////////////////
void draw() {
  if (myPort.available() > 0) {
    val = myPort.read();
    println("!");
  }  
  if (val == 2) { 
    bus1.sendNoteOn(2, on, 127); //RST CV on
    bus3.sendNoteOff(2, on, 127); //kill switch gonote-off
    bus3.sendNoteOn(2, off, 127); //kill switch offnote-on!!
    video.start();
    video.loadPixels();
    arrayCopy(video.pixels, backgroundPixels);
  } else if  (val == 1) {
    ///////////OFF////////////
    video.stop();
    bus1.sendNoteOn(2, off, 127); //RST CV off
    bus2.sendNoteOff(2, msg2, 127); //enable killing in the future         
      bus3.sendNoteOff(2, off, 127); //kill switch offnote-off
    bus3.sendNoteOn(2, on, 127); //kill switch goswitch-on!
  }
  if (video.available()) {
    video.read();
    dif();
  }
}


///////////////////////////////CV/MIDI SECTION/////////////////////////////////////////////
/////////////////////////////////FRAME DIF//////////////////////////////////////
void dif() {
  // Difference between the current frame and the stored background
  int presenceSum = 0;
  // For each pixel in the video frame...
  for (int i = 0; i < numPixels; i++) { 
    // Fetch the current color in that location, and also the color of the background in that spot
    color currColor = video.pixels[i];
    color bkgdColor = backgroundPixels[i];
    // Extract the red, green, and blue components of the current pixel's color
    int currR = (currColor >> 16) & 0xFF;
    int currG = (currColor >> 8) & 0xFF;
    int currB = currColor & 0xFF;
    // Extract the red, green, and blue components of the background pixel's color
    int bkgdR = (bkgdColor >> 16) & 0xFF;
    int bkgdG = (bkgdColor >> 8) & 0xFF;
    int bkgdB = bkgdColor & 0xFF;
    // Compute the difference of the red, green, and blue values
    int diffR = abs(currR - bkgdR);
    int diffG = abs(currG - bkgdG);
    int diffB = abs(currB - bkgdB);
    // Add these differences to the running tally
    presenceSum += diffR + diffG + diffB;
  }
  updatePixels(); // Notify that the pixels[] array has changed 
  /////////////////////////////NOTE VALUE -Frame Dif////////////////////////////////////////
  msg2 = int(map(presenceSum, 10000, 60000000, lowMAP, highMAP));
  //println(msg2);
  ////////////////////////////MIDI-MSG if different from previous total////////////////////////
  if (msg2 != lastMes) {
    if (msg2>=33) {
      bus2.sendNoteOn(2, msg2, 127);
      lastMes = msg2;
    }
  }
}  
