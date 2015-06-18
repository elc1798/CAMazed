public class Node {
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
