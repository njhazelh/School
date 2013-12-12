/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import org.junit.Assert;
import org.junit.Test;

/**
 * Test Price
 * 
 * @author Nick
 * @version 12/4/2013
 */
public class PriceTest {

    /**
     * Test Price
     */
    @Test
    public void test() {
        Price p1 = new Price("a", 1000, 0);
        Price p2 = new Price("a", 1000, 1);
        Price p3 = new Price("b", 1000, 0);
        Price p4 = new Price("a", 2000, 0);
        Object o = null;
        
        Assert.assertEquals("p1 cost", p1.getPriceInCents(), 1000);
        Assert.assertFalse("p1 equals p3", p1.equals(p3));
        Assert.assertFalse("p1 equals p2", p1.equals(p2));
        Assert.assertFalse("p1 equals p4", p1.equals(p4));
        Assert.assertFalse("p1 equals o", p1.equals(o));
        Assert.assertTrue("p1 demo", p1.getDemographic().equals("a"));
        Assert.assertEquals("p1 id", p1.getID(), 0);
        Assert.assertTrue("p1 string", p1.toString().equals("a: $10.00"));

        p1.setPriceInCents(2000);
        Assert.assertEquals("p1 cost", p1.getPriceInCents(), 2000);

        p1.setDemographic("c");
        Assert.assertTrue("p1 demo", p1.getDemographic().equals("c"));
    }

}
