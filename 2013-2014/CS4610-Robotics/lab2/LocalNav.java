/**
*
*
*/

package l2;

import ohmm.*;
import static ohmm.OHMM.*;
import ohmm.OHMM.AnalogChannel;
import static ohmm.OHMM.AnalogChannel.*;
import ohmm.OHMM.DigitalPin;
import static ohmm.OHMM.DigitalPin.*;

import java.io.*;

/**
*
* @author Nick Jones
* @version 0.1
*/
public class LocalNav {
    public static final Double GOAL_THESHOLD = 15.0;
    private Double goalX;
    private Double goalY;
    private Line mLine;
    private OHMMDrive ohmm;

    /**
    * CONSTRUCTOR
    */
    public LocalNav(OHMMDrive ohmm, Double goalX, Double goalY) throws Line.NoSuchLineException{
        this.ohmm = ohmm;
        this.goalX = goalX;
        this.goalY = goalY;
        this.mLine = Line.calcLineByPoints(0.0, 0.0, goalX, goalY);
    }




    public Boolean run() {
        this.ohmm.driveSetPose((float)0.0, (float)0.0, (float)0.0);
        moveUntilGoalOrBump();

        if (!this.hasReachedGoal()) {
            // mark hit point NEEDED?

            // face right side to wall
            this.ohmm.driveStraight((float)-150.0);
            this.waitForCommandToFinish();
            this.turnLeft();
            this.moveUntilSensorsFree();
            System.out.println("Reached Corner 1");
            this.ohmm.driveStraight((float)150.0);
            this.turnRight();
            this.moveUntilFrontSensorCovered();
            this.moveUntilSensorsFree();
            System.out.println("Reached Corner 2");
            this.ohmm.driveStraight((float)150.0);
            this.turnRight();
            this.moveUntilFrontSensorCovered();
            this.moveUntilMLine();
            System.out.println("OHMM has reached exit point");
            return this.moveUntilGoalOrBump();
        }
        else
            return this.hasReachedGoal();
    }




    /**
    * turn to the left 90 degrees
    *
    */
    public void turnLeft() {
        ohmm.driveTurnDeg((float)89.0);
        waitForCommandToFinish();
    }




    /**
    * turn to the right 90 degress
    *
    */
    public void turnRight() {
        ohmm.driveTurnDeg((float)-89.0);
        waitForCommandToFinish();
    }




    public Double frontIRDist() {
        return new Double(this.ohmm.senseReadAnalog(AnalogChannel.CH_2));
    }




    public Double backIRDist() {
        return new Double(this.ohmm.senseReadAnalog(AnalogChannel.CH_3));
    }




    public void moveUntilFrontSensorCovered() {
        IRMoveController ctrl = new IRMoveController();
        this.ohmm.driveSetVW((float)50.0, (float)0.0);

        do {
            ctrl.addReading(this.frontIRDist(), this.backIRDist());
        } while (ctrl.frontIsFree());

        this.ohmm.driveSetVW((float)0.0, (float)0.0);
    }




    public void moveUntilSensorsFree() {
        IRMoveController ctrl = new IRMoveController();
        this.ohmm.driveSetVW((float)50.0, (float)0.0);

        do {
            ctrl.addReading(this.frontIRDist(), this.backIRDist());
            this.ohmm.driveSetVW((float)50.0, ctrl.calcAngVel().floatValue());
        } while(!ctrl.frontIsFree() || !ctrl.backIsFree());

        this.ohmm.driveSetVW((float)0.0, (float)0.0);
    }




    Boolean isLeftBumperActive() {
        Boolean result = this.ohmm.senseReadDigital(DigitalPin.IO_A0);
        if (result)
            System.out.println("Left bumper active");

        return result;
    }




    Boolean isRightBumperActive() {
        Boolean result = this.ohmm.senseReadDigital(DigitalPin.IO_A1);
        if (result)
            System.out.println("Right bumper active");

        return result;
    }




    public void waitForCommandToFinish() {
        while(this.ohmm.driveGetQueue() != 0);
    }

   

    /**
    *
    */
    Boolean hasReachedGoal() {
        float[] pose = this.ohmm.driveGetPose();
        Boolean result = this.distanceToGoal() <= GOAL_THESHOLD;
        //System.out.println("x: " + pose[0]);
        //System.out.println("y: " + pose[1]);
        //System.out.println("t: " + pose[2]);

        if (result)
            System.out.println("OHMM has reached goal");

        return  result;
    }




    /**
    * How far is the robot from the goal in mm?
    */
    Double distanceToGoal() {
        float[] pose = this.ohmm.driveGetPose();
        Double distance =  Math.sqrt(Math.pow(this.goalX - pose[0], 2.0) +
                                     Math.pow(this.goalY - pose[1], 2.0));
        //System.out.println("distanceToGoal: " + distance);
        return distance;
    }




