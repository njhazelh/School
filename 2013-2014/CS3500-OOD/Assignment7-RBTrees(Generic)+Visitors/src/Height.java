/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.Comparator;

import rbtree.RBTree;
import rbtree.RBTreeVisitor;

/**
 * Height is a Visitor that finds the height of an RBTree.
 * 
 * The Height of an RBTree is the distance from its root to its furthest Leaf.
 * 
 * @author Nick
 * @version 11/6/2013
 * 
 * @param <T> The type of RBTree that this is working on. Ex: If working on
 *        RBTree<String>, T refers to String.
 */
public class Height<T> implements RBTreeVisitor<T, Integer> {

    /**
     * A Leaf has 0 height.
     * 
     * @param comp The Comparator of the Leaf.
     * @param color The color of the Leaf.
     * @return 0
     */
    @Override
    public Integer visitEmpty(Comparator<T> comp, String color) {
        return 0;
    }

    /**
     * Find the max path to a Leaf of the right and left.
     * 
     * @param comp The Comparator of the Node
     * @param color The Color of the Node
     * @param data The value at the Node
     * @param left The left subtree of the Node.
     * @param right The right subtree of the Node.
     * @return The max length path from the given Node to one of it's subLeaves.
     */
    @Override
    public Integer visitNode(Comparator<T> comp, String color, T data,
            RBTree<T> left, RBTree<T> right) {
        return Math.max(left.accept(this), right.accept(this));
    }
}
