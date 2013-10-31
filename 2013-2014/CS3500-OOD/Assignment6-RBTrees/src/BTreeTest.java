/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.ccs.neu.edu Comments: n/a
 */
import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
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
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("bb", "a", "ccd"));
        t3.build(Arrays.asList("a", "b"));
        
        Assert.assertTrue("t1 contains a", t1.contains("a"));
        Assert.assertFalse("t1 contains f", t1.contains("f"));
        Assert.assertFalse("t1 contains aa", t1.contains("aa"));
        Assert.assertTrue("t1 contains cc", t1.contains("cc"));
        Assert.assertTrue("t2 contains a", t2.contains("a"));
        Assert.assertFalse("t2 contains f", t2.contains("f"));
        Assert.assertTrue("t3 contains a", t3.contains("a"));
        Assert.assertFalse("t3 contains f", t3.contains("f"));
    }
    
    /**
     * Test BTre.binTree()
     */
    @Test
    public void testCreator() {
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        Assert.assertFalse("No Strings in t1", t1.iterator().hasNext());
        Assert.assertEquals("t1 size = 0", t1.size(), 0);
        
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
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        BTree t4 = BTree.binTree(new StringByLength());
        
        Assert.assertTrue("empty lex1 = empty lex2", t1.equals(t2));
        Assert.assertEquals("empty hash==empty hash", t1.hashCode(),
                t2.hashCode());
        Assert.assertTrue("empty lex2  = empty lex1", t2.equals(t1));
        Assert.assertFalse("empty len != empty lex", t1.equals(t3));
        
        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "cc"));
        t3.build(Arrays.asList("aa", "b", "c"));
        
        Assert.assertTrue("{a,bb,cc}=={a,bb,cc}", t1.equals(t2));
        Assert.assertEquals("{a,bb,cc}hash=={a,bb,cc}hash", t1.hashCode(),
                t2.hashCode());
        Assert.assertTrue("{a,bb,cc}=={a,bb,cc}", t2.equals(t1));
        Assert.assertFalse("t1 != t3", t1.equals(t3));
        Assert.assertFalse("t1 != null", t1.equals(o));
        Assert.assertFalse("t2 != null", t2.equals(o));
        Assert.assertFalse("t3 != null", t3.equals(o));
        
        t1.build(Arrays.asList("a"));
        Assert.assertTrue("{a,bb,cc}.add(a)=={a,bb,cc}", t1.equals(t2));
        
        t4.build(Arrays.asList("aa", "b", "c"));
        
        Assert.assertFalse("t1 != t4", t1.equals(t4));
        Assert.assertFalse("t4 != t1", t4.equals(t1));
    }
    
    /**
     * test
     */
    @Test
    public void testIterator() {
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "ccd"));
        t3.build(Arrays.asList("a", "b"));
        
        Iterator<String> i1 = t1.iterator();
        
        Assert.assertTrue("i1.hasNext()", i1.hasNext());
        Assert.assertTrue("i1.next().equals()", i1.next().equals("a"));
        Assert.assertTrue("i1.next = bb", i1.next().equals("bb"));
        
        try {
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"));
            Assert.fail("Iterators Concurrent 1: Stopped");
        }
        catch (ConcurrentModificationException e) {
            Assert.assertTrue("Iterators Concurrent 1: Running", e.getMessage()
                    .equals("1 iterators running"));
        }
        
        Assert.assertTrue("i1.next = cc", i1.next().equals("cc"));
        while (i1.hasNext()) {
            i1.next();
        }
        
        try {
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"));
        }
        catch (ConcurrentModificationException e) {
            Assert.fail("Iterators Concurrent 2: Running");
        }
        
        try {
            i1.next();
            Assert.fail("Has Next");
        }
        catch (NoSuchElementException e) {
            Assert.assertNotNull("No Such Element", e);
        }
        
        try {
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
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        Assert.assertTrue("emptyLex.toString()", t1.toString().equals(""));
        Assert.assertTrue("emptyLength.toString()", t3.toString().equals(""));
        
        t1.build(Arrays.asList("a", "b", "c"));
        t2.build(Arrays.asList("a", "a", "c"), 2);
        
        Assert.assertTrue("{a,b,c}.toString()", t1.toString().equals("a, b, c"));
        Assert.assertEquals("t1.size = 3", t1.size(), 3);
        Assert.assertTrue("t2.toString()", t2.toString().equals("a"));
        Assert.assertEquals("t2.size = 1", t2.size(), 1);
    }
}
