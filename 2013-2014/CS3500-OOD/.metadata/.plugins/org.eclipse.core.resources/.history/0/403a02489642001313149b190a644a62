/**
 * 
 */
package rbtree;

import java.util.ArrayList;

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
class Leaf extends RBTree {
    
    /**
     * This is the only way to access LEAF.
     */
    public static final Leaf LEAF = new Leaf();
    
    /**
     * Force the constructor to be private. Only method of access is from
     * Leaf.LEAF, since Leaf is a singleton object.
     */
    public Leaf(Comparator<String> comp) {
        t
    }
    
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
    public Color getColor() {
        return Color.BLACK;
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
