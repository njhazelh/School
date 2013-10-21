/**
 * Basic test program for assignment 1 - FSetString.
 * @author Clinger
 * @author Schmidt
 * @version 2013-09-09
 */
public class TestFSetString {

    /**
     * Runs the tests.
     * @param args the command line arguments
     */         
    public static void main(String args[]) {
        TestFSetString test = new TestFSetString();

        // Test with 0-argument FSetString.emptySet().

        System.out.println("Testing 0-argument emptySet()");
        test.creation();
        test.accessors(0);
        test.usual();
        test.accessors(0);    // test twice to detect side effects
        test.usual();

        test.summarize();
    }

    /**
     * Prints a summary of the tests.
     */
    private void summarize() {
        System.out.println();
        System.out.println(totalErrors + " errors found in " +
                totalTests + " tests.");
    }

    public TestFSetString() { }

    // String objects to serve as elements.

    private final String alice   = "Alice";
    private final String bob   = "Bob";
    private final String carol = "Carol";
    private final String dave  = "Dave";

    // FSetString objects to be created and then tested.

    private FSetString f0;    // { }
    private FSetString f1;    // { alice }
    private FSetString f2;    // { bob, alice }
    private FSetString f3;    // { carol, bob, alice }
    private FSetString f4;    // { dave, carol, bob, alice }
    private FSetString f5;    // { alice, bob, alice }
    private FSetString f6;    // { carol, dave, bob, alice }
    private FSetString f7;    // { alice, bob, bob, alice }

    private FSetString s1;    // { alice }
    private FSetString s2;    // { bob }
    private FSetString s3;    // { carol }
    private FSetString s4;    // { dave }

    private FSetString s12;    // { alice, bob }
    private FSetString s13;    // { alice, carol }
    private FSetString s14;    // { alice, dave }
    private FSetString s23;    // { bob, carol }
    private FSetString s34;    // { carol, dave }

    private FSetString s123;   // { alice, bob, carol }
    private FSetString s124;   // { alice, bob, dave }
    private FSetString s134;   // { alice, carol, dave }
    private FSetString s234;   // { bob, carol, dave }

    /**
     * Creates some FSetString objects.
     */
    private void creation() {
        try {
            f0 = FSetString.emptySet();
            f1 = FSetString.insert(f0, alice);
            f2 = FSetString.insert(f1, bob);
            f3 = FSetString.insert(f2, carol);
            f4 = FSetString.insert(f3, dave);
            f5 = FSetString.insert(f2, alice);
            f6 = FSetString.insert(FSetString.insert(f2, dave), carol);

            f7 = FSetString.insert(f0, alice);
            f7 = FSetString.insert(f7, bob);
            f7 = FSetString.insert(f7, bob);
            f7 = FSetString.insert(f7, alice);

            s1 = FSetString.insert(f0, alice);
            s2 = FSetString.insert(f0, bob);
            s3 = FSetString.insert(f0, carol);
            s4 = FSetString.insert(f0, dave);

            s12 = FSetString.insert(f1, "Bob");
            s13 = FSetString.insert(f1, "Carol");
            s14 = FSetString.insert(f1, "Dave");
            s23 = FSetString.insert(s2, "Carol");
            s34 = FSetString.insert(s3, "Dave");

            s123 = FSetString.add(s12, carol);
            s124 = FSetString.add(s12, dave);
            s134 = FSetString.add(s13, dave);
            s234 = FSetString.add(s23, dave);

            s134 = FSetString.add(s134, dave);
            s234 = FSetString.add(s234, dave);

        }
        catch(Exception e) {
            System.out.println("Exception thrown during creation tests:");
            System.out.println(e);
            assertTrue("creation", false);
        }
    }

