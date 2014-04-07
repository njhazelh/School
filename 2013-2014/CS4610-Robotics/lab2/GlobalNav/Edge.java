package l2;

import java.io.*;
import java.util.*;
import java.awt.Point;

public class Edge {
	double weight;
	Node target;

	public Edge(double w, Node t) {
		weight = w;
		target = t;
	}

	public boolean intersectObstacleHuh(ArrayList<Obstacle> oList, Node n) {
		boolean result = false;
		for (int i = 0; i < oList.size(); i++) {
			Obstacle o = oList.get(i);
			result = o.intersectedBy(this, n) || result;
		}
		return result;
	}

	public String toString(){
		return String.valueOf(weight);
	}

}