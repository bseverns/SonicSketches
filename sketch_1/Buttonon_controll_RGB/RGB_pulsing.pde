//Protosnap MEA course

//Our goal is to choose the color we want


int redPin = 3;    //red RGB LED
int greenPin = 5;    //green RGB LED
int bluePin = 6;    //blue RGB LED

void setup () {              /* set all LEDS as outputs */
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  
  /* In this section, you can determine the color of the LED by changing
  the values of the numbers in the parenthesis from 0-255*/
  analogWrite(redPin, 240);    //turn red LED all the way on
  analogWrite(greenPin,125);    //Turn green pin allthe way off
  analogWrite(bluePin, 0);    //turn the blue pin on  some
}

void loop ()  {  
  /* We'll use the loops to cycle the brightness of the blue LED*/
  
  /*In this "for (..." statement, you can change 3 things:
  
  1. first, the starting brightness value which is 0 right now (that means all the
  way off)
  2. second, how bright the LED gets, now the value there is 255 (which means all the
  way on)
  3. third, you can decide which LED pins are getting darker, then brighter
  just erase the "//" in front of the "analogWrite..." that are grey right now
  
  Play around with it, and get comfortable. Remember that you can always restart by not
  saving, closing, and then just reopenning the sketch.
  */
  for (int brightness= 0; brightness<= 255; brightness ++) {
    analogWrite (bluePin, brightness);
    //analogWrite (redPin, brightness);
    //analogWrite (greenPin, brightness);
    
    /*you can use one of these two delays for how long 
    between flashes (lightening strikes).
    
    1. is a set delay, and flashes reliably.
    2. uses a random value between 10 and 100, so that you don't have to decide how 
    it flashes, the microcontroller randomly chooses*/
    
    delay (12);    
    //delay (random(10, 100));
  }
}
