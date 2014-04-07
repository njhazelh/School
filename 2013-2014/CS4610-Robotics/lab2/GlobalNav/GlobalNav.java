package l2;

import ohmm.*;
import static ohmm.OHMM.*;
import ohmm.OHMM.AnalogChannel;
import static ohmm.OHMM.AnalogChannel.*;
import ohmm.OHMM.DigitalPin;
import static ohmm.OHMM.DigitalPin.*;

import java.util.*;
import java.awt.Point;
import java.awt.Point;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.lang.Math;

import java.io.*;

public class GlobalNav {

    public static void sendCommands(ArrayList<Node> nList, OHMMDrive ohmm) {

      //pause robot commands
      ohmm.driveResetPose();
      ohmm.drivePause();

      float robotAngle = 0f;

      for (int i = 0; i < nList.size() - 1; i++) {


        // System.out.println("RobotAngle " + robotAngle);

        Node nstart = nList.get(i);
        Node ngoal = nList.get(i + 1);
        Vertex vstart = nstart.vertex;
        Vertex vgoal = ngoal.vertex;

        //turn 
        //give turn comman
        float xdif = vgoal.x - vstart.x;
        float ydif = vgoal.y - vstart.y;

        float posAngle = 0f;
        float negAngle = 0f;
        if ( !(ydif == 0f)) {
          posAngle =  (float) Math.atan(xdif/ydif);
          negAngle =  (float) Math.atan(xdif/ydif);
        } else {
          posAngle = 0f;
        }
        // System.out.println("ATAN " + posAngle);

        //determine directions greater than pi/2 radians
    
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

        // System.out.println("PosAngle " + posAngle);
        // System.out.println("NegAngle " + negAngle);

        float turnCCW = posAngle - robotAngle;

        float turnCW = negAngle - robotAngle; 


        if ( turnCCW < Math.abs(turnCW)) {
            ohmm.driveTurn(turnCCW);
            System.out.println("TurnCCW " + turnCCW);
        } else {
            ohmm.driveTurn(turnCW);
            System.out.println("TurnCW " + turnCW);
        }

       

        robotAngle = (robotAngle + turnCCW) % (2f * 3.14159f);
        
       //end


        //drive forward distance (times 1000) meters to mm
        float dist = (float) (vstart.distanceTo(vgoal)) * 1000;
        System.out.println("DriveForward " + dist);

        ohmm.driveStraight(dist);

         System.out.println("--------------------------");

      }

      //unpause robot commands
      ohmm.driveUnPause();
    }

    public static void main(String[] args) throws IOException {

      //create the OHMM object
      //OHMMDrive ohmm = (OHMMDrive) OHMM.makeOHMM(argv);
      //to use argv for your own purposes, one option is to replace the above
      //call with a hardcoded version like this:
      OHMMDrive ohmm = (OHMMDrive) OHMM.makeOHMM(new String[]{"-r", "/dev/ttyACM1"});
  
      if (ohmm == null) System.exit(0);

      //If you want to run an instance of the OHMM HTTP image server to show
      //debug images, you could start it here.
      ImageServerDemo server = new ImageServerDemo(ohmm);
      server.start();



      //Read textfile create Map object
      Map map = Map.create("map.txt");

      //Map Configuration Space
      //Calculate expansion
      //side len of square epansion = 30cm (diagonal robot = diameter circle = len square)
      //each corner adds distant of the side of the square to each adjacent side

      map.expand(0.30f);

      ArrayList<Vertex> vertices = map.listVertices();

      ArrayList<Node> nodes = map.listNodes(vertices);

      ArrayList<Obstacle> obstacles = map.listObstacles();

      VGraph.build(nodes, obstacles);

      //Dijkstras Algorithm
      VGraph.computePaths(nodes.get(0));
      ArrayList<Node> path = VGraph.getShortestPathTo(nodes.get(1));

      //Print Out Results
      System.out.println("Here is the path");
      System.out.println(path);
      System.out.println("Here are the commands");
      GlobalNav.sendCommands(path, ohmm);

      //close ohmm
      ohmm.close();
    }
}