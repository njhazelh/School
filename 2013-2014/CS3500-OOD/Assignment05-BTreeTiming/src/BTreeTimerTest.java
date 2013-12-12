/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */

import static org.junit.Assert.*;
import org.junit.Test;

/**
 * BTreeTimerTest runs Blackbox testing
 * on BTreeTimer
 * @author Nick Jones
 * @version 1.0 - 10/18/2013
 */
public class BTreeTimerTest {

    /**
     * Test Ability to run trials.
     */
    @Test
    public void testTrial() {
        BTreeTimer tmr = new BTreeTimer();
        tmr.setFile("iliad.txt");
        tmr.setNumWords(100000);
        tmr.setContainsFile("contains.txt");
        tmr.setComp(new StringByLex());
        tmr.runTrial();
        
        assertTrue("Trials run 1", tmr.trialToString() instanceof String);
        
        tmr.setComp(new StringByLength());
        tmr.runTrial();
        assertTrue("Trials run 2", tmr.trialToString() instanceof String);
    }
}
