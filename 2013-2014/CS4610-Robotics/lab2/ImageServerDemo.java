/**
 * <p>OHMM image server demo</p>
 * <p>Modified by Qimeng Song</p>
 **/

package l2;

import ohmm.*;
import ohmm.OHMM.AnalogChannel;

import java.awt.image.BufferedImage;
import java.awt.Graphics2D;
import java.awt.Color;
import java.io.*;
import java.util.Scanner;

/**
 * <p>OHMM HTTP image server ({@link ohmm.ImageServer}) demonstration.</p>
 *
 * <p>Once this is running aim a web browser to {@code
 * http://IP:8080/server.html} where IP is the IP address of the robot (it
 * should also work to omit the {@code /server.html} part).</p>
 *
 * @author Marsette Vona
 **/
public class ImageServerDemo extends ImageServer {

  /** Default TCP listen port. **/
  public static final int DEF_PORT = 8080;
  /** 1 pixel = 10 mm **/
  /** Image width and height. In real world is 7.5m * 5m **/
  public static final int IMG_WIDTH = 750;
  public static final int IMG_HEIGHT = 500;

  /** Current frame number. **/
  protected int frameNumber = 0;

  /** The OHMM object reference. **/
  protected OHMMDrive ohmm = null;

  /** Storage space for the OHMM pose. **/
  protected float[] pose = new float[3]; 

  /**
   * <p>Constructor sets the TCP listen port and other server configuration.</p>
   *
   * @param port the TCP listen port
   * @param ohmm a reference to the OHMM object, if any
   **/
  public ImageServerDemo(int port, OHMMDrive ohmm) throws IOException {
    super(port); //set TCP listen port

    //save reference to OHMM object
    this.ohmm = ohmm;

    //set default image params
    defFmt = "png"; //png is lossless, jpeg is lossy but gives more compression
    defFPS = 2; //frames per second
    defQual = DEF_QUAL; //compression quality (for jpeg)

    //configure debugging
    dbg = false;
    msgStream = System.out;
    warnStream = System.err;
    spewStackTraces = true;
    spewMouseMoves = false;
  }

  /**
   * <p>Covers {@link ImageServerDemo(int OHMMDrive)}, uses {@link
   * #DEF_PORT}.</p>
   **/
  public ImageServerDemo(OHMMDrive ohmm) throws IOException {
    this(DEF_PORT, ohmm);
  }

  /**
   * <p>Overrides {@link ohmm.ImageServer.updateImage(BufferedImage)}.</p>
   *
   * <p>See the documentation for that method.</p>
   *
   * <p>This is where you do your drawing.  Will be called automatically
   * according to the requested FPS (or the default FPS if no FPS was
   * specifically request by the client).</p>
   **/
  protected BufferedImage updateImage(BufferedImage bi) {

    Graphics2D g = null;
    //create the image we draw into on the first call
    //it will get reused on later calls
    if (bi == null) {
      bi = new BufferedImage(IMG_WIDTH, IMG_HEIGHT+100,
        BufferedImage.TYPE_3BYTE_BGR);
      g = bi.createGraphics();

      //clear image
      g.setBackground(Color.WHITE);
      g.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT+100);

      //draw outline
      g.setPaint(Color.BLACK);
      g.drawRect(0, 0, IMG_WIDTH-1, IMG_HEIGHT-1);

      //draw x coordinate
      g.setColor(Color.RED);
      g.drawLine(0, 250, 750, 250);

      //draw y coordinate
      g.setColor(Color.GREEN);
      g.drawLine(50, 0, 50, 500);
    }
    else {
      g = bi.createGraphics();
      g.setBackground(Color.WHITE);
      g.clearRect(0, IMG_HEIGHT, IMG_WIDTH, IMG_HEIGHT+100);
    }
    //this example just draws some text in the middle of the image
    //you can replace this with any drawing code you want

    String msg = "";

