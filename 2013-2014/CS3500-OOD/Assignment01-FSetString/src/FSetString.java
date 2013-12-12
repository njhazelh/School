/*
 * Name: Nick Jones
 * njhazelh@zimbra.ccs.neu.edu
 * n/a
 */

/**
 * FSetString is a Factory Object that provides a series of <code>static</code>
 * methods for dealing with sets of <code>String</code>s.
 * @author Nick Jones
 * @version 0.1 9/11/2013
 */
abstract class FSetString {
    
    /**
     * BASIC CONSTRUCTOR
     * Creates a representation of an empty set of <code>String</code>s.
     * @return an FSetString representing an empty set
     */
    public static FSetString emptySet() {
        return new MTFSetString();
    }
    
    /**
     * Insert <code>String</code> s into <code>FSetString</code> set, given that
     * it does not already exist within the set.
     * @param set the set to insert into
     * @param s the string to insert
     * @return set with s in it
     */
    public static FSetString insert(FSetString set, String s) {
        return set.insert(s);
    }
    
    /**
     * Insert <code>String</code> s into <code>FSetString</code> set given that
     * it does not already exist within the set.
     * @param set the set to insert into
     * @param s the string to insert
     * @return set with s in it
     */
    public static FSetString add(FSetString set, String s)  {
        return set.add(s);
    }
    
    /**
     * How many elements are in the <code>FSetString</code>?
     * @param set The <code>FSetString</code> to count the elements of.
     * @return The number of elements in the <code>FSetString</code>.
     */
    public static int size(FSetString set) {
        return set.size();
    }
    
    /**
     * Is the <code>FSetString</code> empty?
     * @param set The <code>FSetString</code> to check
     * @return <code>true</code> if <code>FSetString</code> is empty, 
     * else <code>false</code>.
     */
    public static boolean isEmpty(FSetString set) {
        return set.isEmpty();
    }
    
    /**
     * Does the given <code>FSetString</code> contain the <code>String</code> s?
     * @param set The <code>FSetString</code> to check in.
     * @param s The <code>String</code> to check for.
     * @return <code>true</code> if the <code>FSetString</code> contains the
     * <code>String</code> s, else <code>false</code>.
     */
    public static boolean contains(FSetString set, String s) {
        return set.contains(s);
    }
    
    /**
     * Is <code>set1</code> a subset of <code>set2</code>?
     * @param set1 The <code>FSetString</code> that may be a subset
     * @param set2 The <code>FSetString</code> that may contain 
     * <code>set1</code>.
     * @return <code>true</code> if <code>set1</code> is a subset of
     * <code>set2</code>.
     */
    public static boolean isSubset(FSetString set1, FSetString set2) {
        return set1.isSubset(set2);
    }
    
    /**
     * Remove the <code>String</code> s from the <code>FSetString</code> set.
     * @param set The <code>FSetString</code> to remove from.
     * @param s The <code>String</code> to remove.
     * @return A <code>FSetString</code> without s.
     */
    public static FSetString absent(FSetString set, String s) {
        return set.absent(s);
    }
    
    /**
     * Create a <code>FSetString</code> with all the elements for set1 and set2.
     * @param set1 The first <code>FSetString</code>
     * @param set2 The second <code>FSetString</code>
     * @return A <code>FSetString</code> with all the elements of set1 and set2
     * but no repeats.
     */
    public static FSetString union(FSetString set1, FSetString set2) {
        return set1.union(set2);
    }
    
    /**
     * Create a <code>FSetString</code> with the elements that are in both
     * set1 and set2.
     * @param set1 The first <code>FSetString</code>
     * @param set2 The second <code>FSetString</code>
     * @return A <code>FSetString</code> with the elements that are in both
     * set1 and set2.
     */
    public static FSetString intersect(FSetString set1, FSetString set2) {
        return set1.intersect(set2);
    }
    
    /**
     * Create a <code>FSetString</code> with all the elements in this set and
     * the <code>String</code> s, given that s does not already
     * exist within this set.
     * @param s the string to insert
     * @return A <code>ListFSetString</code> with s in it.
     */
    public abstract FSetString insert(String s);
    
