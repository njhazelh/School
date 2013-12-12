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
interface IBTree extends Iterable<String> {
    /**
     * Try to add a String to the RBTree.
     * 
     * @param s String to add
     */
    public void add(String s);

    /**
     * Does this RBTree contain s?
     * 
     * @param s The String to look for?
     * @return true if present.
     */
    public boolean contains(String s);

    /**
     * Is that a RBTree with the same Strings and Comparator as that?
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
     * How many Strings are in this RBTree
     * 
     * @return # of Strings in RBTree
     */
    public int size();

    /**
     * Make an array of all this Strings of this RBTree in order
     * 
     * @return an ordered ArrayList<String>
     */
    public ArrayList<String> toArrayList();

    /**
     * Get a string representing this RBTree
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString();

    /**
     * Generate a String that sorta represents the structure of this Tree.
     * 
     * @return the string
     */
    public String toStructString();
    
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
interface Interfaces {
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
interface IRBTree extends IBTree, Interfaces {
}
