/*
 * Author: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.*;

/**
 * BTree is a mutable data type whose values represent
 * String data items, organized as a binary search tree, with the 
 * ordering specified by the provided Comparator<String>. The BTree
 * class implements the Iterable<String> interface by providing an
 * Iterator<String> that generates the individual elements of the 
 * BTree in the order specified by the provided Comparator<String>.
 * 
 * A typical BTree is a {x1, x2, x3, x4...}
 * The abstraction function is:
 * AF(c) = {x.get[i].StringValue | left[i] < value && right[i] > value } ?????
 * 
 * The Rep Invariant is:
 * for all integers 0 < i < c.size, c.els[i] is a String &&
 * for all integers 0 < i < c.value.index, c.comp.compare(c.els[i],c.value) < 0
 * for all integers c.value.index < i < c.size,
 *        c.comp.compare(c.else[i],c.value) > 0
 * BTree.binTree(comparator) != null &&
 * BTree.size == 0 &&
 * BTree.binTree(comp).iterator.remove -> UnsupportedOperationException
 * BTree.binTree(comp).iterator.next   -> NoSuchElementException
 * BTree.binTree(comp).build(iter).iterator.next -> String, given iter.size > 0
 * c.build(iter) -> ConcurrentModificationException, given at least 1 iterators
 * over c are running.
 * c.iterator.next != iterator.next
 * ???
 * 
 *        
 * @author Nick Jones
 * @version 2.0 - 10/16/2013
 */
public class BTree implements Iterable<String> {
    private IBTree tree;
    private int active;
    private Comparator<String> comp;
    
    /**
     * Factory method to generate
     * an empty binary search tree
     * with the given <code>Comparator</code>
     *
     * @param comp the given <code>Comparator</code>
     * @return new empty binary search tree that uses the
     *         given <code>Comparator</code> for ordering
     */
    public static BTree binTree(Comparator<String> comp) {
        return new BTree(comp);
    }
    
    /**
     * CONSTRUCTOR
     * @param comp Comparator to use throughout the BTree.
     */
    public BTree(Comparator<String> comp) {
        this.tree = new Leaf();
        this.comp = comp;
        this.active = 0;
    }
    
    
    /**
     * Modifies: 
     * this binary search tree by inserting the 
     * first numStrings <code>String</code>s from 
     * the given <code>Iterable</code> collection
     * The tree will not have any duplicates 
     * - if an item to be added equals an item
     * that is already in the tree, it will not be added.
     *
     * @param in the given <code>Iterable</code> collection
     * @param numStrings number of <code>String</code>s
     *        to iterate through and add to BTree
     *        if numStrings is negative or larger than the number of 
     *        <code>String</code>s in iter then all <code>String</code>s 
     *        in iter should be inserted into the tree 
     */
    public void build(Iterable<String> in, Integer numStrings) {
        if (numStrings < 0) {
            this.build(in);
        }
        else if (this.active == 0) {
            Iterator<String> iter = in.iterator();
            
            if (iter.hasNext() && this.tree.isLeaf()) {
                this.tree = new Node(iter.next(), this.tree, this.tree);
            }
            
            for (int i = 1; i < numStrings && iter.hasNext(); i++) {
                tree.add(iter.next());
            }
        }
        else {
            throw new ConcurrentModificationException(this.active + 
                    " iterators running");
        }
    }
    
    
    /**
     * Modifies: 
     * this binary search tree by inserting the 
     * <code>String</code>s from the given 
     * <code>Iterable</code> collection
     * The tree will not have any duplicates 
     * - if an item to be added equals an item
     * that is already in the tree, it will not be added.
     *
     * @param in the given <code>Iterable</code> collection
     */
    public void build(Iterable<String> in) {
        if (this.active == 0) {
            Iterator<String> iter = in.iterator();
            
            if (iter.hasNext() && this.tree.isLeaf()) {
                this.tree = new Node(iter.next(), this.tree, this.tree);
            }
            
            while (iter.hasNext()) {
                tree.add(iter.next());
            }
        }
        else {
            throw new ConcurrentModificationException(active + 
                    " iterators running");
        }
    }
    
    /**
     * How many Strings are in this BTree?
     * @return The number of Strings in the left, right, and middle?
     */
    public int size() {
        return this.tree.size();
    }
    
    /**
     * Get an iterator for this BTree.
     * While iterator active, cannot modify this BTree.
     * @return An iterator for this BTree that returns all
     * Strings in BTree in order defined by Comparator.
     */
    public Iterator<String> iterator() {
        return new BTreeIter(this.tree);
    }
    
    
    /**
     * Does this BTree contain s?
     * @param s String to check for.
     * @return true if this tree contains the String s.
     */
    public boolean contains(String s) {
        return this.tree.contains(s);
    }
    
