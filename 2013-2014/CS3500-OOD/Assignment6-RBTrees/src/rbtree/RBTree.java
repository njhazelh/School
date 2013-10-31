/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

package rbtree;

import java.util.ArrayList;

/**
 * RBTree is a mutable representation of Red Black Trees, a form of binary
 * search trees with good worst case efficiency.
 * 
 * @author Nicholas Jones
 * @version Oct 30, 2013
 */
public class RBTree<T> {
    private Comparator<T> comp;
    private IRBTree tree;
    
    public RBTree(Comparator<T> comp) {
        this.comp = comp;
        this.tree = RBTree.Leaf.LEAF;
    }
    
    /**
     * Color represents the color of a IRBTree, which is either Red or Black.
     * 
     * @author  Nicholas Jones
     * @version Oct 30, 2013
     */
    protected enum Color {
        RED, BLACK
    }
    
    /**
     * IRBTree is an interface for an immutable Red Black Tree of Strings that order
     * Strings according to Comparator given.
     * 
     * You cannot add to a leaf, so when building an IRBTree, the first step is
     * two swap out your leaf with a Node. Node is mutable, so any additions
     * from there change the structure without reassignment.
     * 
     * This version no longer has isLeaf, since try/catch is a more efficient
     * method of control. Rather than check isLeaf for all additions, assume
     * it's a Node, and catch the single instance it is not.
     * 
     * @author Nick Jones
     * @version Oct 30, 2013
     */
    private interface IRBTree {
        /**
         * Try to add a String to the BTree.
         * 
         * @param s String to add
         */
        public void add(String s);
        
        /**
         * Does this IBTree contain s?
         * 
         * @param s The String to look for?
         * @return true if present.
         */
        public boolean contains(String s);
        
        /**
         * Is that a IBTree with the same Strings and Comparator as that?
         * 
         * @param that The Object to compare this to.
         * @return true if equal.
         */
        @Override
        public boolean equals(Object that);
        
        /**
         * What is this IBTree's Color? See: BTree.Color enum.
         * 
         * @return The color it is.
         */
        public RBTree.Color getColor();
        
        /**
         * Get an int such that the hashCode/equals relationship holds true.
         * 
         * @return an int such that if two objects are equal, they have the same
         *         hashCode.
         */
        @Override
        public int hashCode();
        
        /**
         * How many Strings are in this IBTree
         * 
         * @return # of Strings in IBTree
         */
        public int size();
        
        /**
         * Make an array of all this Strings of this IBTree in order
         * 
         * @return an ordered ArrayList<String>
         */
        public ArrayList<String> toArrayList();
        
        /**
         * Get a string representing this IBTree
         * 
         * @return s1, s2, s3, ...
         */
        @Override
        public String toString();
    }
    
    protected static class Leaf implements IRBTree {
        public static final Leaf LEAF = new Leaf();
        
        
    }
    
    protected class Node implements IRBTree {
        
    }
}
