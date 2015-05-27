import processing.video.*;

final float COLOR_DETECTION_THRESHOLD = 25.0;

Capture cap;
color start = color(0 , 0 , 230);
color end = color(230 , 0 , 0);
color wall = color(25 , 25 , 25);
color path = color(230 , 230 , 230);
color walker = color(255 , 0 , 0);

void setup() {
  size(600 , 800);
  cap = new Capture(this , width , height);
  cap.start();
}

void captureEvent(Capture cap) {
  cap.read();
}

int[] findLoc(float R , float G , float B) {
  for (int x = 0; x < video.width; x++) {
    for (int y = 0; y < video.height; y++) {
      color pixel = cap.pixels[x + y * video.width];
      float redDiff = abs(red(pixel) - R);
      float greenDiff = abs(green(pixel) - G);
      float blueDiff = abs(blue(pixel) - B);
      if (redDiff < COLOR_DETECTION_THRESHOLD &&
          greenDiff < COLOR_DETECTION_THRESHOLD &&
          blueDiff < COLOR_DETECTION_THRESHOLD) {
          int[] retVal = {x , y};
          return retVal;
      }
    }
  }
  int[] retFailed = {-1 , -1};
  return retFailed;
}

int[] findStart() {
  return findLoc(red(start) , green(start) , blue(start));
}

int[] findEnd() {
  return findLoc(red(end) , green(end) , blue(end));
}

void AStar() {
  // Ill finish this some time within the next week or so...
}

void main() {
   cam.loadPixels();
   image(cam , 0 , 0);
   AStar();
}
