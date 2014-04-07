package l2;

import java.io.*;
import java.util.*;
import java.awt.Point;
import java.awt.geom.Point2D;

public class Map {
	Vertex goal;
	Obstacle arena;
	ArrayList<Obstacle> obstacles;

	public Map(Vertex g, Obstacle a, ArrayList<Obstacle> o) {
		goal = g;
		arena = a;
		obstacles = o;
	}

	public Map() {
		goal = new Vertex(0f, 0f);
		arena = new Obstacle(0f, 0f, 0f, 0f);
		obstacles = new ArrayList<Obstacle>();
	}

	//creates a map object given a txtfile, should it i have an intance map, that creates 
	// and empty goal
	static Map create(String txtFile) {

		Map map2 = new Map();

		try{

  			FileReader fr = new FileReader(txtFile);
  			BufferedReader bufferedReader = new BufferedReader(fr);
  			List<List> lines = new ArrayList<List>();
  			String line;
  			// Coordinated c = new Coordinated(0.0, 1.0);
  			//create a an array of lines, and then seperate doubles into array
  			//take that returned array, place the 0 in goal
  			//place 1 as boundry
  			//loop through rest return and obstacles array.
        	while ((line = bufferedReader.readLine()) != null) {
        		List<Float> map_object = new ArrayList<Float>();
        		Scanner	s = new Scanner(line);
        		while(s.hasNext()) {
        			map_object.add(Float.parseFloat(s.next()));
        		}
        		lines.add(map_object);
        	}
        	bufferedReader.close();



        	//must have goal point
        	
        	// List goalRaw;
        	List<Float> goalRaw = lines.get(0);
        	Vertex goal = new Vertex(goalRaw.get(0), goalRaw.get(1));
        	// Point2D goal = new Point2D.Float(goalRaw.get(0), goalRaw.get(1));


        	// Arena - must have
        	List<Float> arenaRaw = lines.get(1);
        	Obstacle arena = new Obstacle(arenaRaw.get(0), arenaRaw.get(1), arenaRaw.get(2), arenaRaw.get(3));

        	//loop through the rest of list of lists, add each line as an obstacle
        	ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

			for (int i = 2; i < lines.size(); i++) {
				List<Float> obstacleRaw = lines.get(i);
				Obstacle obstacle = new Obstacle(obstacleRaw.get(0), obstacleRaw.get(1), obstacleRaw.get(2), obstacleRaw.get(3));
				obstacles.add(obstacle);
			}	

			//create the new map Object = this function should return a map object
			Map map = new Map(goal, arena, obstacles);
			return map;
		}catch(IOException e){
  			e.printStackTrace();
		}

		return map2;

	}

	// takes a number to expand obstacles by
	public Map expand(float num){
		List<Obstacle> oList = this.obstacles;

		for (int i = 0; i < oList.size(); i++) {
			Obstacle o = oList.get(i);
			o.expand(num);
		}

		return this;

	}

	public ArrayList<Vertex> listVertices() {
		List<Obstacle> oList = this.obstacles;
		ArrayList<Vertex> vertices = new ArrayList<Vertex>();

		vertices.add(goal);
		vertices.add(new Vertex(0, 0));

		for (int i = 0; i < oList.size(); i++) {
			Obstacle o = oList.get(i);
			List<Vertex> v = o.toVertices();
			vertices.addAll(v);
		}
		return vertices;
	}

	public ArrayList<Node> listNodes(ArrayList<Vertex> vList){
		ArrayList<Node> nodes = new ArrayList<Node>();

		for (int i = 0; i < vList.size(); i++) {
			Vertex v = vList.get(i);
			Node n = new Node(v);
			nodes.add(n);
		}

		return nodes;

	}

	public ArrayList<Obstacle> listObstacles() {
		return obstacles;
	}


	public String toString(){
		return "Goal[" + goal + "] " + "Arena[" + arena + "] " + obstacles;
	}
}



