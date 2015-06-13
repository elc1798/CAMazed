import processing.video.*;
import java.util.PriorityQueue;
import java.util.Comparator;

color trackColorSTART;
color trackColorEND;
color blank;
boolean SelectMode;

final float COLOR_DETECTION_THRESHOLD = 60.0;

Capture cap;
final color start = color(20, 50, 125);
final color end = color(125, 10, 10);
final color wall = color(85, 85, 85);
final color path = color(180, 180, 180);
final color walker = color(255, 204, 0);

Node finishNode;
boolean keepDrawing = true;

void setup() {
  size(640, 480);
  cap = new Capture(this, width, height);
  cap.start();
}

void captureEvent(Capture cap) {
  cap.read();
}

int[] findLoc(float R, float G, float B) {
  for (int x = 0; x < cap.width; x++) {
    for (int y = 0; y < cap.height; y++) {
      color pixel = cap.pixels[x + y * cap.width];
      float redDiff = abs(red(pixel) - R);
      float greenDiff = abs(green(pixel) - G);
      float blueDiff = abs(blue(pixel) - B);
      if (redDiff < COLOR_DETECTION_THRESHOLD &&
        greenDiff < COLOR_DETECTION_THRESHOLD &&
        blueDiff < COLOR_DETECTION_THRESHOLD) {
        int[] retVal = {
          x, y
        };
        return retVal;
      }
    }
  }
  int[] retFailed = {
    -1, -1
  };
  return retFailed;
}

int[] findStart() {
  return findLoc(red(start), green(start), blue(start));
}

int[] findEnd() {
  return findLoc(red(end), green(end), blue(end));
}

boolean isOnPath(color c) {
  return abs(red(c) - red(path)) < COLOR_DETECTION_THRESHOLD && abs(green(c) - green(path)) < COLOR_DETECTION_THRESHOLD && abs(blue(c) - blue(path)) < COLOR_DETECTION_THRESHOLD;
}

boolean isOnStart(color c) {
  return abs(red(c) - red(start)) < COLOR_DETECTION_THRESHOLD && abs(green(c) - green(start)) < COLOR_DETECTION_THRESHOLD && abs(blue(c) - blue(start)) < COLOR_DETECTION_THRESHOLD;
}

boolean isOnEnd(color c) {
  return abs(red(c) - red(end)) < COLOR_DETECTION_THRESHOLD && abs(green(c) - green(end)) < COLOR_DETECTION_THRESHOLD && abs(blue(c) - blue(end)) < COLOR_DETECTION_THRESHOLD;
}

boolean isOnWall(color c) {
  return abs(red(c) - red(wall)) < COLOR_DETECTION_THRESHOLD && abs(green(c) - green(wall)) < COLOR_DETECTION_THRESHOLD && abs(blue(c) - blue(wall)) < COLOR_DETECTION_THRESHOLD;
}

boolean isOnWalker(color c) {
  return abs(red(c) - red(walker)) < COLOR_DETECTION_THRESHOLD && abs(green(c) - green(walker)) < COLOR_DETECTION_THRESHOLD && abs(blue(c) - blue(walker)) < COLOR_DETECTION_THRESHOLD;
}

boolean outOfBounds(Node n) {
  return n.r < 0 || n.c < 0 || n.r >= cap.height || n.c >= cap.width;
}

double distance(Node n1, Node n2) {
  return (n1.r - n2.r) * (n1.r - n2.r) + (n1.c - n2.c) * (n1.c - n2.c);
}

