import java.util.Comparator;

/**
 * StringByLength orders Strings by length.
 * @author Nick Jones
 * @version 10/8/2013
 */
class StringByLength implements Comparator<String> {
    
    /**
     * @param s1 String 1
     * @param s2 String 2
     * @return s1.length - s2.length
     */
    public int compare(String s1, String s2) {
        return s1.length() - s2.length();
    }
    
    /**
     * Does that equal this?
     * @param that Object to compare to
     * @return true if that is an instance of StringByLength
     */
    public boolean equals(Object that) {
        return that instanceof StringByLength;
    }
    
    /**
     * Return a String rep. of this Comparator
     * @return "StringByLength"
     */
    public String toString() {
        return "StringByLength";
    }
}

