import java.util.Comparator;

/**
 * Comparator implementation that compares the reverse of the 
 * Strings by lexicographical ordering
 * 
 * @author Jessica Young Schmidt jschmidt
 * @version 2013-10-07
 */
class StringReverseByLex implements Comparator<String> {

    /**
     * compares o1 and o2
     * @param o1 first String in comparison
     * @param o2 second String in comparison
     * @return a negative integer, zero, or a positive integer 
     *         as the first argument is less than, equal to, or 
     *         greater than the second. 
     */
    public int compare(String o1, String o2) {
        String s1 = new StringBuffer(o1).reverse().toString();
        String s2 = new StringBuffer(o2).reverse().toString();
        return s1.compareTo(s2);
    }

    /**
     * Is this <code>Comparator</code> same as the given object
     * @param o the given object
     * @return true if the given object is an instance of this class
     */
    public boolean equals(Object o) {
        return (o instanceof StringReverseByLex);
    }

    /**
     * There should be only one instance of this class = all are equal
     * @return the hash code same for all instances
     */
    public int hashCode() {
        return (this.toString().hashCode());
    }

    /**
     * @return name of class
     */
    public String toString() {
        return "StringReverseByLex";
    }

}

/**
 * Comparator implementation that compares the 
 * Strings without prefix by lexicographical ordering
 * 
 * @author Jessica Young Schmidt jschmidt
 * @version 2013-10-07
 */
class StringWithOutPrefixByLex implements Comparator<String> {

    /**
     * compares o1 and o2
     * @param o1 first String in comparison
     * @param o2 second String in comparison
     * @return a negative integer, zero, or a positive integer 
     *         as the first argument is less than, equal to, or 
     *         greater than the second. 
     */
    public int compare(String o1, String o2) {
        String s1, s2;
        if(o1.length() > 4){
            s1 = o1.substring(3);
        }
        else { 
            s1 = o1;
        }
        if(o2.length() > 4){
            s2 = o2.substring(3);
        }
        else { 
            s2 = o2;
        }
        return s1.compareTo(s2);
    }

    /**
     * Is this <code>Comparator</code> same as the given object
     * @param o the given object
     * @return true if the given object is an instance of this class
     */
    public boolean equals(Object o) {
        return (o instanceof StringWithOutPrefixByLex);
    }

    /**
     * There should be only one instance of this class = all are equal
     * @return the hash code same for all instances
     */
    public int hashCode() {
        return (this.toString().hashCode());
    }

    /**
     * @return name of class
     */
    public String toString() {
        return "StringWithOutPrefixByLex";
    }

}