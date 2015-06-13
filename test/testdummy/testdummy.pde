import processing.video.*;
import java.util.PriorityQueue;
import java.util.Comparator;

color trackColorSTART;
color trackColorEND;
color blank = color(255, 0, 0);
boolean SelectMode;


Capture cap;
final color start = color(20, 50, 125);
final color end = color(125, 10, 10);
final color wall = color(85, 85, 85);
final color path = color(180, 180, 180);
final color walker = color(255, 204, 0);

//Node finishNode;
boolean keepDrawing = true;

void setup() {
  size(640, 480);
  cap = new Capture(this, width, height);
  cap.start();
  trackColorSTART = color(255, 0, 0);
  trackColorEND = color(225, 0, 0);
}

void captureEvent(Capture cap) {
  cap.read();
}

void draw() {
  if (keepDrawing) {
    cap.loadPixels();
    image(cap, 0, 0);
    //loadAStar(AStar());
  

  float COLOR_DETECTION_THRESHOLD = 50; 
  int closestXstart = 0;
  int closestYstart = 0;
  int closestXend = 0;
  int closestYend = 0;

  for (int x = 0; x < cap.width; x ++ ) {
    for (int y = 0; y < cap.height; y ++ ) {
      int loc = x + y*cap.width;
      color currentColor = cap.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColorSTART);
      float g2 = green(trackColorSTART);
      float b2 = blue(trackColorSTART);
      float d1 = dist(r1, g1, b1, r2, g2, b2);
      if (d1 < COLOR_DETECTION_THRESHOLD) {
        COLOR_DETECTION_THRESHOLD = d1;
        closestXstart = x;
        closestYstart = y;}}
    if (COLOR_DETECTION_THRESHOLD < 10) { 
      fill(trackColorSTART);
      strokeWeight(4.0);
      stroke(0);
      ellipse(closestXstart, closestYstart, 48, 48);}
  }
 } 
}
void keyPressed() {
  switch (key) {
  case 's': 
    {
      SelectMode = true;
      trackColorSTART = blank;
      trackColorEND = blank;
      System.out.println("Select the start point color "); 
      keepDrawing = true; 
      break;
    }
  case 'e': 
    SelectMode = false; 
    System.out.println("Select the end point color "); 
    break;
    //    case 'r': trackColorSTART = blank; trackColorEND = blank; not included because 's' resets once clicked again
  case 'p': 
    {
      System.out.println("[Starting point RGB]");
      System.out.printf("%4f , %4f , %4f\n", red(trackColorSTART), green(trackColorSTART), blue(trackColorSTART));
      System.out.println("[ Ending point RGB ]");
      System.out.printf("%4f , %4f , %4f\n", red(trackColorEND), green(trackColorEND), blue(trackColorEND));
    }
  }
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*cap.width;
  if (SelectMode == true) {
    trackColorSTART = cap.pixels[loc];
    System.out.print("Start point color : ");
    System.out.printf("%4f , %4f , %4f\n", red(trackColorSTART), green(trackColorSTART), blue(trackColorSTART));
  } else {
    trackColorEND = cap.pixels[loc];
    System.out.print("End point color : ");
    System.out.printf("%4f , %4f , %4f\n", red(trackColorEND), green(trackColorEND), blue(trackColorEND));
    keepDrawing = false; //stops the camera once the end points are done
    fill(trackColorEND);
    strokeWeight(4.0);
    stroke(0);
    ellipse(mouseX, mouseY, 48, 48);
  }
}

