/*This sketch controls the sound that your shack will have.
 */

void setup() {                
  // initialize the digital pin as an output.
  pinMode(2, OUTPUT);     
}

void loop() {

  /*The notes that your Protosnap can produce are controlled
   by the numbers that you put here, they can be anywhere between
   0-4000.
   
   Try these out first though, change the numbers after you've decided 
   whether you want them to be higher or lower*/

  int note1 = 200; //set minimum frequency/note for your first note
  int note2 = 400; //sets a second note
  int note3 = 100; //and the third


  /* here you can change the pace of you sounds, and what the tempo of your
   sounds are*/
  for (int i = 0; i < 5; i++){
    tone(2, note1);
    note1++;
    delay(2000);
    tone(2, note2);
    note2++;
    delay(2000);
    tone(2, note3);
    note3++;
    delay(2000);
  }
}


