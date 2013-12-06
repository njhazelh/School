/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import org.junit.Assert;
import org.junit.Test;

/**
 * MovieTest tests the functionality of the Movie class in dataControl
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class MovieTest {

    /**
     * Test the movie class
     */
    @Test
    public void test() {
        Movie m1 = new Movie(1, "a", 100);
        Event e1 = new Event(0, m1, null, 0);

        Assert.assertTrue("m1 length", m1.getLengthInSecs() == 100);
        Assert.assertTrue("m1 title", m1.getTitle().equals("a"));
        Assert.assertTrue("m1 id", m1.getID() == 1);
        Assert.assertTrue("m1 events", m1.getEvents().size() == 0);
        Assert.assertTrue("m1 toString", m1.toString().equals("a, 1 minutes"));

        m1.addEvent(e1);

        Assert.assertTrue("m1 added event", m1.getEvents().get(0).equals(e1));
        Assert.assertTrue("m1 hashCode", m1.hashCode() == 1);

        m1.removeEvent(e1);
        Assert.assertTrue("m1 events 2", m1.getEvents().size() == 0);
    }

}
