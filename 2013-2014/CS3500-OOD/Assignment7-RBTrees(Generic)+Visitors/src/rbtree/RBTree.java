/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

package rbtree;

import java.util.ArrayList;

/**
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
interface IBTree<T> extends Iterable<T> {
    /**
     * Try to add a T to the IBTree.
     * 
     * @param s T to add
     */
    public void add(T s);

    /**
     * Does this IBTree contain s?
     * 
     * @param s The T to look for?
     * @return true if present.
     */
    public boolean contains(T s);

    /**
     * Is that an IBTree with the same Ts and Comparator as this?
     * 
     * @param that The Object to compare this to.
     * @return true if equal.
     */
    @Override
    public boolean equals(Object that);

    /**
     * Get an int such that the hashCode/equals relationship holds true.
     * 
     * @return an int such that if two objects are equal, they have the same
     *         hashCode.
     */
    @Override
    public int hashCode();

    /**
     * How many Ts are in this IBTree
     * 
     * @return # of Ts in IBTree
     */
    public int size();

    /**
     * Make an array of all this Ts of this IBTree in order
     * 
     * @return an ordered ArrayList<T>
     */
    public ArrayList<T> toArrayList();

    /**
     * Get a String representing this IBTree
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString();

    /**
     * Generate a String that represents the structure of this IBTree.
     * 
     * @param the indentation for each level: "\t\t...". Start at "".
     * @return the string
     */
    public String toStructString(String indent);

    /**
     * Is the representation of this IBTree valid?
     * 
     * @return true if valid, else false.
     */
    public boolean repOK();
    
    /**
     * Apply the given visitor to this tree.
     * 
     * @param visitor visitor to use.
     * @return the result of the visitor operations.
     */
    public <R> R accept(RBTreeVisitor<T, R> visitor);
}

/**
 * Coloured because England!
 * 
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
interface Coloured {
    /**
     * What is the color of this thing?
     * 
     * @return the color of this.
     */
    public Color getColor();

    /**
     * Set the Color of this thing
     * 
     * @param c the new color
     */
    public void setColor(Color c);
}

/**
 * This is a union of the two interfaces, Coloured and IBTree.
 * 
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
public interface RBTree<T> extends IBTree<T>, Coloured {
}
