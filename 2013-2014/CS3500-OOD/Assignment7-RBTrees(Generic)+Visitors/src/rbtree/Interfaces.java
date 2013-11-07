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
     * Try to add a T to the RBTree.
     * 
     * @param s T to add
     */
    public void add(T s);

    /**
     * Does this RBTree contain s?
     * 
     * @param s The T to look for?
     * @return true if present.
     */
    public boolean contains(T s);

    /**
     * Is that a RBTree with the same Ts and Comparator as that?
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
     * How many Ts are in this RBTree
     * 
     * @return # of Ts in RBTree
     */
    public int size();

    /**
     * Make an array of all this Ts of this RBTree in order
     * 
     * @return an ordered ArrayList<T>
     */
    public ArrayList<T> toArrayList();

    /**
     * Get a String representing this RBTree
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString();

    /**
     * Generate a String that sorta represents the structure of this Tree.
     * 
     * @param the indentation for each level
     * @return the string
     */
    public String toStructString(String indent);

    /**
     * Is the representation of this IBTree valid?
     * 
     * @return true if valid, else false.
     */
    public boolean repOK();
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
interface IRBTree<T> extends IBTree<T>, Coloured {
}
