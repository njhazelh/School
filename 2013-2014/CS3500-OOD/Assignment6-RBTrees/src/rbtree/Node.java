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
    private Node               parent; // Null when highest Node (root).
                                       
    /**
     * Create a new Node with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param left The left side of this tree. Strings < this.value
     * @param val The String at this Node.
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
     * s Create a new Node with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param parent The parent of this Node.
     * @param left The left side of this tree. Strings < this.value
     * @param val The String at this Node.
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
                        new Node(Color.RED, this.comp, this, this.left, s,
                            this.left);
                ((Node) this.left).balance();
            }
        }
        else if (this.comp.compare(s, this.val) > 0) { // ADD TO RIGHT
            try { // ASSUME ADDING TO NODE
                this.right.add(s);
            }
            catch (UnsupportedOperationException e) { // ADD TO LEAF
                this.right =
                        new Node(Color.RED, this.comp, this, this.right, s,
                            this.right);
                ((Node) this.right).balance();
            }
        }
    }
    
    /**
     * WHAT THE HELL DOES THIS DO????
     * 
     * INVARIANT: SUB TREES OF THIS ARE BALANCED AND COLORED CORRECTLY
     * THIS.COLOR = RED
     */
    protected void balance() {
        IRBTree uncle;
        Node node = this;
        
        if (this.parent instanceof Node) { // IS THIS THE ROOT NODE?
            node.color = Color.BLACK;
        } // HAS PARENT
        
        else if (node.parent.getColor() == Color.BLACK) {
            return;
        } // HAS PARENT && THIS.PARENT.COLOR == RED => HAS GRANDPARENT
        
        else {
            uncle = node.parent.getSibling();
            if (uncle.getColor() == Color.RED) {
                node.parent.setColor(Color.BLACK);
                uncle.setColor(Color.BLACK);
                node.parent.parent.setColor(Color.RED);
                node.parent.parent.balance();
            } // HAS PARENT && PARENT IS RED && HAS GRANDPARENT && NO RED UNCLE
            
            else {
                if (node.equals(node.parent.right) &&
                        node.parent.equals(node.parent.parent.left)) {
                    node.rotateLeft();
                    node = (Node) (node.left);
                }
                
                else if (node.equals(node.parent.left) &&
                        node.parent.equals(node.parent.parent.right)) {
                    node.rotateRight();
                    node = (Node) (node.right);
                }
                
                node.parent.setColor(Color.BLACK);
                node.parent.parent.setColor(Color.RED);
                
                if (node.equals(node.parent.left)) {
                    node.parent.parent.rotateRight();
                }
                else {
                    node.parent.parent.rotateLeft();
                }
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
     * @param that The Object to check against.
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
     * Get the Root (highest Node) in this tree.
     * 
     * @return the root.
     */
    public Node getRoot() {
        Node p = this;
        
        while (p.parent instanceof Node) {
            p = p.parent;
        }
        
        return p;
    }
    
    /**
     * This must have a parent for this to work.
     * 
     * @return The other child of this Node's parent.
     */
    protected IRBTree getSibling() {
        if (this.equals(this.parent.left)) {
            return this.parent.right;
        }
        else {
            return this.parent.left;
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
     * MUST HAVE RIGHT CHILD NODE Mutates this and subnodes of this so that this
     * is now the left subNode of this.right returns the new top node.
     */
    protected void rotateLeft() {
        Node oldParent = (Node) (this.parent.parent.left);
        IRBTree oldLeft = this.left;
        this.parent.parent.left = this;
        this.left = oldParent;
        oldParent.right = oldLeft;
    }
    
    /**
     * MUST HAVE LEFT CHILD NODE. Mutates this and subnodes of this so that this
     * is now the right subNode of this.left returns the new top node.
     */
    protected void rotateRight() {
        Node oldParent = (Node) (this.parent.parent.left);
        IRBTree oldRight = this.right;
        this.parent.parent.right = this;
        this.right = oldParent;
        oldParent.left = oldRight;
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
