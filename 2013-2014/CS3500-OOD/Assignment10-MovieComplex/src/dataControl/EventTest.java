/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.GregorianCalendar;

import org.junit.Assert;
import org.junit.Test;

/**
 * EventTest tests the functionality of the Event class in dataControl
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class EventTest {

    /**
     * Test Event
     */
    @Test
    public void test() {
        Theater t = new Theater("ta", 1, 0, false, 100);
        Movie m = new Movie(0, "a", 600);
        Event e = new Event(1, m, t, 0);
        GregorianCalendar end = new GregorianCalendar();
        end.setTimeInMillis(600000);
        
        Assert.assertTrue("e String",
            e.toString().equals("a @ 7:00PM-7:10PM in ta(1):100"));
        Assert.assertTrue("e theater", e.getTheater().equals(t));
        Assert.assertEquals("e filledSeats", e.getFilledSeats(), 0);
        Assert.assertTrue("e has 600 tickets", e.hasNTickets(100));
        Assert.assertFalse("e has 601 tickets", e.hasNTickets(101));
        Assert.assertFalse("e not sold out", e.isSoldOut());
        e.fillSeats(100);
        Assert.assertEquals("e filledSeats", e.getFilledSeats(), 100);
        Assert.assertTrue("e has 0 tickets", e.hasNTickets(0));
        Assert.assertFalse("e has 1 tickets", e.hasNTickets(1));
        Assert.assertTrue("e overlaps e", e.isOverlapping(e));
        Assert.assertTrue("e movie", e.getMovie().equals(m));
        Assert.assertEquals("e id", e.getID(), 1);
        Assert.assertTrue("e sold out", e.isSoldOut());
        Assert.assertEquals("e end time", e.getEndTime(), 600000);
        Assert.assertEquals("e start time", e.getStartTime(), 0);
        Assert.assertTrue("e end calendar", e.getEndTimeCalendar().equals(end));
        e.hide();
    }
}
