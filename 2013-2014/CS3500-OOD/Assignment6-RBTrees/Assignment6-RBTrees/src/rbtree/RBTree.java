/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

package rbtree;

import java.util.ArrayList;
import java.util.Comparator;

/**
 * RBTree is a mutable representation of Red Black Trees, a form of binary
 * search trees with good worst case efficiency.
 * 
 * @author Nicholas Jones
 * @version Oct 30, 2013
 */
public abstract class RBTree {
    /**
     * Factory: Create an empty RBTree.
     * 
     * @param comp The Comparator<String> to use to organize Strings.
     * @return an empty RBTree.
     */
    public static RBTree binTree(Comparator<String> comp) {
        return new Leaf(comp);
    }
    
    /**
     * Try to add a String to the RBTree.
     * 
     * @param s String to add
     */
    public void add(String s);
    
    /**
     * Does this IRBTree contain s?
     * 
     * @param s The String to look for?
     * @return true if present.
     */
    public boolean contains(String s);
    
    /**
     * Is that a IRBTree with the same Strings and Comparator as that?
     * 
     * @param that The Object to compare this to.
     * @return true if equal.
     */
    @Override
    public boolean equals(Object that);
    
    /**
     * Get the color of this RBTree.
     * 
     * @return Red or Black.
     */
    public Color getColor();
    
    /**
     * Get an int such that the hashCode/equals relationship holds true.
     * 
     * @return an int such that if two objects are equal, they have the same
     *         hashCode.
     */
    @Override
    public int hashCode();
    
    /**
     * Is this a Leaf?
     * 
     * @return true if it is a Leaf.
     */
    public boolean isLeaf();
    
    /**
     * Change the color of this RBTree.
     * 
     * @param c The new Color(RED|BLACK)
     */
    public void setColor(Color c);
    
    /**
     * How many Strings are in this IRBTree
     * 
     * @return # of Strings in IRBTree
     */
    public int size();
    
    /**
     * Make an array of all this Strings of this IRBTree in order
     * 
     * @return an ordered ArrayList<String>
     */
    public ArrayList<String> toArrayList();
    
    /**
     * Get a string representing this IRBTree
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString();
}