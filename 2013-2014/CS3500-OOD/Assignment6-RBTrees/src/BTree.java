/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */

import java.util.ArrayList;
import java.util.Comparator;

/**
 * BTree is an implementation of BinaryTrees of Strings using Red/Black trees,
 * which balance the tree to maintain good worst case efficiency.
 * 
 * INVARIANTS:
 *  - No red node has a Red Parent.
 *  - Every path from the root to an empty node contains the same number of
 *    black nodes. 
 * 
 * @author Nick Jones
 * @version 10/26/2013
 * 
 */
public class BTree {
    private Comparator<String> comp;
    private IRBTree            tree;
    
    private BTree(Comparator<String> comp) {
        this.comp = comp;
        this.tree = Leaf.LEAF;
    }
    
    public BTree binTree(Comparator<String> comp) {
        return new BTree(comp);
    }
    

}
