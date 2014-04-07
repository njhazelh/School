/**
 * <p>Demo of CvKinect.</p>
 *
 * <p>This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.</p>
 *
 * <p>This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.</p>
 *
 * <p>You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin St, Fifth Floor, Boston, MA 02110-1301 USA</p>
 *
 * <p>Copyright (c) 2011 Marsette A. Vona</p>
 **/


package l5;

import com.googlecode.javacpp.*;
import com.googlecode.javacv.*;
import com.googlecode.javacv.cpp.*;
import static com.googlecode.javacv.cpp.opencv_calib3d.*;
import static com.googlecode.javacv.cpp.opencv_contrib.*;
import static com.googlecode.javacv.cpp.opencv_core.*;
import static com.googlecode.javacv.cpp.opencv_features2d.*;
import static com.googlecode.javacv.cpp.opencv_flann.*;
import static com.googlecode.javacv.cpp.opencv_highgui.*;
import static com.googlecode.javacv.cpp.opencv_imgproc.*;
import static com.googlecode.javacv.cpp.opencv_legacy.*;
import static com.googlecode.javacv.cpp.opencv_ml.*;
import static com.googlecode.javacv.cpp.opencv_objdetect.*;
import static com.googlecode.javacv.cpp.opencv_video.*;

import static com.googlecode.javacv.cpp.freenect.*;


import ohmm.*;
import static ohmm.OHMM.*;
import ohmm.OHMM.AnalogChannel;
import static ohmm.OHMM.AnalogChannel.*;
import ohmm.OHMM.DigitalPin;
import static ohmm.OHMM.DigitalPin.*;

/**
 * <p>Demo of {@link CvKinect}.</p>
 *
 * <p>Also see {@link CvDemo}.</p>
 *
 * @author Marsette A. Vona
 **/
public class CvKinectDemo extends CvKinect {
  
  /** Application name.**/
  public static final String APPNAME = "CvKinectDemo";
  public boolean dbg = false;

  /** State for {@link #handleKeyExt}. **/
  protected int tiltCycle = 0;

  /** State for {@link #handleKeyExt}. **/
  protected int ledCycle = 0;

  /** State for {@link #handleKeyExt}. **/
  protected boolean regCycle = true;

  /** State for {@link #handleKeyExt}. **/
  protected String fmtCycle = "depth";

  /** State for {@link #handleMouse}. **/
  protected int[] dumpXY = new int[] {-1, -1};

  /** Gamma table for {@link #depthToBGR}. **/
//  protected int[] gamma = null;

  /** False color depth image. **/
  protected IplImage depthBGR = null;

  /** Depth mask image. **/
  protected IplImage depthMask = null;

  /** Whether to show depth in false color if possible. **/
  protected boolean falseColor = true;

  /** Whether to mask color by valid depth if possible. **/
  protected boolean maskColor = false;


  /** Sets {@link #APPNAME}. **/
  public CvKinectDemo() { super(APPNAME); }

  /**
   * {@inheritDoc}
   *
   * <p>This impl handles keycodes for Kinect demo functions.</p>
   **/
  protected boolean handleKeyExt(int code) {

    switch (code) {
    case 'j': case 'k':
      maxFPS += (code == 'j') ? 1 : ((maxFPS > 1) ? -1 : 0);
      System.out.println("max FPS: "+maxFPS);
      break;
    case 't': case 'T':
      try { tiltCycle = getTiltDegs(); msg("tilt degs: "+tiltCycle); }
      catch (Exception e) { warn(e.getMessage()); }
      break;
    case '+': case 187:
      try { 
        tiltCycle++;
        msg("tilt +1 deg to "+tiltCycle); setTiltDegs(tiltCycle);
      } catch (Exception e) { warn(e.getMessage()); }
      break;
    case '-': case 189:
      try { 
        tiltCycle--;
        msg("tilt -1 deg to "+tiltCycle); setTiltDegs(tiltCycle);
      } catch (Exception e) { warn(e.getMessage()); }
      break;
    case '0':
      try { tiltCycle = 0; msg("tilt to 0 deg"); setTiltDegs(tiltCycle); }
      catch (Exception e) { warn(e.getMessage()); }
      break;
    case 'l': case 'L':
      try {
        ledCycle++; if (ledCycle > 6) ledCycle = 0;
        setLED(ledCycle); msg("led: "+ledCycle);
      } catch (Exception e) { warn(e.getMessage()); }
      break;
    case 'r': case 'R':
      regCycle = !regCycle;
      setDepthRegistration(regCycle);
      msg("depth registration: "+regCycle);
      break;
    case 'f': case 'F':
      try {
        if ("video".equals(fmtCycle)) fmtCycle = "depth";
        else fmtCycle = "video";
        setFormat(fmtCycle);
        msg("format: "+fmtCycle);
      } catch (Exception e) { warn(e.getMessage()); }
      break;
    case 'd': case 'D':
      if (falseColor) { falseColor = false; maskColor = true; }
      else if (maskColor) { maskColor = false; }
      else { falseColor = true; }
      msg("false color: "+falseColor+", mask color: "+maskColor);
      break;
    }

    return true;
  }

