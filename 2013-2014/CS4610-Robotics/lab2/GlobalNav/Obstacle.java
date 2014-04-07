package l2;

import java.io.*;
import java.util.*;
import java.awt.Point;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;

public class Obstacle {
	float xMin;
	float xMax;
	float yMin;
	float yMax;


	public Obstacle(float xM, float xMx, float yM, float yMx) {
		xMin = xM;
		xMax = xMx;
		yMin = yM;
		yMax = yMx;
	}

	public Obstacle expand(float num){
		this.xMin = this.xMin - num;
		this.xMax = this.xMax + num;
		this.yMin = this.yMin - num;
		this.yMax = this.yMax + num;
		return this;
	}

	// min max to vertices
	public List<Vertex> toVertices(){
		List<Vertex> vertices = new ArrayList<Vertex>();
		vertices.add(new Vertex(this.xMax, this.yMin));
		vertices.add(new Vertex(this.xMax, this.yMax));
		vertices.add(new Vertex(this.xMin, this.yMax));
		vertices.add(new Vertex(this.xMin, this.yMin));
		return vertices;

	}

	//Determines if a shape is intersected by the given line.
	public boolean intersectedBy(Edge e, Node n){
		Vertex p1 = n.vertex;
		Vertex p2 = e.target.vertex;

		//a small buffer to handle the lines on edges of rectangles
		float b = 0.001f;

		//upper most left 
		Float x = this.xMin + b;
		Float y = this.yMin + b;
		Float h = this.yMax - this.yMin - b;
		Float w = this.xMax - this.xMin - b;
		
		Line2D l1 = new Line2D.Float(p1.x, p1.y, p2.x, p2.y);
		return  l1.intersects(x, y, w, h);
	
	}

	public String toString(){
		return xMin + " " + xMax + " " + yMin + " " + yMax;
	}
}