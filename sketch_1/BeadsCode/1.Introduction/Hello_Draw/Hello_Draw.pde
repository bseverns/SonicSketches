// Hello_Draw.pde

// the setup routine is run once when the program starts
void setup()
{
  // create a processing window that is 400 pixels wide and 300 pixels tall
  size(400, 300);
}

// the draw routine is called repeatedly
void draw()
{
  // the line function draws a line on screen
  // width = the width of the processing sketch
  // height = the height of the processing sketch
  // (width/2, height/2) = the center of the processing sketch
  // mouseX = the current position of the mouse along the x-axis
  // mouse Y = the current position of the mouse along the y-axis
  // so this single line of code draws a single line from the center of the window to the mouse position
  // since the draw routine is run over and over again, this sketch will draw many lines, as the mouse is moved
  line(width/2, height/2, mouseX, mouseY);
}