  /**
   * {@inheritDoc}
   *
   * <p>This impl handles keycodes for Kinect demo functions.</p>
   **/
  protected void guiHelpExt() {
    msg("k/j -- increase/decrease max FPS");
    msg("t -- get tilt angle");
    msg("+,- -- incr,decr tilt");
    msg("0 -- set tilt to 0");
    msg("l -- cycle LED");
    msg("r -- toggle depth-to-RGB registration");
    msg("f -- toggle depth/video format");
    msg("d -- toggle depth false color");
  }

  /**
   * {@inheritDoc}
   *
   * <p>This impl triggers RGB/XYZ dump on click.</p>
   **/
  protected void handleMouse(int event, int x, int y, int flags) {
    if (event == CV_EVENT_LBUTTONDOWN)
      synchronized (dumpXY) { dumpXY[0] = x; dumpXY[1] = y; }
    super.handleMouse(event, x, y, flags);
  }

  /**
   * {@inheritDoc}
   *
   * <p>This impl handles Kinect demo functions.</p>
   **/
  protected IplImage process(IplImage frame) {

    //handoff clicked pixel coords from handleMouse()
    int x = -1, y = -1;
    synchronized (dumpXY)
      { x = dumpXY[0]; y = dumpXY[1]; dumpXY[0] = dumpXY[1] = -1; }

    //show color and XYZ at clicked pixel coords, if any
    if ((frame != null) && (x >= 0) && (y >= 0)) {
      msg("pixel: ("+x+", "+y+")");
      CvScalar s = cvGet2D(frame, y, x);
      if (frame.nChannels() == 3) {
        msg("RGB: ("+s.red()+", "+s.green()+", "+s.blue()+")");
      } else if (frame.nChannels() == 1) {
        int z = (int) s.val(0);
        msg("z: "+z);
        if ((okGrabber != null) && ("depth".equals(okGrabber.getFormat())) &&
            ((okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_REGISTERED) ||
             (okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_MM))) {
          DoublePointer wx = new DoublePointer(), wy = new DoublePointer();
          okGrabber.cameraToWorld(x, y, z, wx, wy);
          msg("XYZ [mm]: ("+wx.get()+", "+wy.get()+", "+z+")");
        } else warn("XYZ dump only available with OpenKinect in "+
                    "DEPTH_REGISTERED or DEPTH_MM mode");
      }
    }

    //cannot modify grabbed frame bits!
    IplImage ret = frame;

    if (falseColor && (frame != null) &&
        (okGrabber != null) && ("depth".equals(okGrabber.getFormat()))) {

      //show depth in false color, only for OpenKinect

      int max = MAX_DEPTH_11BIT; float scale = 1.0f;
      if ((okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_REGISTERED) ||
          (okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_MM))
        { max = MAX_DEPTH_MM; scale = 0.25f; }

      depthBGR = depthToBGR(frame, depthBGR, max, scale);

      ret = depthBGR;
    }

    if (maskColor && (frame != null) && 
        (okGrabber != null) && ("depth".equals(okGrabber.getFormat()))) {

      //mask color by valid depth, only for OpenKinect

      try {

        //the incoming frame was the depth map
        
        //this is how to grab the corresponding (by time) color image
        IplImage bgr = okGrabber.grabVideo();
        
        int w = frame.width(), h = frame.height();
        
        if (depthBGR == null)
          depthBGR = IplImage.create(cvSize(w, h), IPL_DEPTH_8U, 3);
       
        if (depthMask == null)
          depthMask = IplImage.create(cvSize(w, h), IPL_DEPTH_8U, 1);

        int min = MIN_DEPTH_11BIT, max = MAX_DEPTH_11BIT;
        if ((okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_REGISTERED) ||
            (okGrabber.getDepthBitsPerPixel() == FREENECT_DEPTH_MM))
          { min = MIN_DEPTH_MM; max = MAX_DEPTH_MM; }

        //make binary mask of valid depth pixels
        cvInRangeS(frame, cvScalar(min,0,0,0), cvScalar(max,0,0,0),
                   depthMask);

        //clear the output image
        cvSet(depthBGR, CvScalar.BLACK, null);
        
        //copy color of pixels with valid depth to output
        cvCopy(bgr, depthBGR, depthMask);
        
        ret = depthBGR;

      } catch (Exception e) { warn("error grabbing BGR: "+e); }
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   *
   * <p>This impl also releases {@link #depthBGR}.</p>
   **/
  public void release() {
    //important to explicitly null and check for non-null to avoid double
    //releasing even if this is called more than once, which it may be since
    //CvBase.finalize() calls release()
    if (depthBGR != null) { depthBGR.release(); depthBGR = null; }
    if (depthMask != null) { depthMask.release(); depthMask = null; }
    super.release();
  }

  /** Program entry point. **/
  public static void main(String argv[]) {
    CvKinectDemo cvkd = new CvKinectDemo();
    cvkd.init(argv.length, argv);
    cvkd.dumpCaptureProperties();
    cvkd.mainLoop();
    cvkd.release();
  }
}
