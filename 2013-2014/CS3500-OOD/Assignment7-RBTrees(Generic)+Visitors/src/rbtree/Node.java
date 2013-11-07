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
 * @author Nicholas Jones
 * @version Oct 31, 2013
 */
class Node<T> implements RBTree<T> {
    private Comparator<T> comp;
    private RBTree<T>     left;
    private RBTree<T>     right;
    private T             val;
    private Color         color;
    private Node<T>       parent; // Null when highest Node<T> (root).

    /**
     * Create a new Node<T> with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param left The left side of this tree. Ts < this.value
     * @param val The T at this Node.
     * @param right The right side of this tree. Ts > this.value.
     */
    public Node(Color color, Comparator<T> comp, RBTree<T> left, T val,
            RBTree<T> right) {
        this.color = color;
        this.comp = comp;
        this.left = left;
        this.val = val;
        this.right = right;
    }

    /**
     * Create a new Node<T> with the given values.
     * 
     * @param color The color of this Node
     * @param comp The comparator of this Node.
     * @param parent The parent of this Node.
     * @param left The left side of this tree. Ts < this.value
     * @param val The T at this Node.
     * @param right The right side of this tree. Ts > this.value.
     */
    public Node(Color color, Comparator<T> comp, Node<T> parent,
            RBTree<T> left, T val, RBTree<T> right) {
        this.color = color;
        this.comp = comp;
        this.parent = parent;
        this.left = left;
        this.val = val;
        this.right = right;
    }

    /**
     * Add the T s to this Node<T> if it is not already present (comparator
     * returns 0 for some T already in this Node).
     * 
     * Note: getRoot() may need to be called on what was the root Node<T> of
     * this tree. balancing can shift the root, but the reference stays the
     * same.
     * 
     * Note: Must call getRoot after adding, because the reference to the root
     * of the tree may no longer point to the root.
     * 
     * @param t The T to add.
     */
    @Override
    public void add(T t) {
        int compResult = this.comp.compare(t, this.val);

        if (compResult < 0) { // ADD TO LEFT
            try { // ASSUME ADDING TO NODE
                this.left.add(t);
            }
            catch (UnsupportedOperationException e) { // ADD TO LEAF
                this.left = new Node<T>(Color.RED, this.comp, this, this.left,
                        t, this.left);
                ((Node<T>) this.left).balance();
            }
        }
        else if (compResult > 0) { // ADD TO RIGHT
            try { // ASSUME ADDING TO NODE
                this.right.add(t);
            }
            catch (UnsupportedOperationException e) { // ADD TO LEAF
                this.right = new Node<T>(Color.RED, this.comp, this,
                        this.right, t, this.right);
                ((Node<?>) this.right).balance();
            }
        }
    }

    /**
     * Assures that the rules of RBTrees are enforced, thus balancing the tree.
     * 
     * Rules: - No Red Node has a red Parent - All Paths from a Node to a Leaf
     * have the same number of Black Nodes.
     * 
     * INVARIANT: SUB TREES OF THIS ARE BALANCED AND COLORED CORRECTLY
     * THIS.COLOR = RED
     */
    protected void balance() {
        Node<T> node = this;

        if (!(this.parent instanceof Node)) { // IS THIS THE ROOT NODE?
            node.color = Color.BLACK;
        } // HAS PARENT

        else if (node.parent.getColor() == Color.BLACK) {
            return;
        } // HAS PARENT && THIS.PARENT.COLOR == RED => HAS GRANDPARENT

        else {
            RBTree<T> uncle = node.parent.getSibling();
            if (uncle.getColor() == Color.RED) {
                node.parent.setColor(Color.BLACK);
                uncle.setColor(Color.BLACK);
                node.parent.parent.setColor(Color.RED);
                node.parent.parent.balance();
            } // HAS PARENT && PARENT IS RED && HAS GRANDPARENT && NO RED UNCLE

            else {
                if (node.equals(node.parent.right)
                        && node.parent.equals(node.parent.parent.left)) {
                    node.rotateLeft();
                    node = (Node<T>) (node.left); // Node = old parent
                }

                else if (node.equals(node.parent.left)
                        && node.parent.equals(node.parent.parent.right)) {
                    node.rotateRight();
                    node = (Node<T>) (node.right); // Node = old parent
                }

                node.parent.setColor(Color.BLACK);
                node.parent.parent.setColor(Color.RED);

                if (node.equals(node.parent.left)) {
                    node.parent.rotateRight();
                }
                else {
                    node.parent.rotateLeft();
                }
            }
        }
    }

    /**
     * Does this Node contain the T s?
     * 
     * @param t The T to look for.
     * @return true if contained in this Node, else false
     */
    @Override
    public boolean contains(T t) {
        return this.val.equals(t)
                || ((this.comp.compare(t, this.val) < 0) && this.left
                        .contains(t))
                || ((this.comp.compare(t, this.val) > 0) && this.right
                        .contains(t));
    }

