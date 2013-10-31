/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

import java.util.ArrayList;
import java.util.Comparator;

/**
 * BTree is an implementation of BinaryTrees of Strings using Red/Black trees,
 * which balance the tree to maintain good worst case efficiency.
 * 
 * INVARIANTS:
 *  - No red node has a Red Parent.
 *  - Every path from the root to an empty node contains the same number of
 *    black nodes. 
 * 
 * @author Nick Jones
 * @version 10/26/2013
 * 
 */
public class BTree {
    private Comparator<String> comp;
    private IRBTree            tree;
    
    private BTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = Leaf.LEAF;
    }
    
    public BTree binTree(Comparator<String> comp) {
        return new BTree(comp);
    }
    
    /**
     * Color is either red or black.
     * 
     * @author Nick Jones
     * @version 10/26/2013
     */
    private static enum Color {
        RED, BLACK;
    }
    
    /**
     * IBTree is an interface for an immutable Binary Tree of Strings that order
     * Strings according to Comparator given.
     * 
     * You cannot add to a leaf, so when building an IBTree, the first step is
     * two swap out your leaf with a Node. Node is mutable, so any additions
     * from there change the structure without reassignment.
     * 
     * This version no longer has isLeaf, since try/catch is a more efficient
     * method of control. Rather than check isLeaf for all additions, assume
     * it's a Node, and catch the single instance it is not.
     * 
     * @author Nick Jones
     * @version 10/26/2013
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
        public BTree.Color getColor();
        
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
    
    /**
     * Leaf is a terminating element of an IBTree.
     * It is a singleton Object that can only be accessed from Leaf.LEAF.
     * 
     * @author Nick Jones
     * @version 10/26/2013
     * 
     */
    private static class Leaf implements IRBTree {
        public static final Leaf LEAF = new Leaf();
        
        /**
         * Force the constructor to be private.
         * Only method of access is from Leaf.LEAF, since Leaf is a singleton
         * object.
         */
        private Leaf() {}
        
        /**
         * Cannot add to a Leaf. Instead swap with Node on higher level.
         * 
         * @throws UnsupportedOperationException
         */
        @Override
        public void add(String s) throws UnsupportedOperationException {
            throw new UnsupportedOperationException("Cannot Add to a Leaf");
        }
        
        /**
         * Leaves do not contain Strings.
         * 
         * @return false
         */
        @Override
        public boolean contains(String s) {
            return false;
        }
        
        /**
         * Is that an instance of Leaf?
         * 
         * @return true if instance of Leaf.
         */
        @Override
        public boolean equals(Object that) {
            return that instanceof Leaf;
        }
        
        /**
         * All Leaves are Black.
         * 
         * @return BTree.Color.BLACK
         */
        @Override
        public BTree.Color getColor() {
            return BTree.Color.BLACK;
        }
        
        /**
         * Fulfill that hashCode/equals agreement.
         * 
         * @return An int such that if this IBTree equals another then their
         *         hashCodes are equal.
         */
        @Override
        public int hashCode() {
            return 0;
        }
        
        /**
         * How many Strings are in this Leaf?
         * 
         * @return 0
         */
        @Override
        public int size() {
            return 0;
        }
        
        /**
         * Make an ArrayList with all the Strings in this IBTree in order
         * 
         * @return an empty ArrayList<String>
         */
        @Override
        public ArrayList<String> toArrayList() {
            return new ArrayList<String>();
        }
        
        /**
         * Get a String representing the Strings in this IBTree.
         * 
         * @return an empty String.
         */
        @Override
        public String toString() {
            return "";
        }
    }
    
    /**
     * Node is a Mutable, non-terminating branch of an IBTree. Additions to it
     * mutate it's structure to avoid building an entirely new IBTree every
     * addition.
     * 
     * @author Nick Jones
     * @version 10/26/2013
     * 
     */
    private class Node implements IRBTree {
        
    }
}