    /**
     * Create a <code>FSetString</code> with all the elements in this set and
     * the <code>String</code> s into this set, given that s does not already
     * exist within the set.
     * @param s the string to insert
     * @return A <code>ListFSetString</code> with s in it.
     */
    public abstract FSetString add(String s);
    
    /**
     * How many elements are in this <code>FSetString</code>?
     * @return The number of elements in this <code>FSetString</code>.
     */
    public abstract int size();
    
    /**
     * Is this <code>FSetString</code> empty?
     * @return <code>true</code> if this <code>FSetString</code> is empty, 
     * else <code>false</code>.
     */
    public abstract boolean isEmpty();
    
    /**
     * Does this <code>FSetString</code> contain the
     * <code>String</code> s?
     * @param s The <code>String</code> to check for.
     * @return <code>true</code> if this <code>FSetString</code> contains the
     * <code>String</code> s, else <code>false</code>.
     */
    public abstract boolean contains(String s);
    
    /**
     * Is <code>this</code> a subset of <code>that</code>?
     * @param that The <code>FSetString</code> that may contain 
     * <code>this</code>.
     * @return <code>true</code> if <code>this</code> is a subset of
     * <code>that</code>.
     */
    public abstract boolean isSubset(FSetString that);
    
    /**
     * Remove the <code>String</code> s from this set.
     * @param s The <code>String</code> to remove.
     * @return A <code>FSetString</code> without s but all the other elements
     * of this.
     */
    public abstract FSetString absent(String s);
    
    /**
     * Create a <code>FSetString</code> with all the elements of
     * this and that.
     * @param that The <code>FSetString</code> to combine with
     * @return A <code>FSetString</code> with all the elements of this and that
     * but no repeats.
     */
    public abstract FSetString union(FSetString that);
    
    /**
     * Create a <code>FSetString</code> with the elements that are in both
     * this and that.
     * @param that The <code>FSetString</code> to combine with
     * @return A <code>FSetString</code> with the elements that are in both
     * this and that.
     */
    public abstract FSetString intersect(FSetString that);
    
    /**
     * Create a <code>String</code> that represents this set.
     * @return "{...(this.size() elements)...}"
     */
    public abstract String toString();
    
    /**
     * Does this equal that?
     * @param that The <code>Object</code> to compare to.
     * @return <code>true</code> if that is not null, is the same type, and
     * has the same elements as this (no more or less).
     */
    public abstract boolean equals(Object that);
    
    /**
     * Create a non-unique int for this, such that
     * this.equals(that) => this.hashCode() == that.hashCode() 
     * @return a non-unique int representing this set.
     */
    public abstract int hashCode();
    
    /**
     * Create a <code>FSetString</code> with all the same elements as this.
     * @return A <code>FSetString</code> with all the same elements.
     */
    public abstract FSetString clone();
}

/**
 * MTFSetString
 * @author Nicholas Jones
 * @version 1.0 - 9/16/2013
 */
class MTFSetString extends FSetString {
    
    /**
     * Insert <code>String</code> s into the set.
     * @param s The <code>String</c to insert
     * @return A new <code>ListFSetString</code> with the <code>String</code> s
     */
    public FSetString insert(String s) {
        return new ListFSetString(this.clone(), s);
    }
    
    /**
     * Insert <code>String</code> s into the set. Similar to 
     * {@link #insert(String) insert}.
     * @param s The <code>String</code> to insert
     * @return A new <code>ListFSetString</code> with the <code>String</code>
     * s.
     */
    public FSetString add(String s) {
        return this.insert(s);
    }
    
    /**
     * How many elements are in this <code>MTFSetString</code>?
     * @return 0 elements are in this Set
     */
    public int size() {
        return 0;
    }
    
    /**
     * Is this <code>MTFSetString</code> empty?
     * @return It is empty.
     */
    public boolean isEmpty() {
        return true;
    }
    
    /**
     * Does this <code>MTFSetString</code> contain a <code>String</code> s?
     * @param s The <code>String</code> to look for.
     * @return false.  There are no Strings in an <code>MTFSetString</code>
     */
    public boolean contains(String s) {
        return false;
    }
    
