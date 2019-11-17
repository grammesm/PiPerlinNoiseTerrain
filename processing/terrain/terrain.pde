import processing.io.*;

// Display setup
int cols, rows;
int scl = 30;
int w = 1400;
int h = 600;
float flying = 0;

// Color vars
int redBase = 214;
int greenBase = 66;

// Terrain map
float[][] terrain;

// Terrain height related
int terrainHeight = 0; // change this with pot
int minTerrainHeight = 0; 
int maxTerrainHeight = 200;

// Speed related
float speedIncrementer = .005;
float maxSpeed = 0.2;
float minSpeed = 0.01;//01;
float speed = minSpeed; // change this with pot

// GPIO pins
final int heightClkPin = 22;
final int heightDtPin = 27;
final int speedClkPin = 24;
final int speedDtPin = 23;

void setup() {
  noCursor();
  
  // Height DT setup
  GPIO.pinMode(heightDtPin, GPIO.INPUT_PULLUP);
  // Height CLK setup
  GPIO.pinMode(heightClkPin, GPIO.INPUT_PULLUP);
  GPIO.attachInterrupt(heightClkPin, this, "clkChangeHeight", GPIO.CHANGE);
  
  // Speed DT setup
  GPIO.pinMode(speedDtPin, GPIO.INPUT_PULLUP);
  // Speed CLK setup
  GPIO.pinMode(speedClkPin, GPIO.INPUT_PULLUP);
  GPIO.attachInterrupt(speedClkPin, this, "clkChangeSpeed", GPIO.CHANGE);
  
  // Setup screen
  fullScreen(P3D);
  //size (800,480,P3D);
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
  frameRate(120);
}

void clkChangeHeight(int pin){
  if (GPIO.digitalRead(heightDtPin) != GPIO.digitalRead(heightClkPin)) {
    terrainHeight+=2;
    if (terrainHeight > maxTerrainHeight) {
      terrainHeight = maxTerrainHeight;
    }
  } else {
    terrainHeight-=2;
    if (terrainHeight < minTerrainHeight) {
      terrainHeight = minTerrainHeight;
    }
  }    
}

void clkChangeSpeed(int pin){
  if (GPIO.digitalRead(speedDtPin) != GPIO.digitalRead(speedClkPin)) {
    speed+=speedIncrementer;
    if (speed > maxSpeed) {
      speed = maxSpeed;
    }
  } else {
    speed-=speedIncrementer;
    if (speed < minSpeed) {
      speed = minSpeed;
    }
  }    
}

void draw() {
  flying -= speed;

  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff,yoff), 0, 1, -terrainHeight, terrainHeight);
      xoff += 0.1;
    }
    yoff += 0.1;
  }

  
  background(color(0, 0, 54));
  noFill();
  
  translate(width/2,height/2+(height/8));
  rotateX(PI/3);
  translate(-w/2,-h/2);
  
  int alpha = 0;
  int alphaIncrementer = (255 - alpha) / (int)((float)rows/1.5); 
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    //println("Alpha: " + alpha);
    for (int x = 0; x < cols; x++) {
      float terrainFirst = terrain[x][y];
      float terrainSecond = terrain[x][y + 1];
      
        float ratio = Math.abs(terrainFirst/(maxTerrainHeight-(maxTerrainHeight/2)));
        int red = redBase + (int)((float)(255-redBase) * ratio);
        int green = greenBase + (int)((float)(255-greenBase) * ratio);
        
      if (terrainFirst >= 0) {
        stroke(color(red,green,255, alpha));
      } else {
        int darkRed = redBase - (int)(redBase * ratio);
        int darkBlue = 255 - (int)(255 * ratio);
        int darkGreen = greenBase - (int)(greenBase * ratio);
        stroke(color(darkRed,darkGreen,darkBlue, alpha));
      }
      vertex(x*scl, y*scl, terrainFirst);
      vertex(x*scl, (y+1)*scl, terrainSecond);
    }
    alpha += alphaIncrementer;
    if (alpha > 255) {
      alpha = 255;
    }
    endShape();
  }
}
