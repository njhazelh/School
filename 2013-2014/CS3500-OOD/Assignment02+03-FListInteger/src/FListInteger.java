/*
 * Name: Nicholas Jones
 * email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */


/**
 * @author Nick Jones
 * @version 9/29/2013
 * FListInteger is a Factory implementation representing a list of Integers.
 */
abstract class FListInteger {
    
    /**
     * Make an empty list
     * @return an empty list
     */
    public static FListInteger emptyList() {
        return new EmptyList();
    }
    
    /**
     * Add the given integer to the start of the list.
     * @param list The list to add to
     * @param num The number to add
     * @return A new list with all the elements of list prefixed by num.
     */
    public static FListInteger add(FListInteger list, Integer num) {
        return new FList(list, num);
    }
    
    /**
     * Is the given list empty?
     * @param list The list to check
     * @return true if empty else false
     */
    public static boolean isEmpty(FListInteger list) {
        return list.isEmpty();
    }
    
    /**
     * Get the Integer at the given index of the list
     * @param list The list to get from
     * @param index The index to check at (starts at 0).
     * @return The Integer at index
     */
    public static Integer get(FListInteger list, int index) {
        return list.get(index);
    }
    
    /**
     * Set the Integer at index in list to num
     * @param list The list to modify
     * @param index The index to change at. index = [0, size)
     * @param num The new value at index
     * @return A FListInteger with all values of list, but with the value
     * at index replaced by num.
     */
    public static FListInteger set(FListInteger list, int index, Integer num) {
        return list.set(index, num);
    }
    
    /**
     * How many elements are in the list?
     * @param list  The list to get the size of.
     * @return The number of elements in the list
     */
    public static int size(FListInteger list) {
        return list.size();
    }
    
    /**
     * Is the list empty?
     * @return true if empty, else false.
     */
    public abstract boolean isEmpty();
    
    /**
     * Get the Integer at the given index of the list
     * @param index The index to check at (starts at 0).
     * @return The Integer at index
     */
    public abstract Integer get(int index);
    
    /**
     * Set the Integer at index in list to num
     * @param index The index to change at. index = [0, size)
     * @param num The new value at index
     * @return A FListInteger with all values of list, but with the value
     * at index replaced by num.
     */
    public abstract FListInteger set(int index, Integer num);
    
    /**
     * How many elements are in this list?
     * @return The number of elements in the list
     */
    public abstract int size();
    
    /**
     * Return a String representing the list
     * @return [elem0, elem1, elem2...]
     */
    @Override
    public abstract String toString();
    
    /**
     * Does that equal this?
     * @param that The Object to compare to.
     * @return true if that is an instance of the same object and has
     * the same values at the same indexes, else false.
     */
    @Override
    public abstract boolean equals(Object that);
    
    /**
     * Return a non-unique int representing this object, such that
     * this.equals(that) => this.hashCode() == that.hashCode()
     * but not that
     * this.hashCode() == that.hashCode() => this.equals(that)
     * @return The hashCode.
     */
    @Override
    public abstract int hashCode();
    
    /**
     * Get a new instance of FListInteger with the same values,
     * but at a different memory location.
     * @return The new instance
     */
    @Override
    public abstract FListInteger clone();
}

/**
 * EmptyList represents a FListInteger that has no elements
 * @author Nick Jones
 * @version 1.0 - 9/29/2013
 */
class EmptyList extends FListInteger {
    
    /**
     * Is EmptyList empty? YES!
     * @return true
     */
    public boolean isEmpty() {
        return true;
    }
    
    /**
     * Ain't no values to get in an EmptyList
     * @param index The index to get
     * @return The value at index.
     * @throws IndexOutOfBoundsException
     */
    public Integer get(int index) {
        throw new IndexOutOfBoundsException("no #" + index + " element in " +
                this.toString());
    }
    
