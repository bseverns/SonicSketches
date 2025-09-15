/*
Sends MIDI info on "click" based on "brightest pixel"//presenceSum
 */

////////////////////////////// libraries ///////////////////////////////
import themidibus.*;
import processing.video.*;

///////////////////////////Video variables////////////////////////
Capture video;
int numPixels;
int[] backgroundPixels;
// Last brightest coordinates
int lastX = 0;
int lastY = 0;
int off = 0;
int exRound = 0;
int lastMes = 0;



///////////////////////////// MIDI /////////////////////////////////////////
MidiBus bus1;
MidiBus bus2;
boolean play = false;

///////////////////////////////// Setup //////////////////////////////////////
void setup() {
  size(400, 400);
  background(0);

  // MIDI inputs and outputs
  //MidiBus.list();
  // Instantiate the MidiBus
  bus1 = new MidiBus(this, 0, "Bus 1");
  bus2 = new MidiBus(this, 1, "Bus 2");

  //VIDEO STUFF
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height);
  video.start();  
  noStroke();
  smooth();
  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  loadPixels();
  frameRate(5);
}

///////////////////////////////////// Draw //////////////////////////////////////////
void draw() {
  if (video.available()) {
    video.read();
    bright();
  }
}

////////////////// Toggle playing -- eventually arduino.""Read ////////////////////////
void mousePressed() {
  play = !play;
  video.loadPixels();
  arrayCopy(video.pixels, backgroundPixels);
  if (play==false) {
    bus2.sendNoteOn(2, off, 127);
  }
}

void bright() {

  video.loadPixels(); // Make the pixels of video available
  // Difference between the current frame and the stored background
  int presenceSum = 0;

  for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
    // Fetch the current color in that location, and also the color
    // of the background in that spot
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
    // Render the difference image to the screen
    //pixels[i] = color(diffR, diffG, diffB);
    // The following line does the same thing much faster, but is more technical
    pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
  }
  updatePixels(); // Notify that the pixels[] array has changed
  //println(presenceSum); // Print out the total amount of movement
  int msgMap = int(map(presenceSum, 1000000, 40000000, 0, 450));
  int msg2 = int(map(msgMap, 0, 450, 0, 200));
  if (msg2 != lastMes) {
    if (msg2>=75) {
      bus2.sendNoteOn(2, msg2, 127);
      println("dif");
      println(msg2);
      lastMes = msg2;
    }
  }


  //////////////////////////////BrightnessTracker///////////////////////////////
  //START WITH BRIGHTEST PIXEL TRACKKING TO GET CV MESSAGE for OSC CV/VCO Gate
  int brightestX = 0; // X-coordinate of the brightest video pixel
  int brightestY = 0; // Y-coordinate of the brightest video pixel
  float brightestValue = 0; // Brightness of the brightest video pixel

  // Search for the brightest pixel: For each row of pixels in the video image and
  // for each pixel in the yth row, compute each pixel's index in the video
  //video.loadPixels();
  int index = 0;



  //////////////////ANALYZE PIXELS for brightest//////////////////////////
  video.loadPixels(); // Make the pixels of video available

  for (int y = 0; y < video.height; y++) {
    for (int x = 0; x < video.width; x++) {
      // Get the color stored in the pixel
      int pixelValue = video.pixels[index];
      // Determine the brightness of the pixel
      float pixelBrightness = brightness(pixelValue);
      // If that value is brighter than any previous, then store the
      // brightness of that pixel, as well as its (x,y) location
      if (pixelBrightness > brightestValue) {
        brightestValue = pixelBrightness;
        brightestY = y;
        brightestX = x;
      }

      //update index int
      index++;
    }
  }

  // Determine the MIDInotePitch based brightestPixel position
  float p = 60; 
  float x = (float(brightestX) / width) * 20;
  float y = (float(brightestY) / height) * 20;
  int pitch = int(p + x + y);

  //Set MIDI to Bus1
  if ((brightestX != lastX || brightestY != lastY) && play) {
    bus1.sendNoteOn(1, pitch, 127);
    println("GO");
    println(brightestX);
    println(brightestY);
    println("PITCH");
    println(pitch);
  }

  //housekeeping for brightestTracking
  lastX = brightestX;
  lastY = brightestY;
  // Delay .1 seconds to prevent madness
  delay(100);
}