    /**
     * Tests the accessors.
     */
    private void accessors(int nargs) {
        try {
            //testing isEmpty
            assertTrue("empty", FSetString.isEmpty(f0));
            assertFalse("nonempty", FSetString.isEmpty(f1));
            assertFalse("nonempty", FSetString.isEmpty(f3));

            //testing size
            assertTrue("f0.size()", FSetString.size(f0) == 0);
            assertTrue("f1.size()", FSetString.size(f1) == 1);
            assertTrue("f2.size()", FSetString.size(f2) == 2);
            assertTrue("f3.size()", FSetString.size(f3) == 3);
            assertTrue("f4.size()", FSetString.size(f4) == 4);
            assertTrue("f5.size()", FSetString.size(f5) == 2);
            assertTrue("f7.size()", FSetString.size(f7) == 2);

            //testing contains
            assertFalse("contains01", FSetString.contains(f0, alice));
            assertFalse("contains04", FSetString.contains(f0, dave));
            assertTrue("contains11", FSetString.contains(f1, alice));
            assertTrue("contains11n", FSetString.contains(f1, "Alice"));
            assertFalse("contains14", FSetString.contains(f1, dave));
            assertTrue("contains21", FSetString.contains(f2, alice));
            assertFalse("contains24", FSetString.contains(f2, dave));
            assertTrue("contains31", FSetString.contains(f3, alice));
            assertFalse("contains34", FSetString.contains(f3, dave));
            assertTrue("contains41", FSetString.contains(f4, alice));
            assertTrue("contains44", FSetString.contains(f4, dave));
            assertTrue("contains51", FSetString.contains(f5, alice));
            assertFalse("contains54", FSetString.contains(f5, dave));

            //testing isSubset
            assertTrue("isSubset00", FSetString.isSubset(f0, f0));
            assertTrue("isSubset01", FSetString.isSubset(f0, f1));
            assertFalse("isSubset10", FSetString.isSubset(f1, f0));
            assertTrue("isSubset02", FSetString.isSubset(f0, f2));
            assertFalse("isSubset20", FSetString.isSubset(f2, f0));
            assertTrue("isSubset24", FSetString.isSubset(f2, f4));
            assertFalse("isSubset42", FSetString.isSubset(f4, f2));
            assertTrue("isSubset27", FSetString.isSubset(f2, f7));
            assertTrue("isSubset72", FSetString.isSubset(f7, f2));
            assertTrue("isSubset 13 3", FSetString.isSubset(s13, f3));
            assertFalse("isSubset 3 13", FSetString.isSubset(f3, s13));
            assertTrue("isSubset 123 3", FSetString.isSubset(s123, f3));
            assertTrue("isSubset 3 123", FSetString.isSubset(f3, s123));

            //testing absent
            assertTrue("absent f0 1", 
                    FSetString.isEmpty(FSetString.absent(f0, alice)));
            assertTrue("absent f1 1", 
                    FSetString.isEmpty(FSetString.absent(f1, alice)));
            assertTrue("absent f1 2", 
                    FSetString.absent(f1, bob).equals(s1));
            assertTrue("absent f2 1", 
                    FSetString.absent(f2, alice).equals(s2));
            assertTrue("absent f2 2", 
                    FSetString.absent(f2, bob).equals(s1));
            assertTrue("absent f2 3", 
                    FSetString.absent(f2, carol).equals(s12));
            assertTrue("absent f2 12",
                    FSetString.isEmpty(FSetString.absent(
                            FSetString.absent(f2, alice),
                            bob)));
            assertTrue("absent f2 21",
                    FSetString.isEmpty(
                            FSetString.absent(FSetString.absent(f2, bob),
                            alice)));
            assertTrue("absent f6 1", 
                    FSetString.absent(f6, alice).equals(s234));
            assertTrue("absent f6 2", 
                    FSetString.absent(f6, bob).equals(s134));
            assertTrue("absent f6 3", 
                    FSetString.absent(f6, carol).equals(s124));
            assertTrue("absent f6 4", 
                    FSetString.absent(f6, dave).equals(s123));

            //testing union
            assertTrue("union f0 f0", 
                    FSetString.isEmpty(FSetString.union(f0, f0)));
            assertTrue("union f0 s1", FSetString.union(f0, s1).equals(s1));
            assertTrue("union s1 f0", FSetString.union(s1, f0).equals(s1));
            assertTrue("union s1 s1", FSetString.union(s1, s1).equals(s1));
            assertTrue("union s1 s2", FSetString.union(s1, s2).equals(s12));
            assertTrue("union s1 s4", FSetString.union(s1, s4).equals(s14));
            assertTrue("union s2 s1", FSetString.union(s2, s1).equals(s12));
            assertTrue("union s2 s2", FSetString.union(s2, s2).equals(s2));
            assertTrue("union s12 s3", 
                    FSetString.union(s12, s3).equals(s123));
            assertTrue("union s3 s12", 
                    FSetString.union(s3, s12).equals(s123));
            assertTrue("union s13 s2", 
                    FSetString.union(s13, s2).equals(s123));
            assertTrue("union s2 s13", 
                    FSetString.union(s2, s13).equals(s123));
            assertTrue("union s123 s234",
                    FSetString.union(s123, s234).equals(f4));
            assertTrue("union f4 f6",
                    FSetString.union(f4, f6).equals(f4));
            assertTrue("union f6 f4",
                    FSetString.union(f6, f4).equals(f4));
            assertTrue("union f6 f7",
                    FSetString.union(f6, f7).equals(f4));
            assertTrue("union f7 f6",
                    FSetString.union(f7, f6).equals(f4));

            //testing intersect
            assertTrue("intersect f0 f0",
                    FSetString.isEmpty(FSetString.intersect(f0, f0)));
            assertTrue("intersect f0 s1",
                    FSetString.isEmpty(FSetString.intersect(f0, s1)));
            assertTrue("intersect s1 f0",
                    FSetString.isEmpty(FSetString.intersect(s1, f0)));
            assertTrue("intersect s1 s1",
                    FSetString.intersect(s1, s1).equals(s1));
            assertTrue("intersect s1 s2",
                    FSetString.isEmpty(FSetString.intersect(s1, s2)));
            assertTrue("intersect s2 s1",
                    FSetString.isEmpty(FSetString.intersect(s2, s1)));
            assertTrue("intersect s2 s2",
                    FSetString.intersect(s2, s2).equals(s2));
            assertTrue("intersect s12 s3",
                    FSetString.isEmpty(FSetString.intersect(s12, s3)));
            assertTrue("intersect s3 s12",
                    FSetString.isEmpty(FSetString.intersect(s3, s12)));
            assertTrue("intersect s13 s2",
                    FSetString.isEmpty(FSetString.intersect(s13, s2)));
            assertTrue("intersect s2 s13",
                    FSetString.isEmpty(FSetString.intersect(s2, s13)));
            assertTrue("intersect s123 s234",
                    FSetString.intersect(s123, s234).equals(s23));
            assertTrue("intersect f4 f6",
                    FSetString.intersect(f4, f6).equals(
                            FSetString.union(s12, s34)));
            assertTrue("intersect f6 f4",
                    FSetString.intersect(f6, f4).equals(
                            FSetString.union(s12, s34)));
            assertTrue("intersect f6 f7",
                    FSetString.intersect(f6, f7).equals(s12));
            assertTrue("intersect f7 f6",
                    FSetString.intersect(f7, f6).equals(s12));
        }
        catch(Exception e) {
            System.out.println("Exception thrown during accessors tests:");
            System.out.println(e);
            assertTrue("accessors", false);
        }
    }

