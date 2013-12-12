/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.css.neu.edu
 * Comment: n/a
 */

import org.junit.Assert;

import org.junit.Test;

/**
 * This class is JUnit4 Tests of the Comparators defined in the default package.
 * 
 * Tested: IntByVal StringByLength StringByLex
 * 
 * @author Nicholas Jones
 * @version 11/6/2013
 */
public class ComparatorsTest {

    /**
     * Test StringByLex
     */
    @Test
    public void testStringByLex() {
        StringByLex comp = new StringByLex();
        Object o = null;

        Assert.assertTrue("lex repOK", comp.repOK());
        Assert.assertTrue("lex string", comp.toString().equals("StringByLex"));
        Assert.assertFalse("lex != null", comp.equals(o));
    }

    /**
     * Test StringByLength
     */
    @Test
    public void testStringByLength() {
        StringByLength comp = new StringByLength();
        Object o = null;

        Assert.assertTrue("len repOK", comp.repOK());
        Assert.assertTrue("len string", comp.toString()
                .equals("StringByLength"));
        Assert.assertFalse("len != null", comp.equals(o));
    }

    /**
     * Test IntByVal
     */
    @Test
    public void testIntByVal() {
        IntByVal comp = new IntByVal();
        Object o = null;

        Assert.assertTrue("val repOK", comp.repOK());
        Assert.assertTrue("val string", comp.toString().equals("IntByVal"));
        Assert.assertFalse("val != null", comp.equals(o));
    }
}
