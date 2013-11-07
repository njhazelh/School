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
 * Leaf is a singleton representation of a terminating node in a red black tree.
 * 
 * You cannot add to a Leaf. Instead attempt to add, and catch exception. This
 * is more efficient, since most cases off IRBTree addition are to Nodes not
 * Leaves.
 * 
 * @author Nicholas Jones
 * @version Oct 30, 2013
 */
class Leaf<T> implements RBTree<T> {
    Comparator<T> comp;
    private final Color color = Color.BLACK;

    /**
     * CONSTRUCTOR
     */
    public Leaf(Comparator<T> comp) {
        this.comp = comp;
    }

    /**
     * Cannot add to a Leaf. Instead swap with Node on higher level.
     * 
     * @param s The T to add.
     * @throws UnsupportedOperationException
     */
    @Override
    public void add(T s) throws UnsupportedOperationException {
        throw new UnsupportedOperationException("Cannot Add to a Leaf");
    }

    /**
     * Leaves do not contain Ts.
     * 
     * @param s The T to check for.
     * @return false
     */
    @Override
    public boolean contains(T s) {
        return false;
    }

    /**
     * Is that an instance of Leaf?
     * 
     * @param that The Object to compare against.
     * @return true if instance of Leaf.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof Leaf;
    }

    /**
     * All Leaves are BLACK.
     * 
     * @return Color.BLACK
     */
    @Override
    public Color getColor() {
        return this.color;
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
     * Get an iterator that has nothing to iterate through.
     * 
     * @return An iterator for this RBTreeWrapper
     */
    @Override
    public Iterator<T> iterator() {
        return this.toArrayList().iterator();
    }

    /**
     * repOk
     * 
     * @return is this rep ok?
     */
    @Override
    public boolean repOK() {
        return (this.getColor() == Color.BLACK) && this.toString().equals("")
                && (this.size() == 0);
    }

    /**
     * Cannot set the color of a Leaf. Leaves are always BLACK.
     * 
     * @param c the new color
     * @throws UnsupportedOperationException
     */
    @Override
    public void setColor(Color c) throws UnsupportedOperationException {
        throw new UnsupportedOperationException("Leaves must be BLACK");
    }

    /**
     * How many Ts are in this Leaf?
     * 
     * @return 0
     */
    @Override
    public int size() {
        return 0;
    }

    /**
     * Make an ArrayList with all the Ts in this IRBTree in order
     * 
     * @return an empty ArrayList<T>
     */
    @Override
    public ArrayList<T> toArrayList() {
        return new ArrayList<T>();
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

    /**
     * Generate a String that sorta describes the Structure
     * 
     * @return the String
     */
    @Override
    public String toStructString(String indent) {
        return "\n";
    }

    /**
     * Apply the given visitor to this Leaf.
     * 
     * @param visitor visitor to use.
     * @return the result of the visitor operations.
     */
    @Override
    public <R> R accept(RBTreeVisitor<T, R> visitor) {
        return visitor.visitEmpty(this.comp, this.getColor().toString());
    }
}
