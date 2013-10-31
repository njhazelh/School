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
     * Factory: Create an empty RBTree.
     * @param comp The Comparator<String> to use to organize Strings.
     * @return an empty RBTree.
     */
    public static RBTree binTree(Comparator<String> comp) {
        return new RBTree(comp);
    }
    
    
    /**
     * Create an empty RBTree with this
     * 
     * @param comp
     */
    private RBTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = RBTree.Leaf.LEAF;
    }
    
    
    
    
    
    
    
    
    
    
    
    // IMPLEMENTATION TYPES!!!
    
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
        
        public RBTree.Color getColor();
        
        /**
         * Get an int such that the hashCode/equals relationship holds true.
         * 
         * @return an int such that if two objects are equal, they have the same
         *         hashCode.
         */
        @Override
        public int hashCode();
        
        public boolean isLeaf();
        
        public void setColor(RBTree.Color c);
        
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
     * This is more efficient, since most cases off IRBTree addition are to
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
        public RBTree.Color getColor() {
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
         * This is a Leaf.
         * 
         * @return true;
         */
        @Override
        public boolean isLeaf() {
            return true;
        }
        
        /**
         * Cannot set the color of a Leaf. Leaves are always BLACK.
         * 
         * @throws UnsupportedOperationException
         */
        @Override
        public void setColor(Color c) throws UnsupportedOperationException {
            throw new UnsupportedOperationException("Leaves must be BLACK");
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
        private IRBTree      left;
        private IRBTree      right;
        private String       val;
        private RBTree.Color color;
        
        /**
         * Create a new Node with the given values.
         * 
         * @param left The left side of this tree. Strings < this.value
         * @param value The String at this Node.
         * @param right The right side of this tree. Strings > this.value.
         */
        public Node(IRBTree left, String val, IRBTree right) {
            this.left = left;
            this.val = val;
            this.right = right;
        }
        
        /**
         * Add the String s to this Node if it is not already present
         * (comparator returns 0 from some String already in this Node).
         * 
         * @param s The String to add.
         */
        @Override
        public void add(String s) {
            // TODO Auto-generated method stub
            // COMPLICATED!
        }
        
        /**
         * Does this Node contain the String s?
         * 
         * @param s The String to look for.
         * @return true if contained in this Node, else false
         */
        @Override
        public boolean contains(String s) {
            return this.val.equals(s)
                    || (RBTree.this.comp.compare(s, this.val) < 0 && this.left
                            .contains(s))
                    || (RBTree.this.comp.compare(s, this.val) > 0 && this.right
                            .contains(s));
        }
        
        /**
         * What color is this Node?
         * 
         * @return The Color of this Node.
         */
        @Override
        public Color getColor() {
            return this.color;
        }
        
        /**
         * This Node is not a Leaf.
         * 
         * @return false;
         */
        @Override
        public boolean isLeaf() {
            return false;
        }
        
        /**
         * Set the color of this Node to the new Node.
         * 
         * @param color The new Color.
         */
        @Override
        public void setColor(Color color) {
            this.color = color;
        }
        
        /**
         * How many Strings are contained in this Node?
         * 
         * @return a positive number equal to the number of Strings in this
         *         Node.
         */
        @Override
        public int size() {
            return 1 + this.left.size() + this.right.size();
        }
        
        /**
         * Get an ordered ArrayList of the Strings in this Node.
         * 
         * @return Get an ArrayList with all the Strings of this Node in order.
         */
        @Override
        public ArrayList<String> toArrayList() {
            ArrayList<String> temp = this.left.toArrayList();
            temp.add(this.val);
            temp.addAll(this.right.toArrayList());
            
            return temp;
        }
        
    }
}
