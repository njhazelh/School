/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.Comparator;

import rbtree.RBTree;
import rbtree.RBTreeVisitor;

/**
 * BlackHeight finds the number of Black Nodes that are between the root and any
 * Leaf.
 * 
 * @author Nick Jones
 * @version 11/6/2013
 * 
 * @param <T> The type of RBTree that this is working on. Ex: If working on
 *        RBTree<String>, T refers to String.
 */
public class BlackHeight<T> implements RBTreeVisitor<T, Integer> {

    /**
     * Leaves start at 0.
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
     * Find the Number of Black Nodes between the accepting Node and it's
     * left-most Leaf.
     * 
     * @param comp The Comparator of the Node
     * @param color The Color of the Node
     * @param data The value at the Node
     * @param left The left subtree of the Node.
     * @param right The right subtree of the Node.
     * @return The Number of Black Nodes starting at the Node at accepted this
     *         and ending at the left-most leaf of that Node.
     */
    @Override
    public Integer visitNode(Comparator<T> comp, String color, T data,
            RBTree<T> left, RBTree<T> right) {
        Integer temp = left.accept(this);

        return color.equals("BLACK") ? temp + 1 : temp;
    }

}