    /**
     * Is this <code>MTFSetString</code> a subset of <code>FSetString</code>
     * that?
     * @param that The <code>FSetString</code> to compare to.
     * @return true.  <code>MTFSetString</code>'s are subsets of all
     * <code>FSetString</code>
     */
    public boolean isSubset(FSetString that) {
        return true;
    }
    
    /**
     * Remove the <code>String</code> s from the <code>MTFSetString</code>
     * @param s The String to remove
     * @return An <code>MTFSetString</code>.  It's already empty.
     */
    public FSetString absent(String s) {
        return new MTFSetString();
    }
    
    /**
     * Create a <code>FSetString</code> with all the elements in this empty set
     * and a given set.
     * @param that The <code>FSetString</code> to combine with.
     * @return that, since this has no elements.
     */
    public FSetString union(FSetString that) {
        return that.clone();
    }
    
    /**
     * Create a <code>FSetString</code> with the elements that are in both
     * this and that.
     * @param that The <code>FSetString</code> to combine with.
     * @return An empty set, since this has no elements and, thus, shares no
     * elements with <code>that</code>.
     */
    public FSetString intersect(FSetString that) {
        return new MTFSetString();
    }
    
    /**
     * Create a <code>String</code> that represents this set.
     * @return "{...(0 elements)...}"
     */
    @Override
    public String toString() {
        return "{...(0 elements)...}";
    }
    
    /**
     * Is <code>that</code> also a MTFSetString?
     * @param that The <code>Object</code> to compare to.
     * @return <code>true</code> if that is an instance of
     * <code>MTFSetString</code>.  Else <code>false</code>.
     */
    @Override
    public boolean equals(Object that) {
        return  that instanceof MTFSetString;
    }
    
    /**
     * Create a non-unique int for this, such that
     * this.equals(that) => this.hashCode() == that.hashCode() 
     * @return 0, a non-unique int representing this set.
     */
    @Override
    public int hashCode() {
        return 0;
    }
    
    /**
     * Create a <code>FSetString</code> with all the same elements as this.
     * @return A <code>FSetString</code> with no elements.
     */
    @Override
    public FSetString clone() {
        return new MTFSetString();
    }
}

/**
 * ListFSetString is an implementation of sets using a stack architecture where
 * each level has a String and an FSetString, and the lowest level is a
 * MTFSetString.
 * @author Nicholas Jones
 * @version 1.0 - 9/16/2013
 */
class ListFSetString extends FSetString {
    private FSetString sub;
    private String str;
    
    /**
     * CONSTRUCTOR
     * @param sub The <code>FSetString</code> without <code>str</code>
     * @param str The new <code>String</code> in the set.
     */
    public ListFSetString(FSetString sub, String str) {
        this.sub = sub;
        this.str = str;
    }
    
    /**
     * Get the String on this level of the set.
     * @return The first String in the set.  Think "stacks".
     */
    public String getFirst() {
        return str;
    }
    
    /**
     * Get the rest of the <code>FSetString</code> with out the first
     * <code>String</code>.
     * @return The rest of the set.
     */
    public FSetString getRest() {
        return sub;
    }
    
    /**
     * Create a <code>FSetString</code> with all the elements in this set and
     * the <code>String</code> s, given that s does not already
     * exist within this set.
     * @param s the string to insert
     * @return A <code>ListFSetString</code> with s in it.
     */
    public FSetString insert(String s) {
        if (!this.contains(s)) {
            return new ListFSetString(this.clone(), s);
        }
        else {
            return this.clone();
        }
    }

    /**
     * Create a <code>FSetString</code> with all the elements in this set and
     * the <code>String</code> s, given that s does not already
     * exist within this set. Same as {@link #insert(String) insert}.
     * @param s the string to insert
     * @return A <code>ListFSetString</code> with s in it.
     */
    public FSetString add(String s) {
        return this.insert(s);
    }
    
    /**
     * How many elements are in this <code>FSetString</code>?
     * @return The number of elements in this <code>FSetString</code>.
     */
    public int size() {
        return this.sub.size() + 1;
    }
    
