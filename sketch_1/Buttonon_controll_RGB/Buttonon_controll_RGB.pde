/*This portion of the program uses the button controls the 
 LED that you added on
 */

int buttonPin = 7;    //the button is connected to pin 7
int ledPin = 3   ;    //LED's connected to pin 13
int buttonStatus;    //variable We'll use to store the button s status

void setup( ) {
  pinMode(buttonPin, INPUT);    // initialize the buttonPin as input
  pinMode(ledPin, OUTPUT);    //the led is an output
}

void loop( )  {
  /* First read the satus of the button
   HIGH = button is NOT pressed
   LOW = button IS pressed*/
  buttonStatus = digitalRead(buttonPin);

  if (buttonStatus == LOW) {
    digitalWrite(ledPin, HIGH);    //If the button is pressed turn theLED on
  }
  else{
    digitalWrite(ledPin, LOW);    //Otherwise, turn it off

  }
}

