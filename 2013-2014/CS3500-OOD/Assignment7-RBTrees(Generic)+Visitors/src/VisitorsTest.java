/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.ArrayList;
import java.util.Arrays;

import org.junit.Assert;
import org.junit.Test;

/**
 * VisitorsTest tests the functionality of Visitors for RBTrees.
 * 
 * @author Nick Jones
 * @version 11/6/2013
 */
public class VisitorsTest {

    /**
     * Test the PathLengths Visitor
     */
    @Test
    public void testPathLengths() {
        BTree<Integer> tree = BTree.binTree(new IntByVal());
        tree.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12));

        ArrayList<Integer> result = tree.accept(new PathLengths<Integer>());
        ArrayList<Integer> actual = new ArrayList<Integer>(Arrays.asList(3, 3,
                3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5));

        for (int i = 0; (i < result.size()) && (i < actual.size()); ++i) {
            Assert.assertEquals("r" + i + " = " + "a1", actual.get(i),
                    result.get(i));
        }
    }

    /**
     * Test the BlackHeight Visitor
     */
    @Test
    public void testBlackHeight() {
        BTree<Integer> tree = BTree.binTree(new IntByVal());
        tree.build(Arrays.asList(12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0));

        Integer result = tree.accept(new BlackHeight<Integer>());
        Integer actual = 3;

        Assert.assertEquals("Black Height test", actual, result);
    }

    /**
     * Test the CountNodes Visitor
     */
    @Test
    public void testCountNodes() {
        BTree<Integer> tree = BTree.binTree(new IntByVal());
        tree.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12));

        ArrayList<Integer> result = tree.accept(new CountNodes<Integer>());
        ArrayList<Integer> actual = new ArrayList<Integer>(Arrays.asList(13, 9,
                4));

        Assert.assertEquals("0r == 0a", actual.get(0), result.get(0));
        Assert.assertEquals("1r == 1a", actual.get(1), result.get(1));
        Assert.assertEquals("2r == 2a", actual.get(2), result.get(2));
    }

    /**
     * Test the Height Visitor
     */
    @Test
    public void testHeight() {
        BTree<Integer> tree = BTree.binTree(new IntByVal());
        tree.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12));

        Integer result = tree.accept(new Height<Integer>());
        Integer actual = 5;

        Assert.assertEquals("Height test", actual, result);
    }
}
