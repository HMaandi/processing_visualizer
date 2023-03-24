import processing.sound.*;
import peasy.*;

AudioIn in;
Amplitude amp;
FFT fft;
int bands = 512;
float[] spectrum = new float[bands];
int lowBands = 6;
int midBands = 300;
float time;
BeatDetector bd;
float oldLow;
float offset;
float sensitivity;
PeasyCam cam;
PShape shape;
PVector[][] vertices;
int res;


void setup() {
  time = 0;
  oldLow = 0;
  sensitivity = 500;
  offset = 5;
  
  cam = new PeasyCam(this, width/2, height/2, -20, 500);
  
  fullScreen(P3D);
  background(255);
  
  int inputID = -1;
  String[] devices = Sound.list();
  for (int i = 0; i<devices.length; i++) {
    if (devices[i].equals("CABLE Output (VB-Audio Virtual Cable)")) {inputID = i;}
  }
  
  fft = new FFT(this);
  Sound s = new Sound(this);
  s.inputDevice(inputID);
  
  bd = new BeatDetector(this);
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  
  
  in.start();
  fft.input(in);
  
  
  float r = 100;
  res = 40;
  vertices = new PVector[res+1][res+1];
  for (int i = 0; i < res+1; i++) {
    float lat = map(i, 0, res, 0, PI);
    for (int j = 0; j < res+1; j++) {
      float lon = map(j, 0, res, 0, TWO_PI);
      float x = sin(lat) * cos(lon);
      float y = sin(lat) * sin(lon);
      float z = cos(lat);
      vertices[i][j] = new PVector(x, y, z);
    } 
  }
  
  
}

void draw() {
  float r = 500;
  
  time += 0.003;
  float low = 0;
  float mid = 0;
  float high = 0;
  background(0);
  fft.analyze(spectrum);
  for(int i = 0; i < lowBands; i++){
    low += spectrum[i];
  } 
  for(int i = lowBands; i < midBands; i++){
    mid += spectrum[i];
  }
  for(int i = midBands; i < bands; i++){
    high += spectrum[i];
  }
  low = low/lowBands * 100;
  low = low * 30;
  low = min(low, 500);
  low = lerp(oldLow, low, 0.8);
  mid = mid/(midBands - lowBands) * 100;
  mid = mid*30;
  high = high/(bands - midBands) * 100;
  high = high * 30;
  ambientLight(100 * high, 100 * high, 100 * high);
  //ambientLight(0, 0, 0);
  translate(width/2, height/2, -20);
  rotateY(time);
  rotateX(HALF_PI);
  stroke(255, 0, 0);
  fill(255, 0, 0);
  drawBeat(low, 50, mid);
  //sphere(low);
  stroke(10 * mid);
  fill(10 * mid);
  
  sphere(1000);
  
  oldLow = low;
  }
  
  void drawBeat(float r, float offset, float noise) {
    for (int i = 0; i < res; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < res+1; j++) {
      PVector v1 = vertices[i][j];
      if (j % 2 == 0) {v1 = PVector.mult(v1,offset + r + noise*random(1,5));}
      else {v1 = PVector.mult(v1, offset + r);}
      vertex(v1.x, v1.y, v1.z);
      PVector v2 = vertices[i+1][j];
      if (j % 2 == 0) {v2 = PVector.mult(v2,offset + r + noise*random(1,3));}
      else {v2 = PVector.mult(v2, offset + r);}
      vertex(v2.x, v2.y, v2.z);
      
    }
    endShape();
  }
  }
