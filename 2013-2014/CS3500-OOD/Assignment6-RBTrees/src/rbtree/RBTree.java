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
public class RBTree {
    private Comparator<String> comp;
    private IRBTree            tree;
    
    /**
     * Create an empty RBTree with this 
     * @param comp
     */
    private RBTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = RBTree.Leaf.LEAF;
    }
    
    /**
     * Color represents the color of a IRBTree, which is either Red or Black.
     * 
     * @author Nicholas Jones
     * @version Oct 30, 2013
     */
    protected enum Color {
        RED, BLACK
    }
    
    /**
     * IRBTree is an interface for an immutable Red Black Tree of Strings that
     * order Strings according to Comparator given.
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
         * What is this IRBTree's Color? See: RBTree.Color enum.
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
    
    /**
     * Leaf is a singleton representation of a terminating node in a red black
     * tree.
     * 
     * You cannot add to a Leaf. Instead attempt to add, and catch exception.
     * This is more efficient, since most cases off IRBTree addtion are not
     * Nodes not Leaves.
     * 
     * @author Nicholas Jones
     * @version Oct 30, 2013
     */
    private static class Leaf implements IRBTree {
        /**
         * This is the only way to access LEAF.
         */
        public static final Leaf LEAF = new Leaf();
        
        /**
         * Force the constructor to be private. Only method of access is from
         * Leaf.LEAF, since Leaf is a singleton object.
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
         * All Leaves are BLACK.
         * 
         * @return RBTree.Color.BLACK
         */
        @Override
        public BTree.Color getColor() {
            return RBTree.Color.BLACK;
        }
        
        /**
         * Fulfill that hashCode/equals agreement.
         * 
         * @return An int such that if this IRBTree equals another then their
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
         * Make an ArrayList with all the Strings in this IRBTree in order
         * 
         * @return an empty ArrayList<String>
         */
        @Override
        public ArrayList<String> toArrayList() {
            return new ArrayList<String>();
        }
        
        /**
         * Get a String representing the Strings in this IRBTree.
         * 
         * @return an empty String.
         */
        @Override
        public String toString() {
            return "";
        }
    }
    
    /**
     * 
     * @author Nicholas Jones
     * @version Oct 30, 2013
     */
    protected class Node implements IRBTree {
        
        /*
         * (non-Javadoc)
         * 
         * @see rbtree.RBTree.IRBTree#add(java.lang.String)
         */
        @Override
        public void add(String s) {
            // TODO Auto-generated method stub
            
        }
        
        /*
         * (non-Javadoc)
         * 
         * @see rbtree.RBTree.IRBTree#contains(java.lang.String)
         */
        @Override
        public boolean contains(String s) {
            // TODO Auto-generated method stub
            return false;
        }
        
        /*
         * (non-Javadoc)
         * 
         * @see rbtree.RBTree.IRBTree#getColor()
         */
        @Override
        public Color getColor() {
            // TODO Auto-generated method stub
            return null;
        }
        
        /*
         * (non-Javadoc)
         * 
         * @see rbtree.RBTree.IRBTree#size()
         */
        @Override
        public int size() {
            // TODO Auto-generated method stub
            return 0;
        }
        
        /*
         * (non-Javadoc)
         * 
         * @see rbtree.RBTree.IRBTree#toArrayList()
         */
        @Override
        public ArrayList<String> toArrayList() {
            // TODO Auto-generated method stub
            return null;
        }
        
    }
}
