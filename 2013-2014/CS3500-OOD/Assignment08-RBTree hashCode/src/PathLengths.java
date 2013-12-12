/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;

import rbtree.RBTree;
import rbtree.RBTreeVisitor;

/**
 * PathLengths gets a list of the lengths of the paths to each Leaf under the
 * Node that accepts this.
 * 
 * @author Nick Jones
 * @version 11/6/2013
 * @param <T> The type of RBTree that this is working on. Ex: If working on
 *        RBTree<String>, T refers to String.
 */
public class PathLengths<T> implements RBTreeVisitor<T, ArrayList<Integer>> {

    /**
     * Start a new path.
     * 
     * @param comp The Comparator of the Leaf.
     * @param color The color of the Leaf.
     * @return an ArrayList containing 0.
     */
    @Override
    public ArrayList<Integer> visitEmpty(Comparator<T> comp, String color) {
        return new ArrayList<Integer>(Arrays.asList(0));
    }

    /**
     * Return a List of the lengths of the paths from the Node with the given
     * values to each Leaf under it.
     * 
     * @param comp The Comparator of the Node
     * @param color The Color of the Node
     * @param data The value at the Node
     * @param left The left subtree of the Node.
     * @param right The right subtree of the Node.
     * @return An ArrayList containing the lengths of the paths from the given
     *         Node to each Leaf under it.
     */
    @Override
    public ArrayList<Integer> visitNode(Comparator<T> comp, String color,
            T data, RBTree<T> left, RBTree<T> right) {
        ArrayList<Integer> leftPath = left.accept(this);
        ArrayList<Integer> rightPath = right.accept(this);
        ArrayList<Integer> ret = new ArrayList<Integer>();

        for (Integer i : leftPath) {
            ret.add(i + 1);
        }

        for (Integer i : rightPath) {
            ret.add(i + 1);
        }

        return ret;
    }
}
