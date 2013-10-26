/*
 * Author: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.util.*;


/**
 * BTree is a mutable data type whose values represent
 * String data items, organized as a binary search tree, with the 
 * ordering specified by the provided Comparator<String>. The BTree
 * class implements the Iterable<String> interface by providing an
 * Iterator<String> that generates the individual elements of the 
 * BTree in the order specified by the provided Comparator<String>.
 * 
 * A typical BTree is a {x1, x2, x3, x4...}
 * The abstraction function is:
 * AF(c) = {x.get[i].StringValue | left[i] < value && right[i] > value } ?????
 * 
 * We did this once in class for a few seconds. The book does an awful job of
 * explaining, and I didn't get time to go office hours between starting and
 * the due date. Lo Siento. =(
 * 
 * The Rep Invariant is:
 * for all integers 0 < i < c.size, c.els[i] is a String &&
 * for all integers 0 < i < c.value.index, c.comp.compare(c.els[i],c.value) < 0
 * for all integers c.value.index < i < c.size,
 *        c.comp.compare(c.else[i],c.value) > 0
 * BTree.binTree(comparator) != null &&
 * BTree.size == 0 &&
 * BTree.binTree(comp).iterator.remove -> UnsupportedOperationException
 * BTree.binTree(comp).iterator.next   -> NoSuchElementException
 * BTree.binTree(comp).build(iter).iterator.next -> String, given iter.size > 0
 * c.build(iter) -> ConcurrentModificationException, given at least 1 iterators
 * over c are running.
 * c.iterator.next != iterator.next
 * ???
 * 
 *        
 * @author Nick Jones
 * @version 10/8/2013
 */
class BTree implements Iterable<String> {
    private String value;
    private BTree left;
    private BTree right;
    private Comparator<String> comp;
    private int activeIters;
    
    
    /**
     * repOk : Does the representation work?
     * @return true if rep is ok.
     */
    public boolean repOK() {
        if (left instanceof BTree) {
            for (String s : left) {
                if (comp.compare(s, this.value) >= 0) {
                    return false;
                }
            }
        }
        if (right instanceof BTree) {
            for (String s : right) {
                if (comp.compare(s, this.value) <= 0) {
                    return false;
                }
            }
        }
        return left  instanceof BTree ? left.repOK()  : true &&
               right instanceof BTree ? right.repOK() : true;
    }
    
    
    /**
     * Factory method to generate
     * an empty binary search tree
     * with the given <code>Comparator</code>
     *
     * @param comp the given <code>Comparator</code>
     * @return new empty binary search tree that uses the 
     *         given <code>Comparator</code> for ordering
     */
    public static BTree binTree(Comparator<String> comp) {
        return new BTree(comp); 
    }
    
    
    /**
     * CONSTRUCTOR
     * @param comp The comparator for organizing the BTree
     */
    private BTree(Comparator<String> comp) {
        activeIters = 0;
        this.comp = comp;
    }
    
    
    /**
     * Does the Comparator, that, equal the Comparator, this.comp?
     * @param that The Comparator to compare to this.comp.
     * @return true if they are equal, else false.
     */
    private boolean hasSameComparator(Comparator<String> that) {
        return this.comp.equals(that);
    }
    
    
    /**
     * Modifies: this.value to s
     * Effect: Returns false if this.value is already set.
     * Otherwise, returns true.
     * @param s The String to set as value
     * @return true if set, false if not.
     */
    private boolean setValue(String s) {
        if (value == null) {
            value = s;
            return true;
        }
        else {
            return false;
        }
    }
    
    
    /**
     * Add the String s to this BTree so long as it is not already in the
     * tree.
     * @param s
     */
    private void add(String s) {
        if (!this.setValue(s)) {
            if (this.comp.compare(s, value) < 0) {
                if (!(left instanceof BTree)) {
                    left = new BTree(this.comp);
                }
                left.add(s);
            }
            else if (this.comp.compare(s, value) > 0) {
                if (!(right instanceof BTree)) {
                    right = new BTree(this.comp);
                }
                right.add(s);
            }
        }
    }
    
    
    /**
     * Modifies: 
     * this binary search tree by inserting the 
     * <code>String</code>s from the given 
     * <code>Iterable</code> collection
     * The tree will not have any duplicates 
     * - if an item to be added equals an item
     * that is already in the tree, it will not be added.
     *
     * @param in the given <code>Iterable</code> collection
     */
    public void build(Iterable<String> in) {
        if (activeIters == 0) {
            for (String s : in) {
                this.add(s);
            }
        }
        else {
            throw new ConcurrentModificationException(activeIters + 
                    " iterators running");
        }
    }
    
    
    /**
     * Effect: 
     * Produces a <code>String</code> that consists of 
     * all <code>String</code>s in this tree 
     * separated by comma and a space, 
     * generated in the order defined by this tree's 
     * <code>Comparator</code>.
     * So for a tree with <code>Strings</code> 
     * "hello" "bye" and "aloha" 
     * ordered lexicographically, 
     * the result would be "aloha, bye, hello"
     * @return A String representing this BTree.
     */
    @Override
    public String toString() {
        String ret = "";
        
        for (String s : this) {
            ret += s + ", ";
        }

        return ret.substring(0, Math.max(0, ret.length() - 2));
    }
    
    
    /**
     * Effect: 
     * Produces false if o is not an instance of BTree.
     * Produces true if this tree and the given BTree 
     * contain the same <code>String</code>s and
     * are ordered by the same <code>Comparator</code>.
     * So if the first tree was built with Strings 
     * "hello" "bye" and "aloha" ordered
     * lexicographically,  and the second tree was built 
     * with <code>String</code>s "aloha" "hello" and "bye"  
     * and ordered lexicographically, 
     * the result would be true.
     *
     * @param that the object to compare with this
     * @return true if that equals this, else false.
     */
    @Override
    public boolean equals(Object that) {
        if (that instanceof BTree) {
            BTreeIter thisIter = this.iterator();
            BTreeIter thatIter = ((BTree) that).iterator();
            while (thisIter.hasNext() && thatIter.hasNext()) {
                if (!thisIter.next().equals(thatIter.next())) {
                    thisIter.finish();
                    thatIter.finish();
                    return false;
                }
            }
            thisIter.finish();
            thatIter.finish();
            return !thisIter.hasNext() &&
                   !thatIter.hasNext() &&
                   ((BTree)that).hasSameComparator(this.comp);
        }
        else {
            return false;
        }
    }
    
    
    /**
     * Effect: 
     * Produces an integer that is compatible 
     * with the implemented  equals method 
     * and is likely to be different 
     * for objects that are not equal.
     * @return an int representing this object.
     */
    @Override
    public int hashCode() {
        return this.comp.hashCode();
    }
    
    
    /**
     * Get an iterator for this BTree and add 1 to active iterator count.
     * @return A new iterator for this BTree.
     */
    @Override
    public BTreeIter iterator() {
        activeIters++;
        return new BTreeIter();
    }
    
    
    /**
     * BTreeIter is an Iterator<String> that returns all the elements of 
     * its BTree from the left to the right.
     * @author Nick Jones
     * @version 10/8/2013
     */
    private class BTreeIter implements Iterator<String> {
        private BTreeIter leftIter;
        private BTreeIter rightIter;
        private boolean pastVal;
        private boolean isRunning;
        
        
        /**
         * CONSTRUCTOR
         * Put all the sub iterators into place.
         */
        public BTreeIter() {
            if (BTree.this.left instanceof BTree) {
                leftIter = (BTree.this.left.iterator());
            }
            if (BTree.this.right instanceof BTree) {
                rightIter = (BTree.this.right.iterator());
            }
            this.pastVal = !(BTree.this.value instanceof String);
            this.isRunning = true;
            if (!this.hasNext()) {
                this.finish();
            }
        }
        
        
        /**
         * Return the next element in the Iteration.
         * @return the next element
         * @throws NoSuchElementException if nothing left to return.
         */
        @Override
        public String next() {
            if (leftIter instanceof BTreeIter && leftIter.hasNext()) {
                String ret = leftIter.next();
                if (!this.hasNext()) {
                    this.finish();
                }
                return ret;
            }
            else if (!pastVal) {
                String ret = BTree.this.value;
                pastVal = true;
                if (!this.hasNext()) {
                    this.finish();
                }
                return ret;
            }
            else if (rightIter instanceof BTreeIter && rightIter.hasNext()) {
                String ret = rightIter.next();
                if (!this.hasNext()) {
                    this.finish();
                }
                return ret;
            }
            else {
                this.finish();
                throw new NoSuchElementException("Nothing left");
            }
        }
        