    /**
     * Is this <code>FSetString</code> empty?
     * @return <code>false</code>, it's not empty.
     */
    public boolean isEmpty() {
        return false;
    }
    
    /**
     * Does this <code>FSetString</code> contain the
     * <code>String</code> s?
     * @param s The <code>String</code> to check for.
     * @return <code>true</code> if this <code>FSetString</code> contains the
     * <code>String</code> s, else <code>false</code>.
     */
    public boolean contains(String s) {
        return str.equals(s) || sub.contains(s);
    }
    
    /**
     * Is <code>this</code> a subset of <code>that</code>?
     * @param that The <code>FSetString</code> that may contain 
     * <code>this</code>.
     * @return <code>true</code> if <code>this</code> is a subset of
     * <code>that</code>.
     */
    public boolean isSubset(FSetString that) {
        FSetString temp = this;
        
        while (!temp.isEmpty()) {
            if (!that.contains(((ListFSetString)temp).getFirst())) {
                return false;
            }
            temp = ((ListFSetString)temp).getRest();
        }
        return true;
    }
    
    /**
     * Remove the <code>String</code> s from this set.
     * @param s The <code>String</code> to remove.
     * @return A <code>FSetString</code> without s but all the other elements
     * of this.
     */
    public FSetString absent(String s) {
        FSetString newSet = new MTFSetString();
        FSetString temp = this;
        
        while (!temp.isEmpty()) {
            if (!((ListFSetString)temp).getFirst().equals(s)) {
                newSet = newSet.add(((ListFSetString)temp).getFirst());
            }
            temp = ((ListFSetString)temp).getRest();
        }
        
        return newSet;
    }
    
    /**
     * Create a <code>FSetString</code> with all the elements of
     * this and that.
     * @param that The <code>FSetString</code> to combine with
     * @return A <code>FSetString</code> with all the elements of this and that
     * but no repeats.
     */
    public FSetString union(FSetString that) {
        FSetString newSet = this.clone();
        
        while (!that.isEmpty()) {
            newSet = newSet.add(((ListFSetString)that).getFirst());
            that = ((ListFSetString)that).getRest();
        }
        
        return newSet;
    }
    
    /**
     * Create a <code>FSetString</code> with the elements that are in both
     * this and that.
     * @param that The <code>FSetString</code> to combine with
     * @return A <code>FSetString</code> with the elements that are in both
     * this and that.
     */
    public FSetString intersect(FSetString that) {
        FSetString newSet = new MTFSetString();
        FSetString temp = this;
        
        while (!temp.isEmpty()) {
            if (that.contains(((ListFSetString)temp).getFirst())) {
                newSet = newSet.add(((ListFSetString)temp).getFirst());
            }
            temp = ((ListFSetString)temp).getRest();
        }
        
        return newSet;
    }
    
    /**
     * Create a <code>String</code> that represents this set.
     * @return <code>"{...(this.size() elements)...}"</code>
     */
    @Override
    public String toString() {
        return "{...(" + this.size() + " elements)...}";
    }
    
    /**
     * Does this equal that?
     * @param that The <code>Object</code> to compare to.
     * @return <code>true</code> if that is not null, is the same type, and
     * has the same elements as this (no more or less).
     */
    @Override
    public boolean equals(Object that) {
        return  that instanceof ListFSetString &&
                that.hashCode() == this.hashCode() &&
                this.isSubset((FSetString)that) &&
                ((FSetString)that).isSubset(this);
    }
    
    /**
     * Create a non-unique int for this, such that
     * this.equals(that) => this.hashCode() == that.hashCode() 
     * @return a non-unique int representing this set.
     */
    public int hashCode() {
        return this.size();
    }
    
    /**
     * Create a <code>FSetString</code> with all the same elements as this.
     * @return A <code>FSetString</code> with all the same elements.
     */
    @Override
    public FSetString clone() {
        FSetString newSet = new MTFSetString();
        FSetString temp = this;
        while (!temp.isEmpty()) {
            newSet = newSet.add(((ListFSetString)temp).getFirst());
            temp = ((ListFSetString)temp).getRest();
        }
        
        return newSet;
    }
}