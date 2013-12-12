/*
 * Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu 
 * Comments: n/a
 */
import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

import org.junit.Assert;
import org.junit.Test;

/**
 * Test the Class BTree.
 * 
 * @author Nick Jones
 * @version 10/8/2013
 */
public class BTreeTest {

    /**
     * Test contains
     */
    @Test
    public void testContains() {
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLength());
        BTree<Integer> t4 = BTree.binTree(new IntByVal());

        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("bb", "a", "ccd"));
        t3.build(Arrays.asList("a", "b"));
        t4.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8), 20);

        Assert.assertTrue("t1 contains a", t1.contains("a"));
        Assert.assertFalse("t1 contains f", t1.contains("f"));
        Assert.assertFalse("t1 contains aa", t1.contains("aa"));
        Assert.assertTrue("t1 contains cc", t1.contains("cc"));
        Assert.assertTrue("t2 contains a", t2.contains("a"));
        Assert.assertFalse("t2 contains f", t2.contains("f"));
        Assert.assertTrue("t3 contains a", t3.contains("a"));
        Assert.assertFalse("t3 contains f", t3.contains("f"));
        Assert.assertTrue("t4 contains 3", t4.contains(3));
        Assert.assertTrue("t4 contains 9", t4.contains(8));
        Assert.assertFalse("t4 contains 20", t4.contains(20));
        Assert.assertFalse("t4 contains -1", t4.contains(-1));
    }

    /**
     * Test BTre.binTree()
     */
    @Test
    public void testCreator() {
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLength());
        BTree<Integer> t4 = BTree.binTree(new IntByVal());
        
        t4.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8));

        Assert.assertTrue("repOk, t1", t1.repOK());
        Assert.assertTrue("repOk, t2", t2.repOK());
        Assert.assertTrue("repOk, t3", t3.repOK());
        Assert.assertTrue("repOK, t4", t4.repOK());

        Assert.assertFalse("No Strings in t1", t1.iterator().hasNext());
        Assert.assertEquals("t1 size = 0", t1.size(), 0);

        Assert.assertTrue("emptyLex1 = emptyLex1", t1.equals(t1));
        Assert.assertTrue("emptyLex1 = emptyLex2", t1.equals(t2));
        Assert.assertTrue("emptyLex2 = emptyLex1", t2.equals(t1));
        Assert.assertFalse("emptyLength1 != emptyLex1", t3.equals(t1));
        Assert.assertNotNull("emptyLex1 != null", t1);
    }

    /**
     * Test equals()
     */
    @Test
    public void testEquals() {
        Object o = null;
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLength());
        BTree<String> t4 = BTree.binTree(new StringByLength());
        BTree<Integer> t5 = BTree.binTree(new IntByVal());
        BTree<Integer> t6 = BTree.binTree(new IntByVal());

        Assert.assertTrue("empty lex1 = empty lex2", t1.equals(t2));
        Assert.assertEquals("empty hash==empty hash", t1.hashCode(),
                t2.hashCode());
        Assert.assertTrue("empty lex2  = empty lex1", t2.equals(t1));
        Assert.assertFalse("empty len != empty lex", t1.equals(t3));
        Assert.assertFalse("empty == \"Hello\"", t1.equals("Hello"));

        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "cc"));
        t3.build(Arrays.asList("aa", "b", "c"));
        t5.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8));
        t6.build(Arrays.asList(8, 7, 6, 5, 4, 3, 2, 1));

        Assert.assertTrue("{a,bb,cc}=={a,bb,cc}", t1.equals(t2));
        Assert.assertEquals("{a,bb,cc}hash=={a,bb,cc}hash", t1.hashCode(),
                t2.hashCode());
        Assert.assertTrue("{a,bb,cc}=={a,bb,cc}", t2.equals(t1));
        Assert.assertFalse("t1 != t3", t1.equals(t3));
        Assert.assertFalse("t1 != null", t1.equals(o));
        Assert.assertFalse("t2 != null", t2.equals(o));
        Assert.assertFalse("t3 != null", t3.equals(o));
        Assert.assertFalse("t5 != t6", t5.equals(t6));
        Assert.assertFalse("t6 != t5", t6.equals(t5));

        t1.build(Arrays.asList("a"));
        Assert.assertTrue("{a,bb,cc}.add(a)=={a,bb,cc}", t1.equals(t2));

        t6.build(Arrays.asList(0));
        Assert.assertTrue("t5 == t6", t5.equals(t6));
        Assert.assertTrue("t6 == t5", t6.equals(t5));

        t6.build(Arrays.asList(0));
        Assert.assertTrue("t5 == t6", t5.equals(t6));
        Assert.assertTrue("t6+0 == t5", t6.equals(t5));

        t4.build(Arrays.asList("aa", "b", "c"));
        Assert.assertFalse("t1 != t4", t1.equals(t4));
        Assert.assertFalse("t4 != t1", t4.equals(t1));
    }

    /**
     * test
     */
    @Test
    public void testIterator() {
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLength());
        BTree<Integer> t4 = BTree.binTree(new IntByVal());

        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "ccd"));
        t3.build(Arrays.asList("a", "b"));
        t4.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8));

        Iterator<String> i1 = t1.iterator();

        Assert.assertTrue("i1.hasNext()", i1.hasNext());
        Assert.assertTrue("i1.next().equals()", i1.next().equals("a"));
        Assert.assertTrue("i1.next = bb", i1.next().equals("bb"));

        try { // Test t1 cannot ConcurrentModify
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"), 10);
            Assert.fail("Iterators Concurrent 1: Stopped");
        }
        catch (ConcurrentModificationException e) {
            Assert.assertTrue("Iterators Concurrent 1: Running", e.getMessage()
                    .equals("1 iterators running"));
        }

        Assert.assertTrue("i1.next = cc", i1.next().equals("cc"));
        while (i1.hasNext()) { // finish i1
            i1.next();
        }

        Iterator<Integer> i2 = t4.iterator();
        Iterator<Integer> i3 = t4.iterator();
        List<Integer> l = Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8);
        Iterator<Integer> i4 = l.iterator();

        try { // Test that t4 cannot concurrent modify
            t4.build(Arrays.asList(20));
            Assert.fail("Iterators Concurrent 1: Stopped");
        }
        catch (ConcurrentModificationException e) {
            Assert.assertTrue("t4 iter running",
                    e.getMessage().equals("2 iterators running"));
        }

        while (i4.hasNext()) { // Test i2 has correct content
            Assert.assertTrue("i2 ordered iter", i2.next().equals(i4.next()));
        }

        while (i3.hasNext()) { // Run down i3
            i3.next();
        }

        // Test i2 empty
        Assert.assertFalse("i2 empty", i2.hasNext());

        try { // Test t1 can modify again.
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"));
        }
        catch (ConcurrentModificationException e) {
            Assert.fail("Iterators Concurrent 2: Running");
        }

        try { // Test i1 is still empty
            i1.next();
            Assert.fail("Has Next");
        }
        catch (NoSuchElementException e) {
            Assert.assertNotNull("No Such Element", e);
        }

        try { // Test that remove does not work.
            i1.remove();
        }
        catch (UnsupportedOperationException e) {
            Assert.assertNotNull("Operation not supported", e);
        }
    }

    /**
     * Test toString()
     */
    @Test
    public void testToString() {
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLex());
        BTree<Integer> t4 = BTree.binTree(new IntByVal());

        Assert.assertTrue("emptyLex.toString()", t1.toString().equals(""));
        Assert.assertTrue("emptyLex.toString()", t2.toString().equals(""));
        Assert.assertTrue("emptyLength.toString()", t3.toString().equals(""));
        Assert.assertTrue("emptyInt.toString()", t4.toString().equals(""));

        t1.build(Arrays.asList("a", "b", "c"));
        t2.build(Arrays.asList("a", "a", "c"), 2);
        t3.build(Arrays.asList("e", "a", "f", "e", "d", "b", "z", "c"), -1);
        t4.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8));

        Assert.assertTrue("t1 toString", t1.toString().equals("a, b, c"));
        Assert.assertTrue("t2 toString", t2.toString().equals("a"));
        Assert.assertTrue("t3 toString",
                t3.toString().equals("a, b, c, d, e, f, z"));
        Assert.assertTrue("t4 toString",
                t4.toString().equals("0, 1, 2, 3, 4, 5, 6, 7, 8"));
    }

    /**
     * Test size
     */
    @Test
    public void testSize() {
        BTree<String> t1 = BTree.binTree(new StringByLex());
        BTree<String> t2 = BTree.binTree(new StringByLex());
        BTree<String> t3 = BTree.binTree(new StringByLex());
        BTree<Integer> t4 = BTree.binTree(new IntByVal());

        Assert.assertTrue("emptyLex.toString()", t1.toString().equals(""));
        Assert.assertTrue("emptyLength.toString()", t3.toString().equals(""));
        Assert.assertTrue("emptyInt.toString()", t4.toString().equals(""));

        t1.build(Arrays.asList("a", "b", "c"));
        t2.build(Arrays.asList("a", "a", "c"), 2);
        t3.build(Arrays.asList("e", "a", "f", "e", "d", "b", "z", "c"), -1);
        t4.build(Arrays.asList(0, 1, 2, 3, 4, 5, 6, 7, 8));

        Assert.assertEquals("t1.size = 3", t1.size(), 3);
        Assert.assertEquals("t2.size = 1", t2.size(), 1);
        Assert.assertEquals("t3 size = 8", t3.size(), 7);
        Assert.assertEquals("t4 size", t4.size(), 9);
    }
}