        /**
         * Free up this iterators access to the BTree.
         * Modifies: activeIters--;
         */
        public void finish() {
            if (this.isRunning) {
                this.isRunning = false;
                if (this.leftIter instanceof BTreeIter) {
                    this.leftIter.finish();
                }
                if (this.rightIter instanceof BTreeIter) {
                    this.rightIter.finish();
                }
                BTree.this.activeIters--;
            }
        }
        
        
        /**
         * Are there still elements to return?
         * @return true if there are still elements to return, else false.
         */
        @Override
        public boolean hasNext() {
            return leftIter instanceof BTreeIter && leftIter.hasNext() ||
                   !pastVal ||
                   rightIter instanceof BTreeIter && rightIter.hasNext();
        }
        
        
        /**
         * Operation not supported.
         * @throws UnsupportedOperationException
         */
        @Override
        public void remove() {
            throw new UnsupportedOperationException("remove() unsupported");
        }
    }
}


/**
 * StringByLength orders Strings by length.
 * @author Nick Jones
 * @version 10/8/2013
 */
class StringByLength implements Comparator<String> {
    
    /**
     * @param s1 String 1
     * @param s2 String 2
     * @return s1.length - s2.length
     */
    @Override
    public int compare(String s1, String s2) {
        return s1.length() - s2.length();
    }
    
    /**
     * Does that equal this?
     * @param that Object to compare to
     * @return true if that is an instance of StringByLength
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof StringByLength;
    }
}


/**
 * StringByLex orders String lexigraphically.
 * @author Nick Jones
 * @version 10/8/2013
 */
class StringByLex implements Comparator<String> {
    
    /**
     * @param s1 String 1
     * @param s2 String 2
     * @return s1.compareTo(s2)
     */
    @Override
    public int compare(String s1, String s2) {
        return s1.compareTo(s2);
    }
    
    /**
     * Does that equal this?
     * @param that Object to compare to
     * @return true if that is an instance of StringByLex
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof StringByLex;
    }
}



