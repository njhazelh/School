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
 * CountNodes that returns an ArrayList with three elements
 * index 0: number of non-empty nodes
 * index 1: number of non-empty black nodes
 * index 2: number of non-empty red nodes.
 * 
 * @author Nick Jones
 * @version 11/6/2013
 * 
 * @param <T> The type of RBTree that this is working on. Ex: If working on
 *        RBTree<String>, T refers to String.
 */
public class CountNodes<T> implements RBTreeVisitor<T, ArrayList<Integer>> {

    /**
     * Start a the Path from Leaf to Root.
     * 
     * @param comp The Comparator of the Leaf.
     * @param color The color of the Leaf.
     * @return An ArrayList containing {0,0,0}
     */
    @Override
    public ArrayList<Integer> visitEmpty(Comparator<T> comp, String color) {
        return new ArrayList<Integer>(Arrays.asList(0, 0, 0));
    }

    /**
     * Combine the counts from the Left and Right subtrees.
     * 
     * @param comp The Comparator of the Node
     * @param color The Color of the Node
     * @param data The value at the Node
     * @param left The left subtree of the Node.
     * @param right The right subtree of the Node.
     * @return An ArrayList containing
     *         {# non-empty, # Black non-empty, # Red Non-empty}
     */
    @Override
    public ArrayList<Integer> visitNode(Comparator<T> comp, String color,
            T data, RBTree<T> left, RBTree<T> right) {
        ArrayList<Integer> leftAr = left.accept(this);
        ArrayList<Integer> rightAr = right.accept(this);
        Boolean isBlack = color.equals("BLACK");

        leftAr.set(0, leftAr.get(0) + rightAr.get(0) + 1);
        leftAr.set(1, leftAr.get(1) + rightAr.get(1) + (isBlack ? 1 : 0));
        leftAr.set(2, leftAr.get(2) + rightAr.get(2) + (isBlack ? 0 : 1));

        return leftAr;
    }
}
