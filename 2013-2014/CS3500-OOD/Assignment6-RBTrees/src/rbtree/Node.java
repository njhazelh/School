/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

package rbtree;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;

/**
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
class Node implements IRBTree {
    private Comparator<String> comp;
    private IRBTree            left;
    private IRBTree            right;
    private String             val;
    private Color              color;
    private Node               parent;
    
    /**
     * Create a new Node with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param left The left side of this tree. Strings < this.value
     * @param value The String at this Node.
     * @param right The right side of this tree. Strings > this.value.
     */
    public Node(Color color, Comparator<String> comp, IRBTree left, String val,
            IRBTree right) {
        this.color = color;
        this.comp = comp;
        this.left = left;
        this.val = val;
        this.right = right;
    }
    
    /**
     * Create a new Node with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param parent The parent of this Node.
     * @param left The left side of this tree. Strings < this.value
     * @param value The String at this Node.
     * @param right The right side of this tree. Strings > this.value.
     */
    public Node(Color color, Comparator<String> comp, Node parent,
            IRBTree left, String val, IRBTree right) {
        this.color = color;
        this.comp = comp;
        this.parent = parent;
        this.left = left;
        this.val = val;
        this.right = right;
    }
    
    /**
     * Add the String s to this Node if it is not already present (comparator
     * returns 0 for some String already in this Node).
     * 
     * @param s The String to add.
     */
    @Override
    public void add(String s) {
        if (this.comp.compare(s, this.val) < 0) { // ADD TO LEFT
            try { // ASSUME ADDING TO NODE
                this.left.add(s);
            }
            catch (UnsupportedOperationException e) { // ADD TO LEAF
                this.left =
                        new Node(Color.RED, this.comp, this.left, s, this.left);
            }
            
            this.balance();
        }
        else if (this.comp.compare(s, this.val) > 0) { // ADD TO RIGHT
            try { // ASSUME ADDING TO NODE
                this.right.add(s);
            }
            catch (UnsupportedOperationException e) { // ADD TO LEAF
                this.right =
                        new Node(Color.RED, this.comp, this.right, s,
                            this.right);
            }
            
            this.balance();
        }
    }
    
    /**
     * MUST HAVE LEFT CHILD NODE
     */
    protected void rotateRight() {
        Node gp = this.parent;
        Node oldParent = this;
        IRBTree oldRight = ((Node)(this.left)).right;
        
        this.left.right = oldParent;
        this.left = oldRight;
        
        if (gp instanceof Node) {
            
        }
        else { // ROOT NODE (NEED TO STEAL REFERENCE)
            
        }
    }
    
    /**
     * MUST HAVE RIGHT CHILD NODE
     */
    protected Node rotateLeft() {
        Node gp = this.parent;
        Node oldChild = (Node)(this.right);
        IRBTree oldLeft = oldChild.left;
        
        oldChild.left = this;
        this.right = oldLeft;
        
        if (gp instanceof Node) {
            gp.left = oldChild;
        }
        else { // ROOT NODE (NEED TO STEAL REFERENCE)
            this.
        }
    }
    
    /**
     * WHAT THE HELL DOES THIS DO????
     */
    protected void balance() {
        IRBTree uncle;
        
        if (this.parent == null) { // ROOT NODE
            this.color = Color.BLACK;
        } // HAS PARENT
        else if (this.parent.getColor() == Color.BLACK) { // BALANCED
            return;
        } // HAS PARENT and PARENT COLOR IS RED => HAS GRANDPARENT
        else if (this.getUncle().getColor() == Color.RED) {
            this.parent.setColor(Color.BLACK);
            uncle.setColor(Color.BLACK);
            this.parent.parent.setColor(Color.RED);
            this.parent.parent.balance();
        } // HAS PARENT and PARENT COLOR IS RED and DOES NOT HAVE RED UNCLE
        else if (this.equals(this.parent.right) &&
                this.parent.equals(this.parent.parent.left)) {
            this.parent.rotateLeft();
        } // " and NO GRANDPARENT or NOT RIGHT OF PARENT or PARENT NOT LEFT OF GRANDPARENT
        else if (this.parent.left.equals(this) &&
                this.parent.equals(this.parent.parent.right)) {
            this.parent.rotateRight();
        }
        else {
            this.parent.setColor(Color.BLACK);
            this.parent.parent.setColor(Color.RED);
            if (this.equals(this.parent.left)){
                this.parent.parent.rotateRight();
            }
            else {
                this.parent.parent.rotateLeft();
            }
        }
    }
    
    /**
     * Does this Node contain the String s?
     * 
     * @param s The String to look for.
     * @return true if contained in this Node, else false
     */
    @Override
    public boolean contains(String s) {
        return this.val.equals(s) ||
                (this.comp.compare(s, this.val) < 0 && this.left.contains(s)) ||
                (this.comp.compare(s, this.val) > 0 && this.right.contains(s));
    }
    
    /**
     * Is that an instance of Node with the same comparator and Strings?
     * 
     * @return true if Node and same Strings, else false.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof Node &&
                ((Node) that).comp.equals(this.comp) &&
                ((Node) that).toArrayList().equals(this.toArrayList());
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
     * This must have a grandparent for this to work.
     * 
     * @return
     */
    protected IRBTree getUncle() {
        Node gp = this.parent.parent; // GRANDPARENT

        if (this.parent.equals(gp.left)) {
            return gp.right;
        }
        else {
            return gp.left;
        }
    }
    
    /**
     * a.equals(b) => a.hashCode == b.hashCode()
     * 
     * @return An int such that the hashCode/equals agreement hold true.
     */
    @Override
    public int hashCode() {
        return this.size();
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
     * Get an iterator that iterates from the lowest values to the highest
     * values (according to the comparator.)
     * 
     * @return An iterator for this RBTree
     */
    @Override
    public Iterator<String> iterator() {
        return this.toArrayList().iterator();
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
     * @return a positive number equal to the number of Strings in this Node.
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
    
    /**
     * Convert this Node into a String with the Strings contained listed in
     * order of appearance from left to right.
     * 
     * @return A String representing this Node as Described.
     */
    @Override
    public String toString() {
        String ret = "";
        
        for (String s : this.toArrayList()) {
            ret += s + ", ";
        }
        
        return ret.substring(0, ret.length() - 2);
    }
    
}
