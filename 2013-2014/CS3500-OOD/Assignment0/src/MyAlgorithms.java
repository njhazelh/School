import java.util.ArrayList;
import java.util.Arrays;
import tester.Tester;

/**
 * This class contains a sort method for ArrayLists of String
 * @author Nicholas Jones
 * @version 1.0 - 9/10/2013
 */
class MyAlgorithms {
    /**
     * Swaps the Strings located at i1 and i2 in list
     * @param list The list to swap elements in
     * @param i1 The index of the first element
     * @param i2 The index of the second element
     * INVARIANT: 0<=i1 && i2<list.size()
     */
    private static void swap(ArrayList<String> list, Integer i1, Integer i2) {
        String s1 = list.get(i1);
        list.add(i1, list.get(i2));
        list.remove(i1 + 1);
        list.add(i2, s1);
        list.remove(i2 + 1);
    }
    
    /**
     * Sorts the given list of Strings into alphabetical order
     * using QuickSort.
     * @param slist The list to sort
     */
    public static void sort(ArrayList<String> slist) {
        if (slist == null || slist.size() == 0 || slist.size() == 1) {
            return;
        }
        
        // Set the Pivot
        swap(slist, 0, (int)(Math.random() * slist.size()));
        
        // Divide the list into lower and higher than the pivot
        Integer k = 0;
        for (Integer i = 1; i < slist.size(); i++) {
            if (slist.get(i).compareTo(slist.get(0)) < 0) {
                swap(slist, ++k, i);
            }
        }
        swap(slist, 0, k);
        
        // Sort each side
        ArrayList<String> lowerSide = 
                new ArrayList<String>(slist.subList(0, k));
        ArrayList<String> higherSide = 
                new ArrayList<String>(slist.subList(k + 1, slist.size()));
        sort(lowerSide);
        sort(higherSide);
        
        // Combine sides and pivot back into list
        lowerSide.add(slist.get(k));
        lowerSide.addAll(higherSide);
        slist.clear();
        slist.addAll(lowerSide);
    }
}

/**
 * Examples and Tests for MyAlgorithms
 * @author Nick
 * @version 1.0
 */
class Examples {
    private final ArrayList<String> list1 =
            new ArrayList<String>(Arrays.asList("a", "b", "c", "d", 
                    "e", "f", "g", "h", "i"));
    private final ArrayList<String> scramble1 = 
            new ArrayList<String>(Arrays.asList("i", "g", "h", "a", 
                    "b", "f", "e", "c", "d"));
    private final ArrayList<String> list2 =
            new ArrayList<String>(Arrays.asList("agatha", "alfred", "andrew", 
                    "betty", "cathy", "devon", "drew", "elizabeth", "emily", 
                    "nick", "nicole", "sam", "sue", "trevor"));
    private final ArrayList<String> scramble2 =
            new ArrayList<String>(Arrays.asList("cathy", "alfred", "agatha", 
                    "betty", "andrew", "drew", "devon", "elizabeth", "emily", 
                    "trevor", "nicole", "sue", "nick", "sam"));
    
    /**
     * Test the sort method
     * @param t The tester
     */
    void testSort(Tester t) {
        new MyAlgorithms(); // Needed to pass webcat tests for some reason
        ArrayList<String> temp1 = new ArrayList<String>(scramble1);
        ArrayList<String> temp2 = new ArrayList<String>(scramble2);
        ArrayList<String> temp3 = new ArrayList<String>();
        MyAlgorithms.sort(temp1);
        MyAlgorithms.sort(temp2);
        MyAlgorithms.sort(temp3);
        MyAlgorithms.sort(null);
        t.checkExpect(temp1, list1);
        t.checkExpect(temp2, list2);
        t.checkExpect(temp3, new ArrayList<String>());
    }
}