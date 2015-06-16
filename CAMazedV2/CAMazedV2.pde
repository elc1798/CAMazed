import processing.video.*;
import java.awt.image.BufferedImage;

// Color variables
color startColor;
color endColor;
color walker = color(225, 225, 0);
boolean selectorMode;
float COLOR_DETECTION_THRESHOLD;

Capture cap;
EdgeDetector detector = new EdgeDetector();
PImage edges;
PImage start;
PImage end;
PImage frame;
BufferedImage detectorBuffer;

void setup() {
  size(480, 360);
  detector.setLowThreshold(0.5f);
  detector.setHighThreshold(1f);
  edges = createImage(width, height, RGB);
  start = createImage(width, height, RGB);
  end = createImage(width, height, RGB);
  frame = createImage(width, height, RGB);
  cap = new Capture(this, width, height);
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
    for (int x = 0; x < start.width; x++) {
      for (int y = 0; y < start.height; y++) {
        color tColor = start.pixels[x + y * start.width];
        // Get surrounding colors
        int energy = 0;
        try {
          energy += (int)red(start.pixels[x + 1 + y * start.width]) / 255;
          energy += (int)red(start.pixels[x - 1 + y * start.width]) / 255;
          energy += (int)red(start.pixels[x + (y + 1) * start.width]) / 255;
          energy += (int)red(start.pixels[x + (y - 1) * start.width]) / 255;
          energy += (int)red(start.pixels[x + 1 + (y + 1) * start.width]) / 255;
          energy += (int)red(start.pixels[x + 1 + (y - 1) * start.width]) / 255;
          energy += (int)red(start.pixels[x - 1 + (y + 1) * start.width]) / 255;
          energy += (int)red(start.pixels[x - 1 + (y - 1) * start.width]) / 255;
        } 
        catch(Exception e) {
          // Do nothing. This prevents the changing of pixels on the edge
        }
        if (energy <= 4) {
          start.pixels[x + y * start.width] = color(0, 0, 0); // Absolute White
        }
      }
    }
  }
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
    for (int x = 0; x < end.width; x++) {
      for (int y = 0; y < end.height; y++) {
        color tColor = end.pixels[x + y * start.width];
        // Get surrounding colors
        int energy = 0;
        try {
          energy += (int)red(end.pixels[x + 1 + y * end.width]) / 255;
          energy += (int)red(end.pixels[x - 1 + y * end.width]) / 255;
          energy += (int)red(end.pixels[x + (y + 1) * end.width]) / 255;
          energy += (int)red(end.pixels[x + (y - 1) * end.width]) / 255;
          energy += (int)red(end.pixels[x + 1 + (y + 1) * end.width]) / 255;
          energy += (int)red(end.pixels[x + 1 + (y - 1) * end.width]) / 255;
          energy += (int)red(end.pixels[x - 1 + (y + 1) * end.width]) / 255;
          energy += (int)red(end.pixels[x - 1 + (y - 1) * end.width]) / 255;
        } 
        catch(Exception e) {
          // Do nothing. This prevents the changing of pixels on the edge
        }
        if (energy <= 4) {
          end.pixels[x + y * start.width] = color(0, 0, 0); // Absolute White
        }
      }
    }
  }
}

void loadEdges() {
  frame = createImage(width, height, RGB);
  frame.copy(cap, 0, 0, cap.width, cap.height, 0, 0, cap.width, cap.height); 
  detector.setSourceImage((BufferedImage)frame.getNative());
  detector.process();
  detectorBuffer = detector.getEdgesImage();
  edges = new PImage(detectorBuffer);
  for (int x = 0; x < end.width; x++) {
    for (int y = 0; y < end.height; y++) {
      color tColor = end.pixels[x + y * start.width];
      // Get surrounding colors
      int energy = 0;
      try {
        energy += (int)red(end.pixels[x + 1 + y * end.width]) / 255;
        energy += (int)red(end.pixels[x - 1 + y * end.width]) / 255;
        energy += (int)red(end.pixels[x + (y + 1) * end.width]) / 255;
        energy += (int)red(end.pixels[x + (y - 1) * end.width]) / 255;
        energy += (int)red(end.pixels[x + 1 + (y + 1) * end.width]) / 255;
        energy += (int)red(end.pixels[x + 1 + (y - 1) * end.width]) / 255;
        energy += (int)red(end.pixels[x - 1 + (y + 1) * end.width]) / 255;
        energy += (int)red(end.pixels[x - 1 + (y - 1) * end.width]) / 255;
      } 
      catch(Exception e) {
        // Do nothing. This prevents the changing of pixels on the edge
      }
      if (energy <= 4) {
        end.pixels[x + y * start.width] = color(0, 0, 0); // Absolute White
      }
    }
  }
  // Invert Image
  edges.filter(INVERT);
}

void draw() {
  cap.loadPixels();
  loadEdges();
  image(edges, 0, 0);
}
