/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
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
     * Test Leaves
     */
    @Test
    public void testLeaf() {
        Object o = null;

        Leaf<String> l1 = new Leaf<String>();
        Leaf<Integer> l2 = new Leaf<Integer>();
        Leaf<String> l3 = new Leaf<String>();

        Assert.assertTrue("Leaf<String> = Leaf<String>", l1.equals(l3));
        Assert.assertFalse("Leaf<String> != null", l1.equals(o));
        Assert.assertTrue("Leaf<String> = Leaf<Integer>", l1.equals(l2));
    }

    /**
     * Test something.
     */
    @Test
    public void testNode() {
        Comparator<String> lex = new Comparator<String>() {
            /**
             * Compares s1 and s2 for lex
             * 
             * @param s1 String 1
             * @param s2 String 2
             * @return < 0 if s1 < s2, 0 if s1 == s2, > 0 if s1 > s2
             */
            @Override
            public int compare(String s1, String s2) {
                return s1.compareTo(s2);
            }
        };

        Comparator<String> length = new Comparator<String>() {
            /**
             * Compares s1 and s2 for length
             * 
             * @param s1 String 1
             * @param s2 String 2
             * @return < 0 if s1 < s2, 0 if s1 == s2, > 0 if s1 > s2
             */
            @Override
            public int compare(String s1, String s2) {
                return s1.length() - s2.length();
            }
        };

        Comparator<Integer> num = new Comparator<Integer>() {
            /**
             * Compares s1 and s2 for number comparison
             * 
             * @param num1 int 1
             * @param num2 int 2
             * @return < 0 if num1 < num2, 0 if num == num2, > 0 if num1 > num2
             */
            @Override
            public int compare(Integer num1, Integer num2) {
                return num1.compareTo(num2);
            }
        };

        Leaf<String> stringLeaf = new Leaf<String>();
        Leaf<Integer> intLeaf = new Leaf<Integer>();
        
        Node<String> n1 = new Node<String>(Color.BLACK, lex, stringLeaf, "f",
                stringLeaf);
        Node<String> n2 = new Node<String>(Color.BLACK, length, stringLeaf,
                "a", stringLeaf);
        Node<String> n3 = new Node<String>(Color.BLACK, lex, stringLeaf, "e",
                stringLeaf);
        Node<Integer> n4 = new Node<Integer>(Color.BLACK, num, intLeaf, 0,
                intLeaf);
        Node<Integer> n5 = new Node<Integer>(Color.BLACK, num, intLeaf, 0,
                intLeaf);
        

        Object o = null;

        for (String s : Arrays.asList("e", "a", "f", "e", "d", "b", "z", "c")) {
            n1.add(s);
            n1 = n1.getRoot();
            Assert.assertTrue("n1 repOK", n1.repOK());
        }

        for (String s : Arrays.asList("a", "aa", "aaa", "bbbb", "bbbbb",
                "bbbbbb", "bbbbbbb", "bbbbbbbb")) {
            n2.add(s);
            n2 = n2.getRoot();
            Assert.assertTrue("n2 repOK", n2.repOK());
        }

        for (String s : Arrays.asList("h", "g", "f", "e", "d", "c", "b", "a")) {
            n3.add(s);
            n3 = n3.getRoot();
            Assert.assertTrue("n3 repOK", n3.repOK());
        }

        for (Integer i = 1; i <= 20000; i++) {
            n4.add(i);
            n4 = n4.getRoot();
            if (!n4.contains(i)) {
                Assert.fail("added but doesn't contain" + i);
            }
        }

        for (Integer i = 1; i <= 200000; i++) {
            Integer n = (new Double(Math.random() * 2000)).intValue();
            n5.add(n);
            n5 = n5.getRoot();
        }
        
        Assert.assertTrue("n4 size", n4.size() == 20001);
        Assert.assertTrue("n1 repOK", n1.repOK());
        Assert.assertTrue("n2 repOK", n2.repOK());
        Assert.assertTrue("n1 balanced", n1.toStructString("").equals(
                "\n\t\tRED z\n\tBLACK f\nBLACK e\n\t\tBLACK d\n\t\t\tRED "
                + "c\n\tRED b\n\t\tBLACK a\n"));
        Assert.assertTrue("n2 balanced", n2.toStructString("").equals(
                "\n\t\t\tRED bbbbbbbb\n\t\tBLACK bbbbbbb\n\tRED bbbbbb\n\t\t"
                + "BLACK bbbbb\nBLACK bbbb\n\t\tBLACK aaa\n\tRED aa\n\t\tBLACK"
                + " a\n"));
        Assert.assertTrue("n3 balanced", n3.toStructString("").equals(
                "\n\t\tBLACK h\n\tRED g\n\t\tBLACK f\nBLACK e\n\t\tBLACK d\n\t"
                + "RED c\n\t\tBLACK b\n\t\t\tRED a\n"));
        Assert.assertTrue("n1 root BLACK", n1.getColor() == Color.BLACK);
        Assert.assertTrue("n2 root BLACK", n2.getColor() == Color.BLACK);
        Assert.assertFalse("n1 != n2", n1.equals(n2));
        Assert.assertFalse("n1 != null", n1.equals(o));
        Assert.assertFalse("n2 != null", n2.equals(o));
        Assert.assertTrue("root n1 = n1", n1.getRoot().equals(n1));
        Assert.assertTrue("root n2 = n2", n2.getRoot().equals(n2));
    }
}