    /**
     * Ain't no values to set in an EmptyList
     * @param index The index to change
     * @param num The new value
     * @return A list with num at index
     * @throws IndexOutOfBoundsException
     */
    public FListInteger set(int index, Integer num) {
        throw new IndexOutOfBoundsException("no #" + index + " element in " +
                this.toString());
    }
    
    /**
     * How many elements are in an EmptyList?
     * @return 0
     */
    public int size() {
        return 0;
    }
    
    /**
     * Get a representation of this EmptyList as a String.
     * @return "[]"
     */
    public String toString() {
        return "[]";
    }
    
    /**
     * Is that an EmptyString?
     * @param that The Object to compare to.
     * @return true if that is EmptyList, else false
     */
    public boolean equals(Object that) {
        return that instanceof EmptyList;
    }
    
    /**
     * Return a non-unique int representing this object, such that
     * this.equals(that) => this.hashCode() == that.hashCode()
     * but not that
     * this.hashCode() == that.hashCode() => this.equals(that)
     * @return The hashCode: 0.
     */
    public int hashCode() {
        return 0;
    }
    
    /**
     * Get a new instance of EmptyList.
     * @return The new instance
     */
    public FListInteger clone() {
        return new EmptyList();
    }
}

/**
 * FList represents an FListInteger that has one or more elements
 * @author Nick Jones
 * @version 1.0 - 9/29/2013
 */
class FList extends FListInteger {
    private FListInteger sub;
    private Integer num;
    
    /**
     * CONSTRUCTOR
     * @param sub A FListInteger
     * @param num The Integer to go at the front of the new FList
     */
    public FList(FListInteger sub, Integer num) {
        this.sub = sub.clone();
        this.num = num;
    }
    
    /**
     * Is this an EmptyList?
     * @return false
     */
    public boolean isEmpty() {
        return false;
    }
    
    /**
     * Get the Integer at index [0, size)
     * @param index The index to check.
     * @return The value at index.
     */
    public Integer get(int index) {
        if (index == 0) {
            return this.num;
        }
        else {
            return this.sub.get(index - 1);
        }
    }
    
    /**
     * Set the Integer at index to number.
     * @param index The index to change
     * @param number The new value at index
     * @return A new instance of FListInteger where the value at index is number
     */
    public FListInteger set(int index, Integer number) {
        if (index == 0) {
            return FListInteger.add(this.sub, number);
        }
        else {
            return FListInteger.add(this.sub.set(index - 1, number), this.num);
        }
    }
    
    /**
     * How many Integers are in this list?
     * @return The number of Integers in the list.
     */
    public int size() {
        return 1 + this.sub.size();
    }
    
    /**
     * Return a String representing the list
     * @return [elem0, elem1, elem2...]
     */
    public String toString() {
        if (this.sub.isEmpty()) {
            return "[" + this.num + "]";
        }
        else {
            return "[" + num + ", " + 
                    this.sub.toString().substring(1, sub.toString().length());
        }
    }
    
    /**
     * Does that equal this?
     * @param that The Object to compare to.
     * @return true if that is an instance of the same object and has
     * the same values at the same indexes, else false.
     */
    public boolean equals(Object that) {
        Boolean result = true;
        
        if (that instanceof FList &&
                ((FList)that).size() == this.size()) {
            for (int i = this.size() - 1; i >= 0; i--) {
                if (!((FList)that).get(i).equals(this.get(i))) {
                    result = false;
                }
            }
        }
        else {
            result = false;
        }
        
        return result;
    }
    
    /**
     * Return a non-unique int representing this object, such that
     * this.equals(that) => this.hashCode() == that.hashCode()
     * but not that
     * this.hashCode() == that.hashCode() => this.equals(that)
     * @return The hashCode: 0.
     */
    public int hashCode() {
        return this.size();
    }
    
    /**
     * Get a new instance of this with the values of this at the same indexes.
     * @return The new instance
     */
    public FListInteger clone() {
        FListInteger temp = FListInteger.emptyList();
        
        for (int i = this.size() - 1; i >= 0; i--) {
            temp = FListInteger.add(temp, this.get(i));
        }
        
        return temp;
    }
}
