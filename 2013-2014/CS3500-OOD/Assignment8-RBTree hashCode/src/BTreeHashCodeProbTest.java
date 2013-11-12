import java.util.ArrayList;
import java.util.Random;
import org.junit.*;
import static org.junit.Assert.*;

/**
 * A test program to complete probability tests on the hashCode method of BTree
 * 
 * @author Jessica Young Schmidt
 * @version 2013-11-06
 * 
 */
public class BTreeHashCodeProbTest {

    /** random number generator, initialed by probabilisticTests() */
    Random rng;

    /** base for hash codes */
    int base = 0;

    /**
     * Probabilistic test for distribution of hash codes.
     */
    @Test
    public void hashCodeTest() {
        int numFailed = 0;
        numFailed = numFailed + probabilisticTests(400, 20);
        base = -2;
        numFailed = numFailed + probabilisticTests(400, 20);
        base = 412686306;
        numFailed = numFailed + probabilisticTests(400, 20);

        System.out.println("\nNum failed: " + numFailed);
        assertTrue("hashCode quality", numFailed <= 1);
    }

    /**
     * Initializes rng
     */
    private void initializeRNGrandomly() {
        rng = new Random(System.nanoTime());
    }

    /**
     * Generate n random pairs of unequal BTree<Integer> values. If k or more
     * have the same hash code, then report failure.
     * 
     * @param n
     *            number of random pairs
     * @param k
     *            number to report failure
     * @return 0 if sameHash <k, 1 otherwise
     */
    private int probabilisticTests(int n, int k) {
        System.out.println("probabilisticTests: " + n + ", " + k);
        initializeRNGrandomly();
        int sameHash = 0;
        int equalButDiffHashCode = 0;
        int i = 0;
        while (i < n) {
            BTree<Integer> b1 = randomBTree();
            BTree<Integer> b2 = randomBTree();
            // System.out.println("[" + b1 + "] [" + b2 + "]");
            if (!(b1.equals(b2))) {
                i = i + 1;
                if (b1.hashCode() == b2.hashCode()) {
                    System.out.println("Same hashCode but not equal: [" + b1
                            + "] [" + b2 + "]\n  hashCodes: " + b1.hashCode()
                            + ", " + b2.hashCode());
                    sameHash = sameHash + 1;
                }
            }
            else {
                // b1 and b2 are equal. Check that hashCodes are equal
                if (b1.hashCode() != b2.hashCode()) {
                    equalButDiffHashCode++;
                }
            }
        }
        System.out.println("Same Hash: " + sameHash + " / " + n
                + ". Pass hashCode quality: " + (sameHash < k));

        // assertTrue("hashCode quality", sameHash < k);
        assertTrue("equal hashCodes for equal BTrees",
                equalButDiffHashCode == 0);

        if (sameHash < k) {
            return 0;
        }
        else {
            return 1;
        }

    }

    /**
     * Returns a randomly selected BTree<Integer>
     */
    private BTree<Integer> randomBTree() {
        // System.out.println("randomBTree");

        // First pick the size.
        double x = rng.nextDouble();
        double y = 0.5;
        int size = 0;
        while (y > x) {
            size = size + 1;
            y = y / 2.0;
        }
        BTree<Integer> b = BTree.binTree(new IntByVal());
        ArrayList<Integer> al = new ArrayList<Integer>();
        // System.out.println("size: " + size);
        while (al.size() < size) {
            al.add(randomInteger());
        }
        b.build(al);
        return b;
    }

    /**
     * Returns a randomly selected Integer.
     */
    private Integer randomInteger() {
        int h = base + rng.nextInt(5);
        return new Integer(h);
    }
}
