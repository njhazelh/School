/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

package rbtree;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;

/**
 * RBTree is a mutable representation of Red Black Trees, a form of binary
 * search trees with good worst case efficiency.
 * 
 * @author Nicholas Jones
 * @version Oct 30, 2013
 */
public class RBTree implements Iterable<String> {
    private IRBTree            tree;
    private Comparator<String> comp;
    
    /**
     * Factory: Create an empty RBTree that uses the given Comparator to
     * organize Strings.
     * 
     * @param comp The Comparator<String> to use to organize Strings.
     * @return an empty RBTree.
     */
    public static RBTree binTree(Comparator<String> comp) {
        return new RBTree(comp);
    }
    
    /**
     * This is the private RBTree Constructor. A factory interface is provided
     * from creating instances of RBTree.
     * 
     * @param comp The comparator this tree will use to organize Strings.
     */
    private RBTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = Leaf.INSTANCE;
    }
    
    /**
     * Try to add a String to the RBTree.
     * 
     * @param s String to add
     */
    public void add(String s) {
        try { // ASSUME ADDING TO NODE
            this.tree.add(s);
            this.tree = ((Node) this.tree).getRoot();
        }
        catch (UnsupportedOperationException e) { // SWAP NODE WITH LEAF
            this.tree =
                    new Node(Color.BLACK, this.comp, this.tree, s, this.tree);
        }
    }
    
    /**
     * Does this RBTree contain s?
     * 
     * @param s The String to look for?
     * @return true if present.
     */
    public boolean contains(String s) {
        return this.tree.contains(s);
    }
    
    /**
     * Is that a RBTree with the same Strings and Comparator as that?
     * 
     * @param that The Object to compare this to.
     * @return true if equal.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof RBTree && ((RBTree) that).tree.equals(this.tree);
    }
    
    /**
     * Get an int such that the hashCode/equals relationship holds true.
     * 
     * @return an int such that if two objects are equal, they have the same
     *         hashCode.
     */
    @Override
    public int hashCode() {
        return this.tree.hashCode();
    }
    
    /**
     * Get an iterator that iterates from the lowest values to the highest
     * values (according to the comparator.)
     * 
     * @return An iterator for this RBTree
     */
    @Override
    public Iterator<String> iterator() {
        return this.tree.iterator();
    }
    
    /**
     * repOk
     * 
     * @return Is the representation for this RBTree valid?
     */
    public boolean repOK() {
        return this.tree.getColor() == Color.BLACK;
    }
    
    /**
     * How many Strings are in this RBTree
     * 
     * @return # of Strings in RBTree
     */
    public int size() {
        return this.tree.size();
    }
    
    /**
     * Make an array of all this Strings of this RBTree in order
     * 
     * @return an ordered ArrayList<String>
     */
    public ArrayList<String> toArrayList() {
        return this.tree.toArrayList();
    }
    
    /**
     * Get a string representing this RBTree
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString() {
        return this.tree.toString();
    }
}
