/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import org.junit.Assert;
import org.junit.Test;

/**
 * This quickly runs the constructors for the Exceptions that I definied.
 * There's not much for them to do, so... yeah.
 * 
 * @author Nick Jones
 * @version 12/3/2013
 */
public class ExceptionTests {

    /**
     * Run the constructors for OverlappingEventException
     */
    @Test
    public void testOverlapping() {
        new OverlappingEventException();
        new OverlappingEventException("message");
        new OverlappingEventException("message", new Throwable());

        Assert.assertTrue("tests ran", true);
    }

    /**
     * Run the constructors for SoldOutException
     */
    @Test
    public void testSoldOut() {
        new SoldOutException();
        new SoldOutException("message");
        new SoldOutException("message", new Throwable());

        Assert.assertTrue("tests ran", true);
    }
}
