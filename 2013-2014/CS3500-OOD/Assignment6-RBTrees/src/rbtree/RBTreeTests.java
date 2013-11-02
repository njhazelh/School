/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments:
 */
package rbtree;

import java.util.Arrays;
import java.util.Comparator;

import org.junit.Assert;
import org.junit.Test;

/**
 * @author Nicholas Jones
 * @version Nov 1, 2013
 */
public class RBTreeTests {
    
    /**
     * This takes the place of StringByLex
     */
    private final Comparator<String> lex =
            new Comparator<String>() {
                /**
                 * Compares s1 and s2 for lex
                 * @param s1 String 1
                 * @param s2 String 2
                 * @return < 0 if s1 < s2, 0 if s1 == s2, > 0 if s1 > s2
                 */
                @Override
                public int compare(String s1,
                                    String s2) {
                    return s1.compareTo(s2);
                }
            };
    
    /**
     * This takes the place of StringByLength
     */
    private final Comparator<String> length = 
            new Comparator<String>() {
                /**
                 * Compares s1 and s2 for length
                 * @param s1 String 1
                 * @param s2 String 2
                 * @return < 0 if s1 < s2, 0 if s1 == s2, > 0 if s1 > s2
                 */
                @Override
                public int compare(String s1,
                                    String s2) {
                    return s1.length() -  s2.length();
                }
            };
    
    /**
     * Test Leaves
     */
    @Test
    public void testLeaf() {
        Object o = null;
        
        Assert.assertTrue("Leaf = Leaf", Leaf.INSTANCE.equals(Leaf.INSTANCE));
        Assert.assertFalse("Leaf != null", Leaf.INSTANCE.equals(o));
    }
    
    /**
     * Test something.
     */
    @Test
    public void testNode() {
        Node n1 =
                new Node(Color.BLACK, this.lex, Leaf.INSTANCE, "e",
                    Leaf.INSTANCE);
        Node n2 =
                new Node(Color.BLACK, this.length, Leaf.INSTANCE, "a",
                    Leaf.INSTANCE);
        Object o = null;
        
        for (String s : Arrays.asList("e", "a", "f", "e", "d", "b", "z", "c")) {
            n1.add(s);
        }
        
        for (String s : Arrays.asList("e", "a", "f", "e", "d", "b", "z", "c")) {
            n2.add(s);
        }
        
        System.out.println(n1.toStructString());
        System.out.println(n2.toStructString());
        
        Assert.assertTrue("n1 root BLACK", n1.getColor() == Color.BLACK);
        Assert.assertTrue("n2 root BLACK", n2.getColor() == Color.BLACK);
        Assert.assertFalse("n1 != n2", n1.equals(n2));
        Assert.assertFalse("n1 != null", n1.equals(o));
        Assert.assertFalse("n2 != null", n2.equals(o));
        Assert.assertTrue("root(n1) = n1", n1.getRoot().equals(n1));
        Assert.assertTrue("root(n2) = n2", n2.getRoot().equals(n2));
    }
    
}
