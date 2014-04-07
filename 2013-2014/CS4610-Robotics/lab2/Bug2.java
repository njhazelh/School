/**
 * <p>Bug2 algorithm for CS4610 lab2 group1.</p>
 * <p>Author Qimeng Song</p>
 **/

package l2;

import java.io.IOException;

import ohmm.OHMM.*;
import ohmm.OHMMDrive;
import ohmm.OHMM;

public class Bug2 {
	private OHMMDrive ohmmd;
	public Bug2(OHMMDrive ohmmd) {
		this.ohmmd = ohmmd;
	}

	public void sensorInitiation(){
		ohmmd.senseConfigDigital(DigitalPin.IO_A0, true, false);
		ohmmd.senseConfigDigital(DigitalPin.IO_A1, true, false);
		ohmmd.senseConfigAnalogIR(AnalogChannel.CH_2, 1);
		ohmmd.senseConfigAnalogIR(AnalogChannel.CH_3, 1);
	}


  
	public void driveToGoal(float x){
		//set world pose to 0 0
		ohmmd.driveSetPose(0, 0, 0);
		//1. read x coordination of goal.
		//2. drive straight for x distance to the goal.
		ohmmd.driveStraight(x);
		//change to dsvw in the future
//		ohmmd.driveSetVW(10, 0);
		//3. wait for bumper switch to return hit signal.
		while(true){
			Boolean leftBumped = ohmmd.senseReadDigital(DigitalPin.IO_A0);
			Boolean rightBumped = ohmmd.senseReadDigital(DigitalPin.IO_A1);

			if(leftBumped && rightBumped){
				break;
			}
			//only left bumper is triggered, roll right wheel
			else if(leftBumped){
				ohmmd.motSetVelCmd(0, 1);
			}
			//only right bumper is triggered, roll left wheel
			else if(rightBumped){
				ohmmd.motSetVelCmd(1, 0);
			}
			//no bumper is trigger, run forward a little bit (30mm)
			else{
				ohmmd.driveSetVW(15, 0);
			}
		}

		//back up 150 mm then turn left 90 degree.
		// ohmmd.driveStraight(-150.00f);
		// ohmmd.driveTurn(1.57f);
		/*		
		//4. drive along the side of the obstacle until reached corner:

		while(true){
			float firstIR = ohmmd.senseReadAnalog(AnalogChannel.CH_2);
			float secondIR = ohmmd.senseReadAnalog(AnalogChannel.CH_3);

			//if first IR sensor can no longer sense the obstacle 
		//and the second IR sensor can still sense the obstacle, keep driving.

			if(firstIR > && secondIR < ){

		}
		//keep driving straight until the second sensor can no longer sense
		//the obstacle and keep driving 10cm.
			else if()
		//then turn right 90 degree and keep driving along.
		}
		//5. repeat step 4 until reached m line.
		 * 
		 * 
		 */
	}




	public static void main(String[] argv) throws IOException {

		//create the OHMM object
		//	    OHMMDrive ohmm = (OHMMDrive) OHMM.makeOHMM(argv);
		//to use argv for your own purposes, one option is to replace the above
		//call with a hardcoded version like this:
		OHMMDrive ohmm =
				(OHMMDrive) OHMM.makeOHMM(new String[]{"-r", "/dev/ttyACM1"});

		if (ohmm == null) System.exit(0);

		//If you want to run an instance of the OHMM HTTP image server to show
		//debug images, you could start it here.
		//
		ImageServerDemo imageServer = new ImageServerDemo(ohmm);
		imageServer.start();
 
		//to use this file as a template:
		//
		//1 - rename the file to YourClass.java
		//
		//2 - change the class name above from OHMMShellDemo to YourClass
		//
		//3 - change the author info and other documentation above
		//
		//4 - comment out the next two lines that run an OHMMShell
		//
		//5 - write whatever code you want here that makes use of the ohmm object
		//		OHMMShell shell = new OHMMShell(ohmm);
		//		shell.readEvalPrintLoop();

		Bug2 bug2 = new Bug2(ohmm);
		ohmm.senseConfigDigital(DigitalPin.IO_A0, true, false);
		ohmm.senseConfigDigital(DigitalPin.IO_A1, true, false);
		ohmm.senseConfigAnalogIR(AnalogChannel.CH_2, 1);
		ohmm.senseConfigAnalogIR(AnalogChannel.CH_3, 1);
		System.out.println("sensor initiated");
 		bug2.driveToGoal(100);
		ohmm.close();
	}

}