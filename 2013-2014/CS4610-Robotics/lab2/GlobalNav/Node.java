package l2;

import java.io.*;
import java.util.*;
import java.awt.Point;

public class Node implements Comparable<Node>{
	boolean visited;
	double  minDist;
	Vertex vertex;
	ArrayList<Edge> adjacentEdges;
	Node previous;

	public int compareTo(Node other)
    {
        return Double.compare(minDist, other.minDist);
    }


	public Node(boolean v, float md, ArrayList<Edge> ae, Node p, Vertex vx) {
		visited = v;
		minDist = Double.POSITIVE_INFINITY;
		adjacentEdges = ae;
		previous = p;
		vertex = vx;
	}

	public Node(Vertex vx) {
		visited = false;
		minDist = Double.POSITIVE_INFINITY;
		adjacentEdges = new ArrayList<Edge>();
		vertex = vx;
	}


	public void addEdge(Edge e){
		adjacentEdges.add(e);
	}


	public void addAllEdges(ArrayList<Node> nList, ArrayList<Obstacle> oList) {
		for (int i = 0; i < nList.size(); i++) {
			Node node = nList.get(i);
			//distance
			double w = node.vertex.distanceTo(this.vertex);
			Edge e = new Edge(w, node);
			if (!e.intersectObstacleHuh(oList, this) && !(w == 0.0)){
				this.addEdge(e);
			}
		}
	}


	public String toString(){
		return vertex.toString();
	}

}