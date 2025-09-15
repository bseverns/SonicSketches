// Mouse_01.pde

// this short script just shows how we can extract information from a series of coordinates, in this case, the location of the mouse

// variables that will hold various mouse parameters
float xChange = 0;
float yChange = 0;
float lastMouseX = 0;
float lastMouseY = 0;
float meanXChange = 0.0;
float meanYChange = 0.0;

void setup()
{
  size(800, 600); // create a decent-sized window, so that the mouse has room to move
}

void draw()
{
  background(0); // fill the background with black

  // calculate how much the mouse has moved
  xChange = lastMouseX - mouseX;
  yChange = lastMouseY - mouseY;
  
  // calculate the average speed of the mouse
  meanXChange = floor((0.5 * meanXChange) + (0.5 * xChange));
  meanYChange = floor((0.5 * meanYChange) + (0.5 * yChange));
  
  // store the current mouse coordinates for use in the next round
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  
  // show the mouse parameters on screen
  text("MouseX: " + mouseX, 100, 100);
  text("Change in X: " + xChange, 100, 120);
  text("Avg. Change in X: " + meanXChange, 100, 140);
  text("MouseY: " + mouseY, 100, 160);
  text("Change in Y: " + yChange, 100, 180);
  text("Avg. Change in Y: " + meanYChange, 100, 200);
}

