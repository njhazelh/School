package l2;


import java.io.*;
import java.util.*;

// A Vertex class used to represent coordinates

public class Vertex {
	float x;
	float y;

	public Vertex(float xC, float yC) {
		x = xC;
		y = yC;
	}

	//determines if two vertices are equal
	public boolean equals(Vertex v){
		return ((this.x == v.x) && (this.y == v.y));
	}

	//returns the distance between to vertices
	public double distanceTo(Vertex v) {
		double a = Math.pow((this.x - v.x), 2) + Math.pow((this.y - v.y), 2);
		double dist = Math.sqrt(a);
		return dist;
	}

	//returns human readable string represenatation of a Vertex
	public String toString(){
		return x + "  " + y;
	}
}
