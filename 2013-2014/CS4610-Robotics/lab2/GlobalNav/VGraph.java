package l2;

import java.io.*;
import java.util.*;
import java.awt.Point;
import java.util.PriorityQueue;

public class VGraph {

	public static void build(ArrayList<Node> nList, ArrayList<Obstacle> oList) {
		for (int i = 0; i < nList.size(); i++) {
			Node n = nList.get(i);
			n.addAllEdges(nList, oList);
		}
	}

	public static void computePaths(Node source){
        source.minDist = 0.;
        PriorityQueue<Node> vertexQueue = new PriorityQueue<Node>();

        //goal
      	vertexQueue.add(source);

		while (!vertexQueue.isEmpty()) {
		    Node u = vertexQueue.poll();
    	    // Visit each edge exiting u
    	    for (Edge e : u.adjacentEdges){
    	        Node v = e.target;
    	        double weight = e.weight;
    	        double distanceThroughU = u.minDist + weight;
				if (distanceThroughU < v.minDist) {
			    	vertexQueue.remove(v);
			    	v.minDist = distanceThroughU ;
			    	v.previous = u;
			    	vertexQueue.add(v);
				}
    	    }
    	}
	}

	public static ArrayList<Node> getShortestPathTo(Node target){
        ArrayList<Node> path = new ArrayList<Node>();
        for (Node vertex = target; vertex != null; vertex = vertex.previous)
            path.add(vertex);

        return path;
    }

}