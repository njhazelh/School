/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
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
public class RBTree<T> implements Iterable<T> {
    private IRBTree<T>    tree;
    private Comparator<T> comp;

    /**
     * Factory: Create an empty RBTree that uses the given Comparator to
     * organize Ts.
     * 
     * @param comp The Comparator<R> to use to organize Rs.
     * @return an empty RBTree.
     */
    public static <R> RBTree<R> binTree(Comparator<R> comp) {
        return new RBTree<R>(comp);
    }

    /**
     * This is the private RBTree Constructor. A factory interface is provided
     * from creating instances of RBTree.
     * 
     * @param comp The comparator this tree will use to organize Ts.
     */
    private RBTree(Comparator<T> comp) {
        this.comp = comp;
        this.tree = new Leaf<T>();
    }

    /**
     * Try to add a T to the RBTree.
     * 
     * @param s T to add
     */
    public void add(T s) {
        try { // ASSUME ADDING TO NODE
            this.tree.add(s);
            this.tree = ((Node<T>) this.tree).getRoot();
        }
        catch (UnsupportedOperationException e) { // SWAP NODE WITH LEAF
            this.tree = new Node<T>(Color.BLACK, this.comp, this.tree, s,
                    this.tree);
        }
    }

    /**
     * Does this RBTree contain s?
     * 
     * @param s The T to look for?
     * @return true if present.
     */
    public boolean contains(T s) {
        return this.tree.contains(s);
    }

    /**
     * Is that a RBTree with the same Ts and Comparator as that?
     * 
     * @param that The Object to compare this to.
     * @return true if equal.
     */
    @Override
    public boolean equals(Object that) {
        return (that instanceof RBTree<?>)
                && ((RBTree<?>) that).tree.equals(this.tree);
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
    public Iterator<T> iterator() {
        return this.tree.iterator();
    }

    /**
     * repOk
     * 
     * @return Is the representation for this RBTree valid?
     */
    public boolean repOK() {
        return (this.tree.getColor() == Color.BLACK)
                && (this.tree.size() == this.size())
                && this.tree.toString().equals(this.toString())
                && this.tree.repOK();
    }

    /**
     * How many Ts are in this RBTree
     * 
     * @return # of Ts in RBTree
     */
    public int size() {
        return this.tree.size();
    }

    /**
     * Make an array of all this Ts of this RBTree in order
     * 
     * @return an ordered ArrayList<T>
     */
    public ArrayList<T> toArrayList() {
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

    /**
     * Apply the given visitor to this tree.
     * 
     * @param visitor visitor to use.
     * @return the result of the visitor operations.
     */
    public <R> R accept(RBTreeVisitor<T, R> visitor) {
        return this.tree.accept(visitor);
    }
}
