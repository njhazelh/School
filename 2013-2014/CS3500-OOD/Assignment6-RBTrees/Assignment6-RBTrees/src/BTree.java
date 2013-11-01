/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

import java.util.Comparator;

import rbtree.RBTree;

/**
 * BTree is an implementation of BinaryTrees of Strings using Red/Black trees,
 * which balance the tree to maintain good worst case efficiency.
 * 
 * INVARIANTS: - No red node has a Red Parent. - Every path from the root to an
 * empty node contains the same number of black nodes.
 * 
 * @author Nick Jones
 * @version 10/26/2013
 * 
 */
public class BTree {
    private Comparator<String> comp;
    private RBTree             tree;
    
    private BTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = RBTree.binTree(comp);
    }
    
    public BTree binTree(Comparator<String> comp) {
        return new BTree(comp);
    }
    
    
}
