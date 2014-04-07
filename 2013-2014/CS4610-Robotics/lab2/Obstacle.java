package l2;

import java.io.*;
import java.util.*;
import java.awt.geom.Line2D;

//A Obstacle class, representation of a rectangle
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

	//expands an obstacle on all sides a given num
	public Obstacle expand(float num){
		this.xMin = this.xMin - num;
		this.xMax = this.xMax + num;
		this.yMin = this.yMin - num;
		this.yMax = this.yMax + num;
		return this;
	}

	// returns a list of 4 vertices which represents the object
	public List<Vertex> toVertices(){
		List<Vertex> vertices = new ArrayList<Vertex>();
		vertices.add(new Vertex(this.xMax, this.yMin));
		vertices.add(new Vertex(this.xMax, this.yMax));
		vertices.add(new Vertex(this.xMin, this.yMax));
		vertices.add(new Vertex(this.xMin, this.yMin));
		return vertices;
	}

	//Determines if the given shape is intersected by the give line
	public boolean intersectedBy(Edge e, Node n){
		Vertex p1 = n.vertex;
		Vertex p2 = e.target.vertex;
		//a small buffer to handle the lines that make of edges of the obstacles
		float b = 0.001f;

		//(x, y) upper left corner of obstacle
		Float x = this.xMin + b;
		Float y = this.yMin + b;
		Float h = this.yMax - this.yMin - b;
		Float w = this.xMax - this.xMin - b;
		
		Line2D l1 = new Line2D.Float(p1.x, p1.y, p2.x, p2.y);
		return  l1.intersects(x, y, w, h);
	}

	//human readable form of an obstacle object
	public String toString(){
		return xMin + " " + xMax + " " + yMin + " " + yMax;
	}
}