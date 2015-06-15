import processing.video.*;

// Color variables
color startColor;
color endColor;
color walker = color(225 , 225 , 0);
boolean selectorMode;
float COLOR_DETECTION_THRESHOLD;

Capture cap;
PImage edges;
PImage start;
PImage end;
PImage frame;

void setup() {
  try {
    size(800 , 600);
  } catch(Exception e) {
    size(640 , 480); 
  }
  cap = new Capture(this , width , height);
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
        start[x + y * start.width] = color(255 , 255 , 255); // Absolute White
      } else {
        start[x + y * start.width] = color(0 , 0 , 0); // Absolute black 
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
        } catch(Exception e) {
          // Do nothing. This prevents the changing of pixels on the edge
        }
        if (energy <= 4) {
          start[x + y * start.width] = color(0 , 0 , 0); // Absolute White
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
        end[x + y * start.width] = color(255 , 255 , 255); // Absolute White
      } else {
        end[x + y * start.width] = color(0 , 0 , 0); // Absolute black 
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
        } catch(Exception e) {
          // Do nothing. This prevents the changing of pixels on the edge
        }
        if (energy <= 4) {
          end[x + y * start.width] = color(0 , 0 , 0); // Absolute White
        }
      }
    }
  }
}
