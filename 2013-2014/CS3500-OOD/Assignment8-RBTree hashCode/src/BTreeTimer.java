/*
 * Name: Nicholas Jones Email: njhazelh@zimbra.husky.neu.edu Comments: n/a
 */
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Iterator;

/**
 * BTreeTimer is a class to control timing trials for BTree. After construction,
 * the user sets the values of BTreeTimer. Once all important values (see
 * runTrial) have been set, the user calls runTrial to run timings.
 * trialToString then gets the result.
 * 
 * @author Nick Jones
 * @version 1.0 - 10/17/2013
 */
public class BTreeTimer {
    private String             file         = "";
    private Integer            numWords     = 0;
    private Comparator<String> comp         = null;
    private String             containsFile = "";
    private BTree<String>      tree         = null;
    private long               buildTime    = -1;
    private long               containsTime = -1;
    private long               iterateTime  = -1;
    // private long wordsAdded = -1;
    private int                numIterated  = 0;
    
    /**
     * Time build, iterate, and contains. Record results in milliseconds
     * numWords, comp, containsFile, and file, must be set for this to work.
     */
    public void runTrial() {
        this.tree = BTree.binTree(this.comp);
        this.buildTime = this.timeBuild();
        // this.wordsAdded = this.tree.size();
        ArrayList<Number> ar = this.timeIterate();
        this.iterateTime = ((Long) ar.get(0));
        this.numIterated = (Integer) (ar.get(1));
        this.containsTime = this.timeContains();
    }
    
    /**
     * Set the Comparator that will be used to organize the BTree
     * 
     * @param comp The Comparator<String> to use.
     */
    public void setComp(Comparator<String> comp) {
        this.comp = comp;
    }
    
    /**
     * Set the file that will be used for the collection of words that will be
     * checked to see it the BTree contains them.
     * 
     * @param containsFile file path to read from.
     */
    public void setContainsFile(String containsFile) {
        this.containsFile = containsFile;
    }
    
    /**
     * Set the file that words should be read from into the BTree.
     * 
     * @param file file path to read from.
     */
    public void setFile(String file) {
        this.file = file;
    }
    
    /**
     * Set the number of words to read into the file. As BTree is implemented a
     * negative value or a value greater than the number of words in this.file
     * will read all words from file into the tree.
     * 
     * @param numWords words to read
     */
    public void setNumWords(Integer numWords) {
        this.numWords = numWords;
    }
    
    /**
     * How long does build take for this trial configuration?
     * 
     * @return The number of milliseconds it took to add numWords from file to
     *         an empty BTree.
     */
    private long timeBuild() {
        long start = System.currentTimeMillis();
        this.tree.build(new StringIterator(this.file), this.numWords);
        long stop = System.currentTimeMillis();
        return stop - start;
    }
    
    /**
     * How long does it take to run contains on all words in the file referenced
     * by containsFile Build must be run before this is called.
     * 
     * @return The number of milliseconds it took to run all words in
     *         containsFile through tree.contains(s);
     */
    private long timeContains() {
        long start = System.currentTimeMillis();
        for (String s : new StringIterator(this.containsFile)) {
            this.tree.contains(s);
        }
        long stop = System.currentTimeMillis();
        return stop - start;
    }
    
    /**
     * How long does it take to iterate through all words in the BTree? build
     * must be run before this is called.
     * 
     * @return An ArrayList where get(0) is the number of milliseconds it took
     *         to iterate, and get(1) is the number of words iterated though.
     */
    @SuppressWarnings("unchecked")
    private ArrayList<Number> timeIterate() {
        Iterator<String> it = this.tree.iterator();
        int num = 0;
        long start = System.currentTimeMillis();
        while (it.hasNext()) {
            num++;
            it.next();
        }
        long stop = System.currentTimeMillis();
        return new ArrayList<Number>(Arrays.asList(stop - start, num));
    }
    
    /**
     * Return a String with the trial results in CSV form.
     * 
     * @return file,comp,numWords if > 0,numAdded,bldTime,itrTime,containTime
     */
    public String trialToString() {
        return this.comp.toString() + "," + this.file + ","
                + (this.numWords > 0 ? this.numWords + "," : "")
                + this.numIterated + "," + this.buildTime + ","
                + this.iterateTime + "," + this.containsTime;
    }
}
