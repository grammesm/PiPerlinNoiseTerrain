int cols, rows;
int scl = 20;
int w = 2000;
int h = 1600;
float flying = 0;

int redBase = 214;
int greenBase = 66;

float[][] terrain;

void setup() {
  size (600,600,P3D);
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
}

float speed = 0; // change this with pot
float speedIncrementer = 0.0005;
float maxSpeed = 0.2;
float minSpeed = 0.0000001;
boolean incrementing = false;

int terrainHeight = 125;

void draw() {
  flying -= speed;
  if (incrementing) {
    speed += speedIncrementer;
    if (speed > maxSpeed) {
      incrementing = false;
    }
  } else {
    speed -= speedIncrementer;
    if (speed < minSpeed) {
      incrementing = true;
    }
  }

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
  //stroke(0xff);
  noFill();
  
  translate(width/2,height/2+50);
  rotateX(PI/3);
  translate(-w/2,-h/2);
  
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float terrainFirst = terrain[x][y];
      float terrainSecond = terrain[x][y + 1];
      
        float ratio = Math.abs(terrainFirst/(terrainHeight-(terrainHeight/2)));
        int red = redBase + (int)((float)(255-redBase) * ratio);
        int green = greenBase + (int)((float)(255-greenBase) * ratio);
        
      if (terrainFirst >= 0) {
        stroke(color(red,green,255));
      } else {
        //float ratio = (Math.abs(terrainFirst/(terrainHeight-(terrainHeight/2))));
        //int blue = (int)((float)255 * ratio);
        //int green = (int)((float)255 * (1.0-ratio));
        int darkRed = redBase - (int)(redBase * ratio);
        int darkBlue = 255 - (int)(255 * ratio);
        int darkGreen = greenBase - (int)(greenBase * ratio);
        stroke(color(darkRed,darkGreen,darkBlue));
      }
      //if (terrainFirst < -terrainHeight/2) {
      //  stroke(color(52, 64, 61));
      //} else if (terrainFirst < 0) {
      //  stroke(color(102, 112, 110));
      //} else if (terrainFirst < terrainHeight/2) {
      //  stroke(color(113, 163, 154));
      //} else {
      //  stroke(color(212, 255, 244));
      //}
      vertex(x*scl, y*scl, terrainFirst);
      vertex(x*scl, (y+1)*scl, terrainSecond);
    }
    endShape();
  }
}
