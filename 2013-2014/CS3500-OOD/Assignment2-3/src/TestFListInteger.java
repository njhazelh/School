/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */


/**
 * TestFListInteger
 * @author Nick Jones
 * @version 9/24/2013
 */
public class TestFListInteger {
    private Integer totalTests = 0;
    private Integer totalErrors = 0;
    /**
     * Runs the tests
     * @param args Command line arguments
     */
    public static void main(String[] args) {
        TestFListInteger test = new TestFListInteger();

        test.creation();
        test.accessors();
        test.usual();
        test.accessors();    // test twice to detect side effects
        test.usual();

        test.summarize();
    }
    
    /**
     * Summarize all the tests.
     */
    public void summarize() {
        System.out.println(totalErrors + " errors found in " +
                totalTests + " tests.");
    }
    
    private final Integer zero = 0;
    private final Integer one = 1;
    private final Integer two = 2;
    private final Integer three = 3;
    
    private FListInteger f0;  // {}
    private FListInteger f1;  // {zero}
    private FListInteger f2;  // {one, zero}
    private FListInteger f3;  // {two, one, zero}
    private FListInteger f4;  // {three, two, one, zero}
    
    /**
     * Create some FListIntegers
     */
    private void creation() {
        try {
            f0 = FListInteger.emptyList();
            f1 = FListInteger.add(f0, zero);
            f2 = FListInteger.add(f1, one);
            f3 = FListInteger.add(f2, two);
            f4 = FListInteger.add(f3, three);
        }
        catch (Exception e) {
            System.out.println("Exception thrown during creation tests:");
            System.out.println(e);
            assertTrue("creation", false);
        }
    }
    
    /**
     * Test all the accessor methods.
     */
    private void accessors() {
        try {
            // Test isEmpty
            assertTrue("f0 isEmpty", FListInteger.isEmpty(f0));
            assertFalse("f1 isEmpty", FListInteger.isEmpty(f1));
            assertFalse("f3 isEmpty", FListInteger.isEmpty(f3));
            assertFalse("f0.add isEmpty",
                    FListInteger.isEmpty(FListInteger.add(f0, one)));
            
            // Test get
            assertTrue("f1 get 0", FListInteger.get(f1, 0) == 0);
            assertTrue("f2 get 1", FListInteger.get(f2, 1) == 0);
            assertTrue("f2 get 0", FListInteger.get(f2, 0) == 1);
            assertTrue("f3 get 2", FListInteger.get(f3, 2) == 0);
            assertTrue("f3 get 1", FListInteger.get(f3, 1) == 1);
            assertTrue("f3 get 0", FListInteger.get(f3, 0) == 2);

            // test set
            assertTrue("f1 set 4@0", 
                    FListInteger.set(f1, 0, 4).equals(FListInteger.add(f0, 4)));
            assertTrue("f2 set 5@1", 
                    FListInteger.set(f2, 1, 5).equals(
                            FListInteger.add(FListInteger.add(f0, 5),
                                    1)));
            assertTrue("f3 set 2@2", 
                    FListInteger.set(f3, 2, 2).equals(
                            FListInteger.add(
                                    FListInteger.add(
                                            FListInteger.add(f0, 2),
                                                1),
                                            2)));
            
            // Test size
            assertTrue("f0 size", FListInteger.size(f0) == 0);
            assertTrue("f1 size", FListInteger.size(f1) == 1);
            assertTrue("f2 size", FListInteger.size(f2) == 2);
            assertTrue("f3 size", FListInteger.size(f3) == 3);
            assertTrue("f4 size", FListInteger.size(f4) == 4);
            assertTrue("f0.add size", 
                    FListInteger.size(FListInteger.add(f0, three)) ==
                    FListInteger.size(f0) + 1);
        }
        catch (Exception e) {
            System.out.println("Exception thrown during accessors tests:");
            System.out.println(e);
            assertTrue("accessors", false);
        }
    }
    
    /**
     * Test the usual overridden methods.
     */
    private void usual() {
        // Test toString
        assertTrue("f0 String", f0.toString().equals("[]"));
        assertTrue("f1 String", f1.toString().equals("[0]"));
        assertTrue("f2 String", f2.toString().equals("[1, 0]"));
        assertTrue("f3 String", 
                f3.toString().equals("[2, 1, 0]"));
        assertTrue("f4 String", 
                f4.toString().equals("[3, 2, 1, 0]"));
        
        // Test equals
        assertTrue("equal 00", f0.equals(f0));
        assertTrue("equal 11", f1.equals(f1));
        assertTrue("equal 22", f2.equals(f2));
        assertTrue("equal 33", f3.equals(f3));
        assertFalse("0 equals null", f0.equals(null));
        assertFalse("1 equals null", f1.equals(null));
        assertFalse("2 equals null", f2.equals(null));
        assertFalse("3 equals null", f3.equals(null));
        assertFalse("equal 01", f0.equals(f1));
        assertFalse("equal 21", f2.equals(f1));
        assertFalse("equal 31", f3.equals(f1));
        assertFalse("equal 10", f1.equals(f0));
        assertFalse("equal 02", f0.equals(f2));
        
        // Test hashCode
        assertTrue("hashCode 00", f0.hashCode() == f0.hashCode());
        assertTrue("hashCode 44", f1.hashCode() == f1.hashCode());
        assertTrue("hashCode 46", f2.hashCode() == f2.hashCode());
        assertTrue("hashCode 27", f3.hashCode() == f3.hashCode());
        
        
    }
    
    /**
     * Verify that 'test' is true
     * if it is not, report as such.
     * Effect: totalTests++
     * if (!test) totalErrors++
     * @param description What is the test about?
     * @param test What should be true
     */
    private void assertTrue(String description, Boolean test) {
        if (!test) {
            System.out.println("\n***** Test failed ***** "
                    + description + ": " + totalTests);
            totalErrors++;
        }
        totalTests++;
    }
    
    /**
     * Verify that 'test' is false
     * if not, report as such.
     * @see assertTrue
     * @param description What is the test about?
     * @param test What should be false?
     */
    private void assertFalse(String description, Boolean test) {
        assertTrue(description, !test);
    }
}










