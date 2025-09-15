int samplesPerFrame = 32;
int numFrames = 32;        
float shutterAngle = 1.0;
int[][] result;
 
void setup() {
  size(1000,1000,P3D);
  smooth(4);
  noStroke();
  result = new int[width*height][3];
}
 
void draw() {
  for (int i=0; i<width*height; i++)
    for (int a=0; a<3; a++)
      result[i][a] = 0;
 
  for (int sa=0; sa<samplesPerFrame; sa++) {
    t = map(frameCount + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
    sample();
    loadPixels();
    for (int i=0; i<pixels.length; i++) {
      result[i][0] += pixels[i] >> 16 & 0xff;
      result[i][1] += pixels[i] >> 8 & 0xff;
      result[i][2] += pixels[i] & 0xff;
    }
  }
 
  loadPixels();
  for (int i=0; i<pixels.length; i++)
    pixels[i] = 0xff << 24 | (result[i][0]/samplesPerFrame) << 16 | 
      (result[i][1]/samplesPerFrame) << 8 | (result[i][2]/samplesPerFrame);
  updatePixels();
  
  saveFrame("f##.png");
  if (frameCount==numFrames)
    exit();
}
 
float r1, r2, th1, th2, h1, h2, t, hmax = 250, rmax = 1800, pp = .9;
int N = 14, M;
 
void sample() {
  background(0);
  
  for(int i=1; i<=N; i++){
    r1 = map(pow(i,pp),0,pow(N+1,pp),0,rmax);
    r2 = map(pow(i+1,pp),0,pow(N+1,pp),0,rmax);
    h1 = map(sin(TWO_PI*i/N + TWO_PI*t),-1,1,0,hmax);
    h2 = map(sin(TWO_PI*(i+1)/N + TWO_PI*t),-1,1,0,hmax);
 
    M = int(3*pow(2,i-1));
    
    fill(map(i,1,N,255,0));
    pushMatrix();
    translate(width/2,height*2/3,-500);
    rotateX(HALF_PI*.67);
    rotateZ(TWO_PI*t/3);
    for(int j=0; j<M; j++){
      th1 = map(j,0,M,0,TWO_PI);
      th2 = map(j+1,0,M,0,TWO_PI);
      beginShape();
      vertex(r1*cos(th1), r1*sin(th1), h1);
      vertex(r1*cos(th2), r1*sin(th2), h1);
      vertex(r2*cos(.5*th1+.5*th2), r2*sin(.5*th1+.5*th2), h2);
      endShape();
    }
    popMatrix();
  }
}
