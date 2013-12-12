/** CS 3500 Assignment 4 */

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StreamTokenizer;
import java.io.StringReader;
import java.util.Iterator;

/**
 * StringIterator is a concrete class for iterating over all the words in a
 * StringBuffer or text file. At present a word is defined to be a maximal
 * contiguous sequence of English letters.
 */
public class StringIterator implements Iterator<String>, Iterable<String> {
    
    private StreamTokenizer tok;
    private String          eofError = "Tried to read past end of input.";
    
    /**
     * Given a Reader, returns a StreamTokenizer for that Reader that parses
     * words.
     */
    private static StreamTokenizer wordTokenizer(Reader in) {
        StreamTokenizer tok = new StreamTokenizer(in);
        tok.resetSyntax();
        // tok.lowerCaseMode (true);
        tok.wordChars('a', 'z');
        tok.wordChars('A', 'Z');
        tok.eolIsSignificant(false);
        return tok;
    }
    
    /** Create a StringIterator over the words in the given filename */
    public StringIterator(String filename) {
        try {
            FileInputStream fin = new FileInputStream(filename);
            InputStreamReader isr = new InputStreamReader(fin);
            BufferedReader br = new BufferedReader(isr);
            this.tok = StringIterator.wordTokenizer(br);
        }
        catch (FileNotFoundException e) {
            this.tok = StringIterator.wordTokenizer(new StringReader(""));
            System.err.println("StringIterator: File \"" + filename
                    + "\" not found.");
        }
    }
    
    /** Create a StringIterator over the words in the given StringBuffer */
    public StringIterator(StringBuffer sb) {
        this.tok = StringIterator
                .wordTokenizer(new StringReader(sb.toString()));
    }
    
    /** Is there another word in this StringIterator */
    @Override
    public boolean hasNext() {
        int tt = this.nextToken();
        while ((tt != StreamTokenizer.TT_EOF)
                && (tt != StreamTokenizer.TT_WORD)) {
            tt = this.nextToken();
        }
        // Pretend we haven't seen this token yet.
        this.tok.pushBack();
        return tt == StreamTokenizer.TT_WORD;
    }
    
    /** Make this iterator available for FOR-EACH loops */
    @Override
    public Iterator<String> iterator() {
        return this;
    }
    
    /** Return the next word in thei Iterator */
    @Override
    public String next() {
        int tt = this.nextToken();
        while ((tt != StreamTokenizer.TT_EOF)
                && (tt != StreamTokenizer.TT_WORD)) {
            tt = this.nextToken();
        }
        if (tt == StreamTokenizer.TT_WORD) {
            return this.tok.sval;
        }
        throw new RuntimeException(this.eofError);
    }
    
    /**
     * Behaves like tok.nextToken(), but catches any IOException and treats it
     * as though it were the end of input.
     */
    private int nextToken() {
        int tt = 0;
        try {
            tt = this.tok.nextToken();
        }
        catch (IOException e) {
            tt = StreamTokenizer.TT_EOF;
        }
        return tt;
    }
    
    /** Not implemented, not needed. */
    @Override
    public void remove() {
        throw new RuntimeException("StringIterator: Remove Not Possible");
    }
}
