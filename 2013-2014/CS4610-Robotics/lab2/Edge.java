package l2;

import java.io.*;
import java.util.*;

//Class Edge - used to defined weighted edges in a graph

public class Edge {
	double weight;
	Node target;

	public Edge(double w, Node t) {
		weight = w;
		target = t;
	}

	//determines if the given edge with origin  intercest any obstacles contained in the list
	public boolean intersectObstacleHuh(ArrayList<Obstacle> oList, Node n) {
		boolean result = false;
		for (int i = 0; i < oList.size(); i++) {
			Obstacle o = oList.get(i);
			result = o.intersectedBy(this, n) || result;
		}
		return result;
	}	

	//converts and and edge object to human readle format
	public String toString(){
		return String.valueOf(weight);
	}
}