    /**
     * Effect: 
     * Produces a <code>String</code> that consists of 
     * all <code>String</code>s in this tree 
     * separated by comma and a space, 
     * generated in the order defined by this tree's 
     * <code>Comparator</code>.
     * So for a tree with <code>Strings</code> 
     * "hello" "bye" and "aloha" 
     * ordered lexicographically, 
     * the result would be "aloha, bye, hello"
     * @return A String representing this BTree.
     */
    @Override
    public String toString() {
        return this.tree.toString();
    }
    
    
    /**
     * Effect: 
     * Produces false if o is not an instance of BTree.
     * Produces true if this tree and the given BTree 
     * contain the same <code>String</code>s and
     * are ordered by the same <code>Comparator</code>.
     * So if the first tree was built with Strings 
     * "hello" "bye" and "aloha" ordered
     * lexicographically,  and the second tree was built 
     * with <code>String</code>s "aloha" "hello" and "bye"  
     * and ordered lexicographically, 
     * the result would be true.
     *
     * @param that the object to compare with this
     * @return true if that equals this, else false.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof BTree &&
               ((BTree)that).comp.equals(this.comp) &&
               this.tree.equals(((BTree)that).tree);
    }
    
    /**
     * If two Objects are equal, they must have the same hashCode
     * @return The non-unique int representing this BTree.
     */
    @Override
    public int hashCode() {
        return this.tree.hashCode();
    }

    
    
    // Implementation Classes
    
    /**
     * IBTree is an interface for an immutable Binary Tree of Strings
     * that order Strings according to Comparator given.
     * @author Nick Jones
     * @version 1.0 - 10/16/2013
     */
    private interface IBTree {
        /**
         * How many Strings are in this IBTree
         * @return # of Strings in IBTree
         */
        public int size();
        
        /**
         * Try to add a String to the BTree.
         * @param s String to add
         */
        public void add(String s);
        
        /**
         * Is that a IBTree with the same Strings
         * and Comparator as that?
         * @param that The Object to compare this to.
         * @return true if equal.
         */
        public boolean equals(Object that);
        
        /**
         * Get a string representing this IBTree
         * @return s1, s2, s3, ...
         */
        public String toString();
        
        /**
         * Get an int such that the hashCode/equals relationship
         * holds true.
         * @return an int such that if two objects are equal, they have the
         * same hashCode.
         */
        public int hashCode();
        
        /**
         * Does this IBTree contain s?
         * @param s The String to look for?
         * @return true if present.
         */
        public boolean contains(String s);
        
        /**
         * Make an array of all this Strings of this IBTree in order
         * @return an ordered ArrayList<String>
         */
        public ArrayList<String> toArrayList();
        
        /**
         * Is this IBTree a Leaf?
         */
        public boolean isLeaf();
    }
    
    
    /**
     * Leaf is a Terminating Node for an IBTree.
     * @author Nick Jones
     * @version 2.0 - 10/18/2013
     */
    private class Leaf implements IBTree {
        
        /**
         * How many Strings are in this Leaf?
         * @return 0
         */
        public int size() {
            return 0;
        }
        
        /**
         * Cannot add to a Leaf. Instead swap with Node on higher level.
         * @throws UnsupportedOperationException
         */
        public void add(String s) {
            throw new UnsupportedOperationException("Cannot Add to a Leaf");
        }
        
        /**
         * Make an ArrayList with all the Strings in this IBTree in order
         * @return an empty ArrayList<String>
         */
        public ArrayList<String> toArrayList() {
            return new ArrayList<String>();
        }
        
        /**
         * Is that an instance of Leaf?
         * @return true if instance of Leaf.
         */
        public boolean equals(Object that) {
            return that instanceof Leaf;
        }
       
        /**
         * Fulfill that hashCode/equals agreement.
         * @return An int such that if this IBTree equals another then their 
         * hashCodes are equal.
         */
        public int hashCode() {
            return 0;
        }
        
        /**
         * Get a String representing the Strings in this IBTree.
         * @return an empty String.
         */
        public String toString() {
            return "";
        }
        
        /**
         * Does this Leaf contain a String?
         * @return false
         */
        public boolean contains(String s) {
            return false;
        }
        
        /**
         * This is a Leaf
         * @return true
         */
        public boolean isLeaf() {
            return true;
        }
    }
    

    /**
     * Node is a Mutable Binary Tree where all values on the left subtree
     * are less than the value, and all values on the right subtree are 
     * greater.  Nodes Terminate in Leafs.
     * @author Nick Jones
     * @version 2.0 - 10/16/2013
     */
    private class Node implements IBTree {
        private String val;
        private IBTree left;
        private IBTree right;
        
