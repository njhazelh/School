/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;
import java.util.Arrays;

import org.junit.Assert;
import org.junit.Test;

/**
 * TheaterTest tests the functionality of the Theater class.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class TheaterTest {

    /**
     * Test the Theater class
     */
    @Test
    public void test() {
        Theater t = new Theater("a", 1, 0, false, 100);
        Event e = new Event(0, null, t, 0);

        Assert.assertTrue("name", t.getName().equals("a"));
        Assert.assertEquals("id", t.getID(), 1);
        Assert.assertEquals("basePrice", t.getBasePrice(), 0);
        Assert.assertFalse("isLux", t.isLuxury());
        Assert.assertEquals("size", t.getSize(), 100);
        t.addEvent(e);
        Assert.assertTrue("events",
            t.getEvents().equals(new ArrayList<Event>(Arrays.asList(e))));
        t.setBasePrice(1000);
        Assert.assertEquals("basePrice 2", t.getBasePrice(), 1000);
        t.setLuxury(true);
        Assert.assertTrue("isLux", t.isLuxury());
        Assert.assertTrue("t toString", t.toString().equals("a(1):100"));
    }
}
