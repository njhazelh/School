/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import org.junit.Assert;
import org.junit.Test;

/**
 * SaleTest tests the functionality of the Sale class.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class SaleTest {

    /**
     * Test the class Sale.
     */
    @Test
    public void testSale() {
        Price p1 = new Price("a", 5, 1);
        Sale s1 = new Sale(p1, null);
        
        Assert.assertTrue("s1 price", s1.getPrice().equals(p1));
        Assert.assertNull("s1 event", s1.getEvent());
    }
}
