// Hello_Shapes.pde

// the setup routine is run once when the program starts
void setup()
{
  // create a processing window that is 400 pixels wide and 300 pixels tall
  size(400, 300);
  
  // write the text "Hello World" in the window at the location (100, 100)
  text("Hello World", 100, 100);
  
  // draw a line from (100, 100) to (200, 200)
  line(100, 100, 200, 200);
  
  // draw an ellipse at (200, 200) with a width of 50 pixels and a height of 100 pixels
  ellipse(200, 200, 50, 100);
}