    /**
    *
    *
    */
    Boolean moveUntilGoalOrBump() {

        this.faceGoal();
        this.ohmm.driveSetVW((float)50.0, (float)0.0);

        while(true) {
            if(this.hasReachedGoal()) {
                this.ohmm.driveSetVW((float)0.0, (float)0.0); 
                return true;
            }
            else if (this.isLeftBumperActive() || this.isRightBumperActive()) {
                this.ohmm.driveSetVW((float)0.0, (float)0.0); 
                System.out.println("OHMM hit something");
                return false;
            }
        }
    }




    void moveUntilMLine() {
        this.ohmm.driveSetVW((float)50.0, (float)0.0);
        float[] pose;
        
        do { pose = this.ohmm.driveGetPose(); }
        while(!this.mLine.isOnLine((double)pose[0], (double)pose[1], 20.0));

        this.ohmm.driveSetVW((float)0.0, (float)0.0);
    }




    /**
    * Turn to face the goal
    *
    */
    public void faceGoal() {
        float[] pose = ohmm.driveGetPose();
        Double currentX = new Double(pose[0]);
        Double currentY = new Double(pose[1]);
        Double currentTheta = new Double(pose[2]) % (2 * Math.PI);
        currentTheta += currentTheta < 0.0 ? 2 * Math.PI : 0.0;
        Double dx = this.goalX - currentX;
        Double dy = this.goalY - currentY;
        Double goalTheta;

        if (dx == 0.0)
            goalTheta = Math.PI / 2.0 * (dy < 0.0 ? 3 : 1);
        else
            goalTheta = Math.atan(dy / dx) + (dx < 0.0 ? Math.PI : 0.0);

        Double dTheta = goalTheta - currentTheta;

        if (dTheta > Math.PI)
            dTheta = dTheta - 2 * Math.PI;

        //System.out.println("dTheta :" + dTheta);
        //System.out.println("dX: " + dx);
        //System.out.println("dY: " + dy);
        //System.out.println("goalTheta: " + goalTheta);
        //System.out.println("currentX: " + currentX);
        //System.out.println("currentY: " + currentY);

        this.ohmm.driveTurn(dTheta.floatValue());
        Double goalThetaUpper = (goalTheta + .2);
        Double goalThetaLower = (goalTheta - .2);
        do {
            pose = this.ohmm.driveGetPose();
            currentTheta = new Double(pose[2]) % (2 * Math.PI);
            //System.out.println("currentTheta: " + currentTheta);
        } while (currentTheta > goalThetaUpper  || currentTheta < goalThetaLower);
    }



    /**
     * argv contains goal-x and goal-y
     **/
    public static void main(String[] argv) throws IOException {
        //create the OHMM object
        OHMMDrive ohmm =
            (OHMMDrive) OHMM.makeOHMM(new String[]{"-r", "/dev/ttyACM1"});

        if (ohmm == null) System.exit(0);
        //ohmm.driveUnPause();
        ohmm.driveStop();
        //System.out.println("Queue size: " + ohmm.driveGetQueue());

        // Configure sensors
        ohmm.senseConfigAnalogIR(AnalogChannel.CH_2, 1);
        ohmm.senseConfigAnalogIR(AnalogChannel.CH_3, 1);
        ohmm.senseConfigDigital(DigitalPin.IO_A0, true, false);
        ohmm.senseConfigDigital(DigitalPin.IO_A1, true, false);


        //If you want to run an instance of the OHMM HTTP image server to show
        //debug images, you could start it here.
        ImageServerDemo server = new ImageServerDemo(ohmm);
        server.start();


        // Parse goal location from arguments
        Double goalX = 0.0;
        Double goalY = 0.0;
        try {
            goalX = Double.parseDouble(argv[0]);

            if (argv.length >= 2)
                goalY = Double.parseDouble(argv[1]);
        }
        catch (Exception e) {
            System.err.println("Usage: Float(GoalX) Float(GoalY)");
            System.exit(0);
        }

        System.out.println("\nParsed Goal Location: ");
        for (Double f : new Double[]{goalX, goalY})
            System.out.println(f);

        //Run algorithm
        try {
            LocalNav bugAlgo = new LocalNav(ohmm, goalX, goalY);
            bugAlgo.run();

            float[] pose = ohmm.driveGetPose();
            System.out.println("finalX: " + pose[0]);
            System.out.println("finalY: " + pose[1]);

            server.stop(0);
            //Thread.sleep(500);
            ohmm.close();
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            System.exit(0);
        }
    }
}
