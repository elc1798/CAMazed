import processing.video.*;
import java.util.PriorityQueue;
import java.util.Comparator;

class Node {
  public int r;
  public int c;

  public double cost;
  public double tailCost;
  public double headCost;

  private Node parent;

  public Node() {
    r = -1;
    c = -1;
    tailCost = 0.0;
    headCost = 0.0;
    cost = tailCost + headCost;
    parent = null;
  }

  public Node(int x, int y) {
    r = x;
    c = y;
    tailCost = 0.0;
    headCost = 0.0;
    cost = tailCost + headCost;
    parent = null;
  }

  public void setParent(Node n) {
    parent = n;
  }

  public Node getParent() {
    return parent;
  }

  public String toString() {
    return r + "|" + c + "|" + cost;
  }

  public int compareTo(Node n) {
    return (int)(1000000.0 * (this.cost - n.cost));
  }
}

class MazeHeap {

  private static final int START_SIZE = 2;

  private Node[] q;
  private int size;

  public MazeHeap() {
    q = new Node[START_SIZE];
    q[0] = null;
    size = 0;
  }

  public void add(Node n) {
    if (size == q.length - 1) {
      doubleArraySize();
    }
    int position = ++size;
    for (/* No initializer */; position > 1 && n.compareTo(q[getParent(position)]) < 0; position = position / 2) {
      q[position] = q[getParent(position)];
    }
    q[position] = n;
  }

  public Node pop() {
    if (size == 0) {
      return null;
    }
    Node retVal = q[1];
    q[1] = q[size--];
    percolateDownwards(1);
    return retVal;
  }

  public Node[] toArray() {
    return q;
  }

  public boolean empty() {
    return size == 0;
  }

  private void percolateDownwards(int index) {
    Node tmp = q[index];
    int child;
    for (/* No initializer */; 2 * index <= size; index = child) {
      child = getLeftChild(index);
      if (child != size && q[child].compareTo(q[child + 1]) > 0) {
        child++;
      }
      if (tmp.compareTo(q[child]) > 0) {
        q[index] = q[child];
      } else {
        break;
      }
    }
    q[index] = tmp;
  }

  private void doubleArraySize() {
    Node[] tmp = new Node[q.length * 2];
    System.arraycopy(q, 1, tmp, 1, size);
    q = tmp;
  }

  private int getLeftChild(int i) {
    return i * 2;
  }

  private int getRightChild(int i) {
    return i * 2 + 1;
  }

  private int getParent(int i) {
    return i / 2;
  }
}

final float COLOR_DETECTION_THRESHOLD = 25.0;

Capture cap;
final color start = color(0, 0, 230);
final color end = color(230, 0, 0);
final color wall = color(25, 25, 25);
final color path = color(230, 230, 230);
final color walker = color(255, 0, 0);

Node finishNode;

void setup() {
  size(800, 600);
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

double distance(Node n1 , Node n2) {
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
        new Node(current.r - 1 , current.c - 1),
        new Node(current.r - 1 , current.c + 1),
        new Node(current.r + 1 , current.c - 1),
        new Node(current.r + 1 , current.c + 1)
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
    // Draw out the final path 
  }
}

void draw() {
  cap.loadPixels();
  image(cap, 0, 0);
  loadAStar(AStar());
}

