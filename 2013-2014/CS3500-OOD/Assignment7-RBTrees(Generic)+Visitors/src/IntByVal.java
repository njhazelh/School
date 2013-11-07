/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.Comparator;

public class IntByVal implements Comparator<Integer> {

    public boolean repOK() {
        return this.compare(new Integer(2), new Integer(3)) < 0 &&
               this.compare(new Integer(3), new Integer(3)) == 0 &&
               this.compare(new Integer(3), new Integer(2)) > 0;
    }
    
    /**
     * Compare n1 to n2 using compareTo
     * @param n1 integer 1
     * @param n2 integer 2
     * @return n1.compareTo(n2)
     */
    @Override
    public int compare(Integer n1, Integer n2) {
        return n1.compareTo(n2);
    }
    
    /**
     * Does that equal this?
     * 
     * @param that Object to compare to
     * @return true if that is an instance of IntByVal
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof IntByVal;
    }
    
    /**
     * Return a String rep. of this Comparator
     * 
     * @return "IntByVal"
     */
    @Override
    public String toString() {
        return "IntByVal";
    }
}
