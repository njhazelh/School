import static org.junit.Assert.*;

import java.util.*;
import org.junit.Test;

/**
 * Test the Class BTree.
 * @author Nick Jones
 * @version 10/8/2013
 */
public class BTreeTest {

    /**
     * Test BTre.binTree()
     */
    @Test
    public void testCreator() {
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        assertTrue("repOK t1", t1.repOK());
        assertTrue("repOK t2", t2.repOK());
        assertTrue("repOK t3", t3.repOK());
        assertTrue("emptyLex1 = emptyLex2", t1.equals(t2));
        assertTrue("emptyLex2 = emptyLex1", t2.equals(t1));
        assertFalse("emptyLength1 != emptyLex1", t3.equals(t1));
        assertNotNull("emptyLex1 != null", t1);
    }
    
    /**
     * Test toString()
     */
    @Test
    public void testToString() {
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        assertTrue("emptyLex.toString()", t1.toString().equals(""));
        assertTrue("emptyLength.toString()", t3.toString().equals(""));
        
        t1.build(Arrays.asList("a", "b", "c"));
        t2.build(Arrays.asList("a", "a"));
        
        assertTrue("{a,b,c}.toString()", t1.toString().equals("a, b, c"));
        assertTrue("t2.toString()", t2.toString().equals("a"));
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
        
        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "cc"));
        t3.build(Arrays.asList("aa", "b", "c"));
        
        assertTrue("{a,bb,cc}=={a,bb,cc}", t1.equals(t2));
        assertTrue("{a,bb,cc}=={a,bb,cc}", t2.equals(t1));
        assertFalse("t1 != t3", t1.equals(t3));
        assertFalse("t1 != null", t1.equals(o));
        assertFalse("t2 != null", t2.equals(o));
        assertFalse("t3 != null", t3.equals(o));
        
        t1.build(Arrays.asList("a"));
        assertTrue("{a,bb,cc}.add(a)=={a,bb,cc}", t1.equals(t2));
        
        t4.build(Arrays.asList("aa", "b", "c"));
        
        assertFalse("t1 != t4", t1.equals(t4));
        assertFalse("t4 != t1", t4.equals(t1));
    }
    
    /**
     * test hashCode
     */
    @Test
    public void testHashCode() {
        BTree t1 = BTree.binTree(new StringByLex());
        BTree t2 = BTree.binTree(new StringByLex());
        BTree t3 = BTree.binTree(new StringByLength());
        
        t1.build(Arrays.asList("a", "bb", "cc"));
        t2.build(Arrays.asList("a", "bb", "ccd"));
        t3.build(Arrays.asList("b", "a"));
        
        assertNotSame("", t1.hashCode(), t3.hashCode());
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
        
        assertTrue("i1.hasNext()", i1.hasNext());
        assertTrue("it.next().equals()", i1.next().equals("a"));
        
        try {
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"));
            fail("Iterators running");
        }
        catch (ConcurrentModificationException e) {
            assertTrue("IteratorsRunning", 
                    e.getMessage().equals("1 iterators running"));
        }
        
        while (i1.hasNext()) {
            i1.next();
        }
        
        try {
            t1.build(Arrays.asList("asdf", "fg", "a", "aa", "aaa"));
        }
        catch (ConcurrentModificationException e) {
            fail("Iterators stopped");
        }
        
        try {
            i1.remove();
        }
        catch (UnsupportedOperationException e) {
            assertNotNull("Operation not supported", e);
        }
    }

}
