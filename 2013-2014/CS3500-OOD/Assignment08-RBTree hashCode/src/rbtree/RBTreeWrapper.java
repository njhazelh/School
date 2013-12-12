/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

package rbtree;

import java.util.Comparator;
import java.util.Iterator;

/**
 * RBTreeWrapper is a mutable representation of Red Black Trees, a form of
 * binary search trees with good worst case efficiency.
 * 
 * @author Nicholas Jones
 * @version Oct 30, 2013
 * @param <T> The type of data contained.
 */
public class RBTreeWrapper<T> implements Iterable<T> {
    private RBTree<T>     tree;
    private Comparator<T> comp;

    /**
     * Factory: Create an empty RBTreeWrapper that uses the given Comparator to
     * organize Ts.
     * 
     * @param comp The Comparator<R> to use to organize Rs.
     * @param <R> The type of data in this RBTreeWrapper.
     * @return an empty RBTreeWrapper.
     */
    public static <R> RBTreeWrapper<R> binTree(Comparator<R> comp) {
        return new RBTreeWrapper<R>(comp);
    }

    /**
     * This is the private RBTreeWrapper Constructor. A factory interface is
     * provided from creating instances of RBTreeWrapper.
     * 
     * @param comp The comparator this tree will use to organize Ts.
     */
    private RBTreeWrapper(Comparator<T> comp) {
        this.comp = comp;
        this.tree = new Leaf<T>(comp);
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
            this.tree = new Node<T>(Color.BLACK, this.comp, null, this.tree, s,
                    this.tree);
        }
    }

    /**
     * Does this RBTreeWrapper contain s?
     * 
     * @param s The T to look for?
     * @return true if present.
     */
    public boolean contains(T s) {
        return this.tree.contains(s);
    }

    /**
     * Is that a RBTreeWrapper with the same Ts and Comparator as that?
     * 
     * @param that The Object to compare this to.
     * @return true if equal.
     */
    @Override
    public boolean equals(Object that) {
        return (that instanceof RBTreeWrapper<?>)
                && ((RBTreeWrapper<?>) that).tree.equals(this.tree);
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
     * @return An iterator for this RBTreeWrapper
     */
    @Override
    public Iterator<T> iterator() {
        return this.tree.iterator();
    }

    /**
     * Is the representation for this RBTreeWrapper valid?
     * 
     * @return true if valid, else false.
     */
    public boolean repOK() {
        return (this.tree.getColor() == Color.BLACK)
                && (this.tree.size() == this.size())
                && this.tree.toString().equals(this.toString())
                && this.tree.repOK();
    }

    /**
     * How many Ts are in this RBTreeWrapper
     * 
     * @return # of Ts in RBTreeWrapper
     */
    public int size() {
        return this.tree.size();
    }

    /**
     * Get a string representing this RBTreeWrapper
     * 
     * @return "s1, s2, s3, ..."
     */
    @Override
    public String toString() {
        return this.tree.toString();
    }

    // /**
    // * Generate a String that represents the structure and content of this
    // * BTree.
    // * @return A Structured String.
    // */
    // public String toStructString() {
    // return this.tree.toStructString("");
    // }

    /**
     * Apply the given visitor to this tree.
     * 
     * @param visitor visitor to use.
     * @param <R> The return type of the visitor.
     * @return the result of the visitor operations.
     */
    public <R> R accept(RBTreeVisitor<T, R> visitor) {
        return this.tree.accept(visitor);
    }
}
