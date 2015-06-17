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
PImage frozen;
BufferedImage detectorBuffer;
MazeSolver solver;
boolean regularDisplay;
boolean generate;
int[] startCoor;
int[] endCoor;

void setup() {
  size(480, 360);
  selectorMode = -1;
  detector = new EdgeDetector();
  solver = new MazeSolver();
  walker = color(225, 0, 0);
  regularDisplay = true;
  generate = false;
  detector.setLowThreshold(0.5f);
  detector.setHighThreshold(1f);
  edges = createImage(width, height, RGB);
  start = createImage(width, height, RGB);
  end = createImage(width, height, RGB);
  frame = createImage(width, height, RGB);
  frozen = createImage(width, height, RGB);
  cap = new Capture(this, width, height, 18); // Start VideoCapture at 18 frames/second
  cap.start();
}

void captureEvent(Capture cap) {
  cap.read();
}

void loadStart(PImage img) {
  start = createImage(img.width, img.height, RGB);
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      color tColor = img.pixels[x + y * img.width];
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

void loadEnd(PImage img) {
  end = createImage(img.width, img.height, RGB);
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      color tColor = img.pixels[x + y * img.width];
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

void loadEdges(PImage img) {
  frame = createImage(width, height, RGB);
  frame.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
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
    frozen.copy(cap, 0, 0, cap.width, cap.height, 0, 0, cap.width, cap.height);
  } else {
    if (generate) {
      loadStart(frozen.get());
      loadEnd(frozen.get());
      loadEdges(frozen.get());
      PImage combine = createImage(width , height , RGB);
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          int white = (int)(red(start.pixels[x + y * start.width]) + red(end.pixels[x + y * end.width]) + red(edges.pixels[x + y * end.width]));
          if (white == 0) {
            combine.pixels[x + y * combine.width] = color(0 , 0 , 0);
          } else {
            combine.pixels[x + y * combine.width] = color(255 , 255 , 255);
          }
        }
      }
      image(start , 0 , 0);
    } else {
      image(frozen , 0 , 0);
    }
  }
}

void keyPressed() {
  switch (key) {
  case 's':
    selectorMode = 0;
    System.out.println("Select the start point color ");
    regularDisplay = false;
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
  case 'r':
    regularDisplay = true;
    generate = false;
    selectorMode = -1;
    break;
  default:
    System.out.println("Invalid key!");
  }
}

void mousePressed() {
  if (generate) {
    return; // Exit immediately if already generating
  }
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY * cap.width;
  if (selectorMode == 0) {
    startColor = cap.pixels[loc];
    regularDisplay = false;
    generate = false;
    selectorMode = 1;
  } else if (selectorMode == 1) {
    endColor = cap.pixels[loc];
    endCoor = new int[] {
      mouseX, mouseY
    };
    selectorMode = -1;
    regularDisplay = false;
    generate = true;
  }
}

