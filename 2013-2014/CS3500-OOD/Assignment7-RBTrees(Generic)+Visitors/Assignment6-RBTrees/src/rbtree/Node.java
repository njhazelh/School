/**
 * 
 */
package rbtree;

import java.util.ArrayList;

/**
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
class Node extends RBTree {
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