    if (ohmm != null) {
      ohmm.driveGetPose(pose);
      msg += "(x, y, t): ("+pose[0]+", "+pose[1]+", "+pose[2]+")";
      
      //calculate the robot position in the world frame
      int robotx = (int) (pose[0]/10 + 50);
      int roboty = (int) (250 - pose[1]/10);
      float t = pose[2];
      g.setColor(Color.BLACK);
      
      //draw robot 
      int dx = (int) (8*Math.cos(t) + robotx);
      int dy = (int) (8*(-Math.sin(t)) + roboty);
      g.drawLine(robotx, roboty, dx, dy); //robot direction
      int cx1 = (int) (5*Math.cos(t) + 5*Math.sin(t) + robotx);
      int cx2 = (int) (-5*Math.cos(t) + 5*Math.sin(t) + robotx);
      int cx3 = (int) (-5*Math.cos(t) - 5*Math.sin(t) + robotx);
      int cx4 = (int) (5*Math.cos(t) - 5*Math.sin(t) + robotx);
      int cy1 =  (int) (5*(-Math.sin(t)) + 5*Math.cos(t) + roboty);
      int cy2 =  (int) (-5*(-Math.sin(t)) + 5*Math.cos(t) + roboty);
      int cy3 =  (int) (-5*(-Math.sin(t)) + -5*Math.cos(t) + roboty);
      int cy4 =  (int) (5*(-Math.sin(t)) - 5*Math.cos(t) + roboty);

      int[] xPoints = {cx1, cx2, cx3, cx4};
      int[] yPoints = {cy1, cy2, cy3, cy4};
      g.drawPolygon(xPoints, yPoints, 4);

      
      //draw the IR reading
      float d1 = ohmm.senseReadAnalog(AnalogChannel.CH_2);
      float d2 = ohmm.senseReadAnalog(AnalogChannel.CH_3);
      
      //calculate the IRs' reading position in pixels
      int frontIRx = (int) ((pose[0] - (-d1 - 50) * Math.sin(0))/10 + 50);
      int frontIRy = (int) (250 - (pose[1] + (-d1 - 50) * Math.cos(0))/10);    
      int rearIRx = (int)((pose[0] - 100 * Math.cos(t) - (-d2-50) * Math.sin(0))/10 + 50);
      int rearIRy = (int)(250 - ((pose[1]-100 * Math.sin(t)+(-d2-50) * Math.cos(0)))/10);
      //draw the reading
      g.setColor(Color.RED);
      g.drawLine(frontIRx, frontIRy, frontIRx, frontIRy);
      g.setColor(Color.BLUE);
      g.drawLine(rearIRx, rearIRy, rearIRx, rearIRy);   

      //read obstacles info from the map and draw them
      FileReader in;
      try {
        System.out.println( System.getProperty( "user.dir" ) );
        in = new FileReader("map.txt");
        BufferedReader br = new BufferedReader(in);
        //first line is the goal
        String line = br.readLine();
        Scanner sc = new Scanner(line);
        float[] goal = new float[2];
        int i = 0;
        while(sc.hasNext()){
          goal[i] = Float.parseFloat(sc.next());
          System.out.println("i: "+ i+ " "+ goal[i]);
          i++;
        }
        //get the goal's coordination in real world
        float goalRx = goal[0];
        float goalRy = goal[1];

        //convert the coordination to the canvas's coordination
        //1 pixel = 10 mm
        int goalx = (int) (goalRx*100 + 50);
        int goaly = (int) (250 - goalRy*100);
        //draw the goal as a red box
        g.setColor(Color.RED);
        g.drawRect(goalx-5, goaly-5, 10, 10);
        System.out.println("goal coord : "+goalRx+" "+ goalRy);
        
        while ((line = br.readLine()) != null) {

          Scanner s = new Scanner(line);
          float[] obstacle = new float[4];
          int j = 0;
          while(s.hasNext()){
            obstacle[j] = Float.parseFloat(s.next());
            System.out.println(j + " :"+ obstacle[j]);
            j++;
            
          }
          //convert the obstacle coord to the canvas frame
          int obxmin = (int) (obstacle[0]*100+50);
          int obxmax = (int) (obstacle[1]*100+50);
          int obymax = (int) (250-obstacle[2]*100);
          int obymin = (int) (250-obstacle[3]*100);
          int obWidth = (int) (100 * obstacle[1] - 100 * obstacle[0]);
          int obHeight = (int) (100 * obstacle[3] - 100 * obstacle[2]);
          //draw each of the obstacle including the boundary
          g.setColor(Color.GRAY);
          g.drawRect(obxmin, obymin, obWidth, obHeight);
          

        }
        in.close();
      } catch (FileNotFoundException e) {
        System.out.println("map file not found");
        e.printStackTrace();
      } catch (IOException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }

    }




    else {
      msg = "robot not connected  ";
      System.out.println("robot not connected");
    }

    //output the robot pose
    g.setColor(Color.black);
    g.drawString(msg, IMG_WIDTH/2, IMG_HEIGHT + 50);
    return bi;
  }

  /**
   * <p>Overrides {@link ohmm.ImageServer.handleMouse(int, int, int, int)}.</p>
   *
   * <p>See the documentation for that method.</p>
   *
   * <p>This will be called for any user mouse actions over the image in their
   * browser.</p>
   *
   * <p>Default implementation prints some types of actions.</p>
   **/
  protected void handleMouse(int t, int x, int y, int m) {
    switch (t) {
      case EVENT_LBUTTONDOWN:
      System.out.println("client lbutton press at ("+x+", "+y+")"); break;
      case EVENT_LBUTTONUP:
      System.out.println("client lbutton release at ("+x+", "+y+")"); break;
    }
  }

  /**
   * <p>Overrides {@link ohmm.ImageServer.handleKey(char)}.</p>
   *
   * <p>See the documentation for that method.</p>
   *
   * <p>This will be called for any user keypresses over the image in their
   * browser.</p>
   *
   * <p>Default implementation prints the keypress and catches 'g' and 'q' to
   * toggle server debug spew and to exit, respectively.</p>
   **/
  protected void handleKey(char c) {

    System.out.println("client keypress: "+c);

    switch (c) {
    //change these and/or add your own handlers as desired
      case 'g': case 'G': dbg = true; break;
      case 'q': case 'Q':
      stop(); if (ohmm != null) ohmm.close(); System.exit(0); break;
    }
  }

  /** 
   * <p>Entry point.</p>
   *
   * <p>NOTE: You can also just create an ImageServer object somewhere in your
   * own code.  You do not have to run it as a separate program with its own
   * main() as this example shows.</p>
   *
   * <p>Up to one command line argument is accepted giving the TCP listen port.
   * Defaults to {@link #DEF_PORT} if omitted.</p>
   **/
  
  
  public static void main(String[] argv) throws IOException {
   //create the ImageServer in Local Nav and Global Nav
  }
}


