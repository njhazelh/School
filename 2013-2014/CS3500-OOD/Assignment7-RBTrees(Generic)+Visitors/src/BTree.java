/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.Comparator;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
import java.util.NoSuchElementException;

import rbtree.RBTreeVisitor;
import rbtree.RBTreeWrapper;

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
 * @param <T> The type of data stored in the BTree.
 */
public class BTree<T> implements Iterable<T> {
    private Comparator<T> comp;
    private RBTreeWrapper<T>     tree;
    private int           active = 0;

    /**
     * This is a static factory method that produces in empty instance of a
     * BTree
     * 
     * @param comp The comparator to use to organize Strings.
     * @return An empty BTree that uses that comparator comp to organize Strings
     *         into accending order.
     * 
     */
    public static <R> BTree<R> binTree(Comparator<R> comp) {
        return new BTree<R>(comp);
    }

    /**
     * This is a private constructor for BTree that creates an instance of BTree
     * that uses the Comparator<String> comp to organize Strings.
     * 
     * @param comp The comparator to use.
     */
    private BTree(Comparator<T> comp) {
        this.comp = comp;
        this.tree = RBTreeWrapper.binTree(comp);
    }

    /**
     * Modifies: this binary search tree by inserting the <code>String</code>s
     * from the given <code>Iterable</code> collection The tree will not have
     * any duplicates - if an item to be added equals an item that is already in
     * the tree, it will not be added.
     * 
     * @param in the given <code>Iterable</code> collection
     */
    public void build(Iterable<T> in) {
        if (this.active == 0) {
            for (T t : in) {
                this.tree.add(t);
            }
        }
        else {
            throw new ConcurrentModificationException(this.active
                    + " iterators running");
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
     *        add to BTree if numStrings is negative or larger than the number
     *        of <code>String</code>s in iter then all <code>String</code>s in
     *        iter should be inserted into the tree
     */
    public void build(Iterable<T> in, Integer numItems) {
        if (numItems < 0) {
            this.build(in);
        }
        else if (this.active == 0) {
            Iterator<T> iter = in.iterator();

            for (int i = 0; (i < numItems) && iter.hasNext(); i++) {
                this.tree.add(iter.next());
            }
        }
        else {
            throw new ConcurrentModificationException(this.active
                    + " iterators running");
        }
    }

    /**
     * Does this BTree contain s?
     * 
     * @param s String to check for.
     * @return true if this tree contains the String s.
     */
    public boolean contains(T t) {
        return this.tree.contains(t);
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
        return (that instanceof BTree<?>)
                && ((BTree<?>) that).comp.equals(this.comp)
                && this.tree.equals(((BTree<?>) that).tree);
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
    public Iterator<T> iterator() {
        return new BTreeIter();
    }

    /**
     * repOk
     * 
     * @return Is the representation of this BTree valid?
     */
    public boolean repOK() {
        for (T t : this) {
            if (!this.contains(t)) {
                return false;
            }
        }

        return this.tree.repOK();
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
     * Apply the given visitor to this tree.
     * 
     * @param visitor visitor to use.
     * @return the result of the visitor operations.
     */
    public <R> R accept(RBTreeVisitor<T, R> visitor) {
        return this.tree.accept(visitor);
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

    /**
     * BTreeIter is an Iterator that moves through the BTree in the order that
     * the Strings were placed by the Comparator of the BTree they point to.
     * 
     * @author Nick Jones
     * @version 2.0 - 10/17/2013
     */
    protected class BTreeIter implements Iterator<T> {
        private boolean     isDone;
        private Iterator<T> iter;

        /**
         * CONSTRUCTOR
         * 
         */
        public BTreeIter() {
            this.iter = BTree.this.tree.toArrayList().iterator();
            if (this.iter.hasNext()) {
                BTree.this.active++;
                this.isDone = false;
            }
            else {
                this.isDone = true;
            }
        }

        /**
         * Make sure that this Iterator is cleaned up before it is trashed, so
         * that the BTree can add more Strings.
         */
        @Override
        protected void finalize() throws Throwable {
            this.finish();
            super.finalize();
        }

        /**
         * Free up the BTree this Iterator points to, so that new Strings can be
         * added to it.
         */
        public void finish() {
            if (!this.isDone) {
                this.isDone = true;
                BTree.this.active--;
            }
        }

        /**
         * Does this Iterator have another String?
         * 
         * @return true if there is another String, else false.
         */
        @Override
        public boolean hasNext() {
            return this.iter.hasNext();
        }

        /**
         * Get the next String in the iteration.
         * 
         * @return The next String in the iteration.
         */
        @Override
        public T next() {
            if (this.iter.hasNext()) {
                T ret = this.iter.next();
                if (!this.hasNext()) {
                    this.finish();
                }
                return ret;
            }
            else {
                throw new NoSuchElementException("next: "
                        + BTree.this.tree.toString());
            }
        }

        /**
         * Unsupported.
         * 
         * @throws UnsupportedOperationException
         */
        @Override
        public void remove() {
            throw new UnsupportedOperationException("remove");
        }
    }
}