Node AStar() {
  int[] startCoor = findStart();
  int[] endCoor = findEnd();
  if (startCoor[0] == -1 || startCoor[1] == -1 || endCoor[0] == -1 || endCoor[1] == -1) {
    return null;
  }
  Node current = null;
  Node buffer = new Node(startCoor[0], startCoor[1]);
  MazeHeap open = new MazeHeap();
  MazeHeap closed = new MazeHeap();

  buffer.tailCost = 0.0;
  buffer.headCost = 0.0;
  buffer.cost = buffer.tailCost + buffer.headCost;
  open.add(buffer);

  Node[] children = new Node[8];

  while (!open.empty ()) {
    // Get node with priority from heap
    current = open.pop();
    closed.add(current);
    // Exit immediately if out of bounds
    if (outOfBounds(current)) {
      continue;
    }
    // Load element for easy access
    color currColor = cap.pixels[current.r + current.c * cap.width];
    // Set the current grid element to a visited element
    if (isOnPath(currColor)) {
      cap.pixels[current.r + current.c * cap.width] = walker;
    }
    if (isOnPath(currColor) || isOnStart(currColor) || isOnEnd(currColor)) {
      // Setup successors
      children = new Node[] {
        new Node(current.r - 1, current.c), 
        new Node(current.r + 1, current.c), 
        new Node(current.r, current.c - 1), 
        new Node(current.r, current.c + 1), 
        new Node(current.r - 1, current.c - 1), 
        new Node(current.r - 1, current.c + 1), 
        new Node(current.r + 1, current.c - 1), 
        new Node(current.r + 1, current.c + 1)
        };
        // Check to see if successor should be added based on priority
        for (Node n : children) {
          // If child is out of bounds or a wall or has been visited, do not process
          if (outOfBounds(n) || isOnWall(currColor) || isOnWalker(currColor)) {
            continue;
          }
          n.setParent(current);
          if (isOnEnd(currColor)) {
            finishNode = n;
            return n;
          }
          // Use costs to implement heuristics
          n.tailCost = current.tailCost + distance(current, n);
          n.headCost = (endCoor[0] - n.r) * (endCoor[0] - n.r) + (endCoor[1] - n.c) * (endCoor[1] - n.c);
          n.cost = n.tailCost + n.headCost;

          // Check if the node is best case for current position
          boolean insert = true;
          for (Node a : open.toArray ()) {
            if (a != null && a.r == n.r && a.c == n.c && a.cost < n.cost) {
              insert = false;
              break;
            }
          }
          for (Node a : closed.toArray ()) {
            if (!insert) {
              break;
            }
            if (a != null && a.r == n.r && a.c == n.c && a.cost < n.cost) {
              insert = false;
              break;
            }
          }
          if (insert) {
            open.add(n);
          }
        }
    } else {
      continue;
    }
  }
  return null;
}

void loadAStar(Node end) {
  if (end == null) {
    return;
  } else {
    PImage drawn = cap;
    image(drawn, 0, 0);
    Node tmp = end;
    fill(walker);
    strokeWeight(3.2);
    stroke(0);
    while (tmp != null) {
      ellipse(tmp.r, tmp.c, 15, 15);
      System.out.printf("%3d , %3d\n", tmp.r, tmp.c);
      tmp = tmp.getParent();
    }
    //keepDrawing = false;
    System.out.println("Done!");
  }
}

void draw() {
  
  if (keepDrawing) {
    cap.loadPixels();
    image(cap, 0, 0);
    loadAStar(AStar());
  }
}

void keyPressed() {
  switch (key) {
    case 's': SelectMode = true; System.out.println("Select the start point color "); keepDrawing = true; break;
    case 'e': SelectMode = false; System.out.println("Select the end point color "); break;
    case 'r': trackColorSTART = blank; trackColorEND = blank;
    case 'p': System.out.printf("%4f , %4f , %4f\n", red(trackColorSTART), green(trackColorSTART), blue(trackColorSTART));
  }
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*cap.width;
  if (SelectMode == true){
      trackColorSTART = cap.pixels[loc];
      System.out.print("Start point color : ");
      System.out.printf("%4f , %4f , %4f\n", red(trackColorSTART), green(trackColorSTART), blue(trackColorSTART));
  }
  else {
    trackColorEND = cap.pixels[loc];
    System.out.print("End point color : ");
    System.out.printf("%4f , %4f , %4f\n", red(trackColorEND), green(trackColorEND), blue(trackColorEND));
    keepDrawing = false; //stops the camera once the end points are done
  }  
}

