import java.util.Comparator;

/**
 * StringByLex orders String lexigraphically.
 * @author Nick Jones
 * @version 10/8/2013
 */
public class StringByLex implements Comparator<String> {
    
    /**
     * @param s1 String 1
     * @param s2 String 2
     * @return s1.compareTo(s2)
     */
    public int compare(String s1, String s2) {
        return s1.compareTo(s2);
    }
    
    /**
     * Does that equal this?
     * @param that Object to compare to
     * @return true if that is an instance of StringByLex
     */
    public boolean equals(Object that) {
        return that instanceof StringByLex;
    }
    
    /**
     * Return a String rep. of this Comparator
     * @return "StringByLex"
     */
    public String toString() {
        return "StringByLex";
    }
}
