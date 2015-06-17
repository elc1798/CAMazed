import processing.video.*;
import java.awt.image.BufferedImage;

// Color variables
color startColor;
color endColor;
color walker;
int selectorMode;
float COLOR_DETECTION_THRESHOLD;

Capture cap;
EdgeDetector detector;
PImage edges;
PImage start;
PImage end;
PImage frame;
BufferedImage detectorBuffer;
boolean regularDisplay;
boolean freeze;


void setup() {
  size(480, 360);
  selectorMode = -1;
  detector = new EdgeDetector();
  walker = color(225, 0, 0);
  regularDisplay = true;
  freeze = false;
  detector.setLowThreshold(0.5f);
  detector.setHighThreshold(1f);
  edges = createImage(width, height, RGB);
  start = createImage(width, height, RGB);
  end = createImage(width, height, RGB);
  frame = createImage(width, height, RGB);
  cap = new Capture(this, width, height, 18); // Start VideoCapture at 18 frames/second
  cap.start();
}

void captureEvent(Capture cap) {
  cap.read();
}

void loadStart() {
  start = createImage(cap.width, cap.height, RGB);
  for (int x = 0; x < cap.width; x++) {
    for (int y = 0; y < cap.height; y++) {
      color tColor = cap.pixels[x + y * cap.width];
      float tRedDiff = abs(red(tColor) - red(startColor));
      float tGreenDiff = abs(green(tColor) - green(startColor));
      float tBlueDiff = abs(blue(tColor) - blue(startColor));
      if (tRedDiff < COLOR_DETECTION_THRESHOLD && tGreenDiff < COLOR_DETECTION_THRESHOLD && tBlueDiff < COLOR_DETECTION_THRESHOLD) {
        start.pixels[x + y * start.width] = color(255, 255, 255); // Absolute White
      } else {
        start.pixels[x + y * start.width] = color(0, 0, 0); // Absolute black
      }
    }
  }
  for (int i = 0; i < 3; i++) {
    // Blur the image afterwards
    start.filter(BLUR, 2);
  }
  // Invert Image
  start.filter(INVERT);
}

void loadEnd() {
  end = createImage(cap.width, cap.height, RGB);
  for (int x = 0; x < cap.width; x++) {
    for (int y = 0; y < cap.height; y++) {
      color tColor = cap.pixels[x + y * cap.width];
      float tRedDiff = abs(red(tColor) - red(endColor));
      float tGreenDiff = abs(green(tColor) - green(endColor));
      float tBlueDiff = abs(blue(tColor) - blue(endColor));
      if (tRedDiff < COLOR_DETECTION_THRESHOLD && tGreenDiff < COLOR_DETECTION_THRESHOLD && tBlueDiff < COLOR_DETECTION_THRESHOLD) {
        end.pixels[x + y * start.width] = color(255, 255, 255); // Absolute White
      } else {
        end.pixels[x + y * start.width] = color(0, 0, 0); // Absolute black
      }
    }
  }
  for (int i = 0; i < 3; i++) {
    // Blur the image afterwards
    end.filter(BLUR, 2);
  }
  // Invert Image
  end.filter(INVERT);
}

void loadEdges() {
  frame = createImage(width, height, RGB);
  frame.copy(cap, 0, 0, cap.width, cap.height, 0, 0, cap.width, cap.height);
  detector.setSourceImage((BufferedImage)frame.getNative());
  detector.process();
  detectorBuffer = detector.getEdgesImage();
  edges = new PImage(detectorBuffer);
  start.filter(BLUR, 2);
  // Invert Image
  edges.filter(INVERT);
}

void draw() {
  cap.loadPixels();
  if (regularDisplay) {
    image(cap, 0, 0);
  } else {
    
  }
}

void keyPressed() {
  switch (key) {
  case 's':
    selectorMode = 0;
    System.out.println("Select the start point color ");
    keepDrawing = true;
    break;
  case 'e':
    selectorMode = 1;
    System.out.println("Select the end point color ");
    break;
  case 'p':
    System.out.println("[Starting point RGB]");
    System.out.printf("%4f , %4f , %4f\n", red(startColor), green(startColor), blue(startColor));
    System.out.println("[ Ending point RGB ]");
    System.out.printf("%4f , %4f , %4f\n", red(endColor), green(endColor), blue(endColor));
    break;
  case ESC:
    selectorMode = -1;
    break;
  case r:
    regularDisplay = true;
    freeze = false;
    selectorMode = -1;
    break;
  default:
    System.out.println("Invalid key!");
  }
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY * cap.width;
  if (selectorMode == 0) {
    startColor = cap.pixels[loc];
    regularDisplay = false;
    freeze = true;
    selectorMode = 1;
  } else if (selectorMode == 1) {
    trackColorEND = cap.pixels[loc];
    endCoor = new int[] {
      mouseX, mouseY
    };
    selectorMode = -1;
  }
}

