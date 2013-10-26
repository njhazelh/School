/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import java.io.PrintWriter;
import java.util.*;

/**
 * BTreeStressTest is a program to run stress tests on BTree using multiple
 * dictionaries of words, 3 different Comparators, and various number of words
 * to add to each BTree.
 * @author Nick Jones
 * @version 2.0 - 10/17/2013
 */
public class BTreeStressTest {
    // List of Word Files
    private static final List<String> WORD_FILES = 
            Arrays.asList("lexicographically_ordered.txt", 
                "reverse_ordered.txt", 
                "prefix_ordered.txt", 
                "random_order.txt");
    
    // List of Literature Files
    private static final List<String> LIT_FILES = 
            Arrays.asList("iliad.txt",
                "hippooath_DUPLICATES.txt");
    
    // List of Comparators
    @SuppressWarnings("unchecked")
    private static final List<Comparator<String>> COMPARATORS = 
            Arrays.asList(new StringByLex(), 
                new StringReverseByLex(), 
                new StringWithOutPrefixByLex());
    
    // List of Integers to be added to BTree
    private static final List<Integer> NUM_WORDS = 
            Arrays.asList(2000, 4000, 8000,
                16000, 20000, 24000);
    
    // File with words to check with contains.
    private static final String CONTAINS_FILE = "contains.txt";
    
    
    /**
     * Run trials against a collection of files containing random words
     * using all combinations of wordFiles, comps, and numWords
     * @throws Exception Most likely: File IO error.
     */
    public static void runWordTrials() throws Exception {
        BTreeTimer tmr = new BTreeTimer();
        tmr.setContainsFile(BTreeStressTest.CONTAINS_FILE);
        String header = "Comparator,File,Num Strings,Size (#)," + 
                "Build (ms),Iterate (ms),Contains (ms)";
        
        PrintWriter wordsOutput = new PrintWriter("words.csv");
        wordsOutput.println(header);
        
        for (String file : BTreeStressTest.WORD_FILES) {
            tmr.setFile(file);
            for (Comparator<String> comp : BTreeStressTest.COMPARATORS) {
                System.out.println(header);
                tmr.setComp(comp);
                for (Integer i : BTreeStressTest.NUM_WORDS) {
                    tmr.setNumWords(i);
                    tmr.runTrial();
                    wordsOutput.println(tmr.trialToString());
                    System.out.println(tmr.trialToString());
                }
                System.out.println();
                wordsOutput.println();
            }
        }
        wordsOutput.close();
    }
    
    
    /**
     * Run trials against a collection of files containing literature
     * using all combinations of literature words, and comps.
     * @throws Exception Most likely: File IO error.
     */
    public static void runLitTrials() throws Exception {
        BTreeTimer tmr = new BTreeTimer();
        tmr.setContainsFile(BTreeStressTest.CONTAINS_FILE);
        tmr.setNumWords(-1);
        String header = "Comparator,File,Size (#),Build (ms)," + 
                "Iterate (ms),Contains (ms)";
        
        PrintWriter litOutput = new PrintWriter("lit.csv");
        litOutput.println(header);
        
        for (String file : BTreeStressTest.LIT_FILES) {
            System.out.println(header);
            tmr.setFile(file);
            for (Comparator<String> comp : BTreeStressTest.COMPARATORS) {
                tmr.setComp(comp);
                tmr.runTrial();
                litOutput.println(tmr.trialToString());
                System.out.println(tmr.trialToString());
            }
            System.out.println();
            litOutput.println();
        }
        litOutput.close();
    }
    
    
    /**
     * MAIN: ENTRY POINT!
     * Run the Trials.
     * @param args Command line arguments
     */
    public static void main(String[] args) {
        try {
            BTreeStressTest.runWordTrials();
            BTreeStressTest.runLitTrials();
        }
        catch (Exception e) {
            System.out.println(e);
        }
    }
}
