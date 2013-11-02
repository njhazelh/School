/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

import java.util.Comparator;
import java.util.Iterator;

import rbtree.RBTree;

/**
 * BTree is an implementation of BinaryTrees of Strings using Red/Black trees,
 * which balance the tree to maintain good worst case efficiency.
 * 
 * INVARIANTS: - No red node has a Red Parent. - Every path from the root to an
 * empty node contains the same number of black nodes.
 * 
 * @author Nick Jones
 * @version 10/26/2013
 * 
 */
public class BTree implements Iterable<String> {
    private Comparator<String> comp;
    private RBTree             tree;
    
    /**
     * This is a static factory method that produces in empty instance of a
     * BTree
     * 
     * @param comp The comparator to use to organize Strings.
     * @return An empty BTree that uses that comparator comp to organize Strings
     *         into accending order.
     * 
     */
    public static BTree binTree(Comparator<String> comp) {
        return new BTree(comp);
    }
    
    /**
     * This is a private constructor for BTree that creates an instance of BTree
     * that uses the Comparator<String> comp to organize Strings.
     * 
     * @param comp The comparator to use.
     */
    private BTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = RBTree.binTree(comp);
    }
    
    /**
     * Modifies: this binary search tree by inserting the <code>String</code>s
     * from the given <code>Iterable</code> collection The tree will not have
     * any duplicates - if an item to be added equals an item that is already in
     * the tree, it will not be added.
     * 
     * @param in the given <code>Iterable</code> collection
     */
    public void build(Iterable<String> in) {
        Iterator<String> iter = in.iterator();
        
        while (iter.hasNext()) {
            this.tree.add(iter.next());
        }
    }
    
    /**
     * Modifies: this binary search tree by inserting the first numStrings
     * <code>String</code>s from the given <code>Iterable</code> collection The
     * tree will not have any duplicates - if an item to be added equals an item
     * that is already in the tree, it will not be added.
     * 
     * @param in the given <code>Iterable</code> collection
     * @param numStrings number of <code>String</code>s to iterate through and
     *            add to BTree if numStrings is negative or larger than the
     *            number of <code>String</code>s in iter then all
     *            <code>String</code>s in iter should be inserted into the tree
     */
    public void build(Iterable<String> in, Integer numStrings) {
        if (numStrings < 0) {
            this.build(in);
        }
        else {
            Iterator<String> iter = in.iterator();
            
            for (int i = 1; i < numStrings && iter.hasNext(); i++) {
                this.tree.add(iter.next());
            }
        }
    }
    
    /**
     * Does this BTree contain s?
     * 
     * @param s String to check for.
     * @return true if this tree contains the String s.
     */
    public boolean contains(String s) {
        return this.tree.contains(s);
    }
    
    /**
     * Effect: Produces false if o is not an instance of BTree. Produces true if
     * this tree and the given BTree contain the same <code>String</code>s and
     * are ordered by the same <code>Comparator</code>. So if the first tree was
     * built with Strings "hello" "bye" and "aloha" ordered lexicographically,
     * and the second tree was built with <code>String</code>s "aloha" "hello"
     * and "bye" and ordered lexicographically, the result would be true.
     * 
     * @param that the object to compare with this
     * @return true if that equals this, else false.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof BTree && ((BTree) that).comp.equals(this.comp)
                && this.tree.equals(((BTree) that).tree);
    }
    
    /**
     * If two Objects are equal, they must have the same hashCode
     * 
     * @return The non-unique int representing this BTree.
     */
    @Override
    public int hashCode() {
        return this.tree.hashCode();
    }
    
    /**
     * Get an iterator for this BTree. While iterator active, cannot modify this
     * BTree.
     * 
     * @return An iterator for this BTree that returns all Strings in BTree in
     *         order defined by Comparator.
     */
    @Override
    public Iterator<String> iterator() {
        return this.tree.iterator();
    }
    
    /**
     * repOk
     * 
     * @return Is the representation of this BTree valid?
     */
    public boolean repOk() {
        for (String s : this) {
            this.contains(s);
        }
        return true;
    }
    
    /**
     * How many Strings are in this BTree?
     * 
     * @return The number of Strings in the left, right, and middle?
     */
    public int size() {
        return this.tree.size();
    }
    
    /**
     * Effect: Produces a <code>String</code> that consists of all
     * <code>String</code>s in this tree separated by comma and a space,
     * generated in the order defined by this tree's <code>Comparator</code>. So
     * for a tree with <code>Strings</code> "hello" "bye" and "aloha" ordered
     * lexicographically, the result would be "aloha, bye, hello"
     * 
     * @return A String representing this BTree.
     */
    @Override
    public String toString() {
        return this.tree.toString();
    }
}