    /**
     * Is that an instance of Node with the same comparator and Ts?
     * 
     * @param that The Object to check against.
     * @return true if Node and same Ts, else false.
     */
    @Override
    public boolean equals(Object that) {
        return (that instanceof Node<?>)
                && ((Node<?>) that).comp.equals(this.comp)
                && ((Node<?>) that).toArrayList().equals(this.toArrayList());
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
     * Get the Root (highest Node) in this tree. Call after add to re-discover
     * root reference.
     * 
     * @return the root.
     */
    public Node<T> getRoot() {
        Node<T> p = this;

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
    protected RBTree<T> getSibling() {
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
     * @return An iterator for this RBTreeWrapper
     */
    @Override
    public Iterator<T> iterator() {
        return this.toArrayList().iterator();
    }

    /**
     * repOk
     * 
     * @return is this representation ok?
     */
    @Override
    public boolean repOK() {
        for (T s : this.left) {
            if (this.comp.compare(s, this.val) >= 0) {
                System.out.println(s);
                System.out.println(this);
                return false;
            }
        }

        for (T s : this.right) {
            if (this.comp.compare(s, this.val) <= 0) {
                System.out.println(this);
                System.out.println(s);
                return false;
            }
        }

        return this.left.repOK() && this.right.repOK();
    }

    /**
     * Mutates this and subnodes of this so that this is now on top.
     * [[parent.left, parent, this.left], this, this.right]
     */
    protected void rotateLeft() {
        Node<T> oldParent = (this.parent);
        RBTree<T> oldLeft = this.left;
        Node<T> oldGP = this.parent.parent;

        if ((oldGP instanceof Node<?>) && oldGP.left.equals(oldParent)) {
            oldGP.left = this;
        }
        else if (oldGP instanceof Node<?>) {
            oldGP.right = this;
        }

        this.left = oldParent;
        oldParent.right = oldLeft;
        oldParent.parent = this;
        this.parent = oldGP;

        if (oldLeft instanceof Node) {
            ((Node<T>) oldLeft).parent = oldParent;
        }
    }

    /**
     * Mutates this and subnodes of this so that this is now on top. [this.left,
     * this, [this.right, parent, parent.right]]
     */
    protected void rotateRight() {
        Node<T> oldParent = (this.parent);
        RBTree<T> oldRight = this.right;
        Node<T> oldGP = this.parent.parent;

        if ((oldGP instanceof Node) && oldGP.left.equals(oldParent)) {
            oldGP.left = this;
        }
        else if (oldGP instanceof Node) {
            oldGP.right = this;
        }

        this.right = oldParent;
        oldParent.left = oldRight;
        oldParent.parent = this;
        this.parent = oldGP;

        if (oldRight instanceof Node) {
            ((Node<T>) oldRight).parent = oldParent;
        }
    }

    /**
     * Set the color of this Node<T> to the new Node.
     * 
     * @param color The new Color.
     */
    @Override
    public void setColor(Color color) {
        this.color = color;
    }

    /**
     * How many Ts are contained in this Node?
     * 
     * @return a positive number equal to the number of Ts in this Node.
     */
    @Override
    public int size() {
        return 1 + this.left.size() + this.right.size();
    }

    /**
     * Get an ordered ArrayList of the Ts in this Node.
     * 
     * @return Get an ArrayList with all the Ts of this Node<T> in order.
     */
    @Override
    public ArrayList<T> toArrayList() {
        ArrayList<T> temp = this.left.toArrayList();
        temp.add(this.val);
        temp.addAll(this.right.toArrayList());

        return temp;
    }

    /**
     * Convert this Node<T> into a String with the Strings contained listed in
     * order of appearance from left to right.
     * 
     * @return A String representing this Node<T> as Described.
     */
    @Override
    public String toString() {
        String ret = "";

        for (T s : this) {
            ret += s.toString() + ", ";
        }

        return ret.substring(0, ret.length() - 2);
    }

    /**
     * Convert this to a String that represents the structure of this Node.
     * 
     * @return a String (T RED|BLACK LEFT.structString RIGHT.structString)
     */
    @Override
    public String toStructString(String indent) {
        return this.right.toStructString(indent + "\t") + indent + this.color
                + " " + this.val + this.left.toStructString(indent + "\t");
    }

    /**
     * Apply the given visitor to this tree.
     * 
     * @param visitor visitor to use.
     * @return the result of the visitor operations.
     */
    @Override
    public <R> R accept(RBTreeVisitor<T, R> visitor) {
        return visitor.visitNode(this.comp, this.color.toString(), this.val,
                this.left, this.right);
    }
}