        /**
         * CONSTRUCTOR
         * @param val The String for this Node
         * @param left The left subtree
         * @param right The right subtree
         */
        public Node(String val, IBTree left, IBTree right) {
            this.val = val;
            this.left = left;
            this.right = right;
        }
        
        /**
         * How many Strings are in this Node?
         * @return The number of Strings stored in this Node.
         */
        public int size() {
            return 1 + this.left.size() + this.right.size();
        }
        
        /**
         * If s does not already exist in this BTree according to the
         * Comparator (compare = 0), add to this by either swapping
         * Leaf with Node or adding to a Node.
         */
        public void add(String s) {
            if (BTree.this.comp.compare(s, this.val) < 0) {
                if (this.left.isLeaf()) {
                    this.left = new Node(s, this.left, this.left);
                }
                else {
                    this.left.add(s);
                }
            }
            else if (BTree.this.comp.compare(s, this.val) > 0) {
                if (this.right.isLeaf()) {
                    this.right = new Node(s, this.right, this.right);
                }
                else {
                    this.right.add(s);
                }
            }
        }
        
        /**
         * Make an ArrayList with all the elements of this in order.
         * @return An ArrayList with all the elements in order.
         */
        public ArrayList<String> toArrayList() {
            ArrayList<String> ar = new ArrayList<String>();
            
            ar.addAll(this.left.toArrayList());
            ar.add(this.val);
            ar.addAll(this.right.toArrayList());
            
            return ar;
        }
        
        /**
         * Is that an instance of Node with the same Strings and the same
         * comparator?
         * @return true if that is an instance of Node with the same Strings and
         * the same Comparator.
         */
        public boolean equals(Object that) {
            if (that instanceof Node) {
                for (String s : ((Node)that).toArrayList()) {
                    if (!this.contains(s)) {
                        return false;
                    }
                }
                
                for (String s : this.toArrayList()) {
                    if (!((Node)that).contains(s)) {
                        return false;
                    }
                }
                return true;
            }
            else {
                return false;
            }
        }
       
        /**
         * Fulfill that hashCode/equals agreement.
         * @return An int such that if this IBTree equals another then their 
         * hashCodes are equal.
         */
        public int hashCode() {
            return this.size();
        }
        
        /**
         * Get a String representation of the ordered Strings in this Node.
         * @return An String of the Strings in this Node (ordered and separated
         * by commas.)
         */
        public String toString() {
            String ret = "";
            
            for (String s : this.toArrayList()) {
                ret += s + ", ";
            }
            
            return ret.substring(0, Math.max(0, ret.length() - 2));
        }
        
        /**
         * Does this Node contain the String, s?
         * @return true if val.equals(s) or contained in left or right.
         */
        public boolean contains(String s) {
            return this.val.equals(s) ||
                   (BTree.this.comp.compare(s, this.val) < 0 &&
                   this.left.contains(s)) ||
                   (BTree.this.comp.compare(s, this.val) > 0 &&
                   this.right.contains(s));
        }
        
        /**
         * This is not a Leaf.
         * @return false
         */
        public boolean isLeaf() {
            return false;
        }
    }
    
    
    /**
     * BTreeIter is an Iterator that moves through the BTree in the order that
     * the Strings were placed by the Comparator of the BTree they point to.
     * @author Nick Jones
     * @version 2.0 - 10/17/2013
     */
    private class BTreeIter implements Iterator<String> {
        private Iterator<String> iter;
        private boolean isDone;
        
        /**
         * CONSTRUCTOR
         * @param bt The BTree to iterate through.
         */
        public BTreeIter(IBTree bt) {
            this.iter = bt.toArrayList().iterator();
            if (this.iter.hasNext()) {
                BTree.this.active++;
                isDone = false;
            }
            else {
                isDone = true;
            }   
        }
        
        /**
         * Does this Iterator have another String?
         * @return true if there is another String, else false.
         */
        public boolean hasNext() {
            return this.iter.hasNext();
        }
        
        /**
         * Get the next String in the iteration.
         * @return The next String in the iteration.
         */
        public String next() {
            if (this.iter.hasNext()) {
                String ret = this.iter.next();
                if (!this.hasNext()) {
                    this.finish();
                }
                return ret;
            }
            else {
                throw new NoSuchElementException("next: " +
                                       BTree.this.tree.toString());
            }
        }
        
        /**
         * Free up the BTree this Iterator points to, so that new Strings can
         * be added to it.
         */
        public void finish() {
            if (!this.isDone) {
                this.isDone = true;
                BTree.this.active--;
            }
        }
        
        /**
         * Unsupported.
         */
        public void remove() {
            throw new UnsupportedOperationException("remove");
        }
        
        /**
         * Make sure that this Iterator is cleaned up before it is trashed, so
         * that the BTree can add more Strings.
         */
        protected void finalize() throws Throwable {
            this.finish();
            super.finalize();
        }
    }
}
