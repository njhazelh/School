package l2;


import java.io.*;
import java.util.*;
import java.awt.Point;
import java.awt.geom.Point2D;
import java.lang.Math;

public class Vertex {
	float x;
	float y;

	public Vertex(float xC, float yC) {
		x = xC;
		y = yC;
	}

	public String toString(){
		return x + "  " + y;
	}

	public boolean equals(Vertex v){
		if ((this.x == v.x) && (this.y == v.y)){
			return true;
		}else{
			return false;
		}
	}

	public double distanceTo(Vertex v) {
		double a = Math.pow((this.x - v.x), 2) + Math.pow((this.y - v.y), 2);
		double dist = Math.sqrt(a);
		return dist;
	}
}
