import java.util.Arrays;
import java.util.*;
import java.io.FileWriter;
import java.io.PrintWriter;

public class BTreeTimingOld {
    
    public static BTree timeBuildToNum(String filename, Comparator<String> comp,
            Integer num, PrintWriter out) {
        System.out.println("buildNum");
        BTree tree = BTree.binTree(comp);
        
        long start = System.currentTimeMillis();
        tree.build(new StringIterator(filename), num);
        long end = System.currentTimeMillis();
        
        out.print(tree.size() + ",");
        out.print(end - start);
        out.print(",");
        
        return tree;
    }
    
    public static BTree timeBuildAll(String filename, Comparator<String> comp,
            PrintWriter out) {
        System.out.println("buildAll");
        BTree tree = BTree.binTree(comp);
        
        long start = System.currentTimeMillis();
        tree.build(new StringIterator(filename));
        long end = System.currentTimeMillis();
        
        out.print(tree.size() + ",");
        out.print(end - start);
        out.print(",");
        
        return tree;
    }
    
    public static void timeIteration(Iterator<String> it, PrintWriter out) {
        System.out.println("iteration");
        long start = System.currentTimeMillis();
        while (it.hasNext()) {
            it.next();
        }
        long end = System.currentTimeMillis();
        
        out.print(end - start);
        out.print(",");
    }
    
    public static void timeContains(BTree tree, PrintWriter out) {
        System.out.println("contains");
        long start = System.currentTimeMillis();
        for(String s : new StringIterator("contains.txt")) {
            tree.contains(s);
        }
        long end = System.currentTimeMillis();

        out.print(end - start);
        out.print(",");
    }
    
    
    public static void runTrials() {
        List<String> wordFiles = Arrays.asList("lexicographically_ordered.txt", 
                "reverse_ordered.txt", 
                "prefix_ordered.txt", 
                "random_order.txt");
        List<String> literature = Arrays.asList("iliad.txt",
                "hippooath_DUPLICATES.txt");
        List<Comparator<String>> comps = Arrays.asList(new StringByLex(), 
                new StringReverseByLex(), 
                new StringWithOutPrefixByLex());
        List<Integer> numWords = Arrays.asList(2000, 4000, 8000,
                16000, 20000, 24000);
        
        
        // Word file trials.
        try {
            PrintWriter wordsOutput = new PrintWriter("words.csv");
            wordsOutput.print("Comparator,File,Num Strings,Size (#),");
            wordsOutput.println("Build (ms),Iterate (ms),Contains (ms)");
            
            for (String file : wordFiles) {
                for (Comparator<String> comp : comps) {
                    for (Integer i : numWords) {
                        System.out.print("Running:");
                        System.out.print(comp.toString() + ",");
                        System.out.print(file + ",");
                        System.out.println(i);
                        wordsOutput.print(comp.toString() + ",");
                        wordsOutput.print(file + ",");
                        wordsOutput.print(i + ",");
                        BTree tree  = timeBuildToNum(file, comp, i, 
                                wordsOutput);
                        timeIteration(tree.iterator(), wordsOutput);
                        timeContains(tree, wordsOutput);
                        wordsOutput.println();
                    }
                }
            }
            
            wordsOutput.flush();
            wordsOutput.close();
        }
        catch(Exception e) {
            System.out.println(e);
        }

        
        // Literature trials.
        try {
            PrintWriter litOutput = new PrintWriter(new FileWriter("lit.csv"));
            litOutput.print("Comparator,File,Size (#),Build (ms),");
            litOutput.println("Iterate (ms),Contains (ms)");
            
            for (String file : literature) {
                for (Comparator<String> comp : comps) {
                    System.out.print("Running:");
                    System.out.print(comp.toString() + ",");
                    System.out.println(file);
                    litOutput.print(comp.toString() + ",");
                    litOutput.print(file + ",");
                    BTree tree  = timeBuildAll(file, comp, litOutput);
                    timeIteration(tree.iterator(), litOutput);
                    timeContains(tree, litOutput);
                    litOutput.println();
                }
            }
            
            litOutput.flush();
            litOutput.close();
        }
        catch(Exception e) {
            System.out.println(e);
        }
    }
    
    public static void main(String[] args) {
        BTreeTimingOld.runTrials();
    }

}