    /**
     * Tests the usual overridden methods.
     */
    private void usual() {
        try {
            //testing toString
            assertTrue("toString0",
                    f0.toString().equals("{...(0 elements)...}"));
            assertTrue("toString1",
                    f1.toString().equals("{...(1 elements)...}"));
            assertTrue("toString7",
                    f7.toString().equals("{...(2 elements)...}"));

            //testing equals
            assertTrue("equals00", f0.equals(f0));
            assertTrue("equals33", f3.equals(f3));
            assertTrue("equals55", f5.equals(f5));
            assertTrue("equals46", f4.equals(f6));
            assertTrue("equals64", f6.equals(f4));
            assertTrue("equals27", f2.equals(f7));
            assertTrue("equals72", f7.equals(f2));

            assertFalse("equals01", f0.equals(f1));
            assertFalse("equals02", f0.equals(f2));
            assertFalse("equals10", f1.equals(f0));
            assertFalse("equals12", f1.equals(f2));
            assertFalse("equals21", f2.equals(f1));
            assertFalse("equals23", f2.equals(f3));
            assertFalse("equals35", f3.equals(f5));

            assertFalse("equals0string", f0.equals("just a string"));
            assertFalse("equals4string", f4.equals("just a string"));

            assertFalse("equals0null", f0.equals(null));
            assertFalse("equals1null", f1.equals(null));

            //testing hashCode
            assertTrue("hashCode00", f0.hashCode() == f0.hashCode());
            assertTrue("hashCode44", f4.hashCode() == f4.hashCode());
            assertTrue("hashCode46", f4.hashCode() == f6.hashCode());
            assertTrue("hashCode27", f2.hashCode() == f7.hashCode());
        }
        catch(Exception e) {
            System.out.println("Exception thrown during usual tests:");
            System.out.println(e);
            assertTrue("usual", false);
        }
    }

    ////////////////////////////////////////////////////////////////

    private int totalTests = 0;       // tests run so far
    private int totalErrors = 0;      // errors so far

    /**
     * Prints failure report if the result is not true.
     * @param name the name of the test
     * @param result the result to test
     */
    private void assertTrue(String name, boolean result) {
        if(! result) {
            System.out.println();
            System.out.println("***** Test failed ***** "
                    + name + ": " +totalTests);
            totalErrors = totalErrors + 1;
        }/*else{
        System.out.println("----- Test passed ----- "
                   + name + ": " +totalTests);
                   }*/
        totalTests = totalTests + 1;
    }

    /**
     * Prints failure report if the result is not false.
     * @param name the name of the test
     * @param result the result to test
     */
    private void assertFalse(String name, boolean result) {
        assertTrue(name, ! result);
    }

}
