public class MazeSolver {

  /*
    A Star Pseudocode:
    
    initialize the open list
    initialize the closed list
    put the starting node on the open list (you can leave its f at zero)
    
    while the open list is not empty
        find the node with the least f on the open list, call it "q"
        pop q off the open list
        generate q's 8 successors and set their parents to q
        for each successor
          if successor is the goal, stop the search
            successor.g = q.g + distance between successor and q
            successor.h = distance from goal to successor
            successor.f = successor.g + successor.h
    
            if a node with the same position as successor is in the OPEN list \
                which has a lower f than successor, skip this successor
            if a node with the same position as successor is in the CLOSED list \ 
                which has a lower f than successor, skip this successor
            otherwise, add the node to the open list
        end
        push q on the closed list
    end
  */
  public Node AStar(PImage MAZE , int[] startCoor , int[] endCoor , color wallColor , color path) {
    PImage maze = MAZE.get();

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
      current = open.pop();
      closed.add(current);
      if (current.r < 0 || current.c < 0 || current.r >= maze.width || current.c >= maze.height) {
        continue;
      }
      color currColor = maze.pixels[current.r + current.c * maze.width];
      if (currColor != wallColor && currColor != path) {
        maze.pixels[current.r + current.c * cap.width] = path;
      }
      if (current.r == endCoor[0] && current.c == endCoor[1]) {
        return current;
      }
      if (currColor != wallColor) {
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
          for (Node n : children) {
            color tmp = maze.pixels[n.r + n.c * maze.width];
            if (tmp == wallColor || tmp == path) {
              continue;
            }
            n.setParent(current);
            if (n.r == endCoor[0] && n.c == endCoor[1]) {
              return n;
            }
            n.tailCost = current.tailCost + (current.r - n.r) * (current.r - n.r) + (current.c - n.c) * (current.c - n.c);
            n.headCost = (endCoor[0] - n.r) * (endCoor[0] - n.r) + (endCoor[1] - n.c) * (endCoor[1] - n.c);
            n.cost = n.tailCost + n.headCost;

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
}

