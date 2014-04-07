package l2;

import ohmm.*;
import static ohmm.OHMM.*;
import ohmm.OHMM.AnalogChannel;
import static ohmm.OHMM.AnalogChannel.*;
import ohmm.OHMM.DigitalPin;
import static ohmm.OHMM.DigitalPin.*;

import java.util.*;
import java.lang.Math;

import java.io.*;

public class GlobalNav {

    public static void sendCommands(ArrayList<Node> nList, OHMMDrive ohmm) {

      //Reset Pose and pause to que
      ohmm.driveResetPose();
      ohmm.drivePause();

      float robotAngle = 0f;

      for (int i = 0; i < nList.size() - 1; i++) {

        Node nstart = nList.get(i); //current node
        Node ngoal = nList.get(i + 1); //goal node
        Vertex vstart = nstart.vertex; //current vertex
        Vertex vgoal = ngoal.vertex; //goal vertex
        float xdif = vgoal.x - vstart.x; //difference in x
        float ydif = vgoal.y - vstart.y; //difference in y
        float posAngle = 0f; 
        float negAngle = 0f;

        //can't divide ydif by 0, so add negligable amount
        //to recieve a close to exact reading
        if (xdif == 0) {
        	xdif = xdif + 0.000001f;
        }

        posAngle =  (float) Math.atan(ydif/xdif);
        negAngle =  (float) Math.atan(ydif/xdif);

    	//calculate radians of line ccw from x-axis up to 2PI radians
    	//and calculate radians of line cw from x-axis up to 2PI radians
       if( (xdif > 0) && (ydif > 0)) {
            posAngle = posAngle;

            negAngle = -(2f * 3.14159f) + negAngle;
        } else if( !(xdif > 0) && (ydif > 0)) {
            posAngle = 3.14159f + posAngle;

            negAngle = -3.14159f + negAngle;
        } else if( !(xdif > 0) && !(ydif > 0)) {
            posAngle = 3.14159f + posAngle;

            negAngle = -3.14159f + negAngle;
        } else if( (xdif > 0) && !(ydif > 0)) {
            posAngle = (2f * 3.14159f) + posAngle;
            negAngle = negAngle;
        }

        //radians to turn to reach goal in each direction
        float turnCCW = posAngle - robotAngle;
        float turnCW = negAngle - robotAngle; 

        //determine which direction to turn is shortest - CW or CCW
        if ( turnCCW < Math.abs(turnCW)) {
            ohmm.driveTurn(turnCCW);
            System.out.println("TurnCCW " + turnCCW);
        } else {
            ohmm.driveTurn(turnCW);
            System.out.println("TurnCW " + turnCW);
        }

      	//add turn radians to current robotAngle, keeps track of current
      	//robot orientation theta
        robotAngle = (robotAngle + turnCCW) % (2f * 3.14159f);
        
        //drive forward distance 
        float dist = (float) (vstart.distanceTo(vgoal)) * 1000;
        ohmm.driveStraight(dist);
        System.out.println("DriveForward " + dist);

        //spacer for easy to read robot commands
        System.out.println("--------------------------");
      }
      //unpause robot once qued to now run
      ohmm.driveUnPause();
    }

    public static void main(String[] args) throws IOException {
      //create OHMM object
      OHMMDrive ohmm = (OHMMDrive) OHMM.makeOHMM(new String[]{"-r", "/dev/ttyACM1"});
      if (ohmm == null) System.exit(0);

      //Run Image Server
      ImageServerDemo server = new ImageServerDemo(ohmm);
      server.start();

      //Create Map
      Map map = Map.create("map.txt");

      //Establish configuration space, by expanding obstacles
      //this is simplified version calculated by wrapping a circle around
      //the robot, then a square around the circle, and stamping that
      //that square on each obstacle corner.
      map.expand(0.25f);

      //list map items
      ArrayList<Vertex> vertices = map.listVertices();
      ArrayList<Node> nodes = map.listNodes(vertices);
      ArrayList<Obstacle> obstacles = map.listObstacles();

      //Build Visibility graph
      VGraph.build(nodes, obstacles);

      //Dijkstras Algorithm
      VGraph.computePaths(nodes.get(0));
      ArrayList<Node> path = VGraph.getShortestPathTo(nodes.get(1));

      //print out useful information
      System.out.println("Here is the path");
      System.out.println(path);
      System.out.println("Here are the commands");

      //have robot execute path
      GlobalNav.sendCommands(path, ohmm);

      //close ohmm and image server

      while (ohmm.driveGetQueue() != 0) {
      	
      }

      server.stop(0);
      ohmm.close();
    }
}