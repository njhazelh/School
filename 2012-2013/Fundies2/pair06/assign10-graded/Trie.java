/**
 * @author Nick Jones
 * @author Trevyn Langsford
 * @version %I%, %G%
 */

import java.util.ArrayList;
import tester.Tester;
import java.util.Arrays;

// A Trie<V> is one of
//  - new NoValue(Dict<Trie<V>>)
//  - new Node(V, Dict<Trie<V>>)
// and implements Dict<V>
//
// where the keys in the Dict are all single-character strings

interface Trie<V> extends Dict<V>{
	public Integer size();
	public ArrayList<String> matchPrefix(String prefix);
}

class NoValue<V> implements Trie<V>{
	private Dict<Trie<V>> charDict;
	
	/**
	 * THE CONTRUCTOR
	 * @param charDict A dictionary of Tries represented by single
	 * characters.
	 */
	public NoValue(Dict<Trie<V>> charDict){
		this.charDict=charDict;
	}
	
	/**
	 * Does this Trie contain the given key (not in its dictionary)
	 * @param key The key to search for.
	 * @return true if the key exists
	 */
	public Boolean hasKey(String key){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			
			if(charDict.hasKey(firstChar))
				return charDict.lookup(firstChar).hasKey(rest);
			else
				return false;
		}
		catch(IndexOutOfBoundsException e){
			return false;
		}
	}
	
	/**
	 * Find the value associated with the given key
	 * @param key The key to search for
	 * @return The value associated with the key.
	 */
	public V lookup(String key){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			
			if(charDict.hasKey(firstChar))
				return charDict.lookup(firstChar).lookup(rest);
			else
				throw new RuntimeException("No such key");
		}
		catch(IndexOutOfBoundsException e){
			throw new RuntimeException("No such key");
		}
	}
	
	/**
	 * Set the given key in this Trie to be the given value
	 * @param key The key to set
	 * @param value The value to set
	 * @return A new Trie with the key and value set.
	 */
	@Override
	public Trie<V> set(String key, V value){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			Trie<V> nextLevel;
			Dict<Trie<V>> newDict;
			
			if(charDict.hasKey(firstChar)){
				nextLevel = (Trie<V>)(charDict.lookup(firstChar)).set(rest,value);
				newDict = charDict.set(firstChar, nextLevel);	
			}
			else{
				nextLevel = new NoValue<V>(new MTDict<Trie<V>>()).set(rest, value);
				newDict = charDict.set(firstChar, nextLevel);
			}
			return new NoValue<V>(newDict);
		}
		catch(IndexOutOfBoundsException e){
			return new TrieNode<V>(value, charDict);
		}
	}
	
	/**
	 * Get a list of the keys in this Trie
	 * @return A list of the keys.
	 */
	public ArrayList<String> keys(){
		ArrayList<String> chars = charDict.keys();
		ArrayList<String> newKeys = new ArrayList<String>();
		
		for(String c: chars){
			ArrayList<String> nextLevel = charDict.lookup(c).keys();
			for(String s: nextLevel){
				newKeys.add(c+s);
			}
		}
		
		return newKeys;
	}
	
	/**
	 * Get a list of the values in the Trie
	 * @return A list of the values
	 */
	public ArrayList<V> values(){
		ArrayList<String> chars = charDict.keys();
		ArrayList<V> ret = new ArrayList<V>();
		
		for(String c: chars)
			ret.addAll(charDict.lookup(c).values());
		
		return ret;
	}
	
	/**
	 * How many values are in the Trie
	 * @return The number of values.
	 */
	public Integer size(){
		Integer sum = 0;
		
		for(Trie<V> t: charDict.values())
			sum+=t.size();
		
		return sum;
	}

	/**
	 * Find all keys that start with the given prefix
	 * @param prefix The prefix to search for
	 * @return A list of all keys in the Trie that start with the prefix.
	 */
	public ArrayList<String> matchPrefix(String prefix){
		if(prefix.length()>0){
			String firstChar = prefix.substring(0,1);
			String rest = prefix.substring(1);
			
			if(charDict.hasKey(firstChar)){
				ArrayList<String> keys = charDict.lookup(firstChar).matchPrefix(rest);
				for(int i=0; i<keys.size(); i++)
					keys.set(i, firstChar+keys.get(i));
				return keys;
			}
			else
				return new ArrayList<String>();
		}
		else{return keys();}
	}
}

// TrieNode not Node because Node already exists
class TrieNode<V> implements Trie<V>{
	private V value;
	private Dict<Trie<V>> charDict;
	
	/**
	 * THE CONSTRUCTOR
	 * @param value The value this node should hold
	 * @param dict The dictionary of Tries after this
	 */
	public TrieNode(V value, Dict<Trie<V>> dict){
		this.value=value;
		this.charDict=dict;
	}
	
	/**
	 * Does this Trie contain the given key (not in its dictionary)
	 * @param key The key to search for.
	 * @return true if the key exists
	 */
	public Boolean hasKey(String key){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			
			if(charDict.hasKey(firstChar))
				return charDict.lookup(firstChar).hasKey(rest);
			else
				return false;
		}
		catch(IndexOutOfBoundsException e){
			return true;
		}
	}
	
	/**
	 * Find the value associated with the given key
	 * @param key The key to search for
	 * @return The value associated with the key.
	 */
	public V lookup(String key){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			
			if(charDict.hasKey(firstChar))
				return charDict.lookup(firstChar).lookup(rest);
			else
				throw new RuntimeException("No such key");
		}
		catch(IndexOutOfBoundsException e){
			return value;
		}
	}
	
	/**
	 * Set the given key in this Trie to be the given value
	 * @param key The key to set
	 * @param value The value to set
	 * @return A new Trie with the key and value set.
	 */
	@Override
	public TrieNode<V> set(String key, V value){
		try{
			String firstChar = key.substring(0,1);
			String rest = key.substring(1);
			Trie<V> nextLevel;
			Dict<Trie<V>> newDict;
			
			if(charDict.hasKey(firstChar)){
				nextLevel = (Trie<V>)(charDict.lookup(firstChar)).set(rest,value);
				newDict = charDict.set(firstChar, nextLevel);	
			}
			else{
				nextLevel = new NoValue<V>(new MTDict<Trie<V>>()).set(rest, value);
				newDict = charDict.set(firstChar, nextLevel);
			}
			return new TrieNode<V>(this.value,newDict);
		}
		catch(IndexOutOfBoundsException e){
			return new TrieNode<V>(value, charDict);
		}
	}
	
	/**
	 * Get a list of the keys in this Trie
	 * @return A list of the keys.
	 */
	public ArrayList<String> keys(){
		ArrayList<String> chars = charDict.keys();
		ArrayList<String> newKeys = new ArrayList<String>(Arrays.asList(""));
		
		for(String c: chars){
			ArrayList<String> nextLevel = charDict.lookup(c).keys();
			for(String s: nextLevel){
				newKeys.add(c+s);
			}
		}
		
		return newKeys;
	}
	
	/**
	 * Get a list of the values in the Trie
	 * @return A list of the values
	 */
	public ArrayList<V> values(){
		ArrayList<V> ret = new ArrayList<V>();
		
		for(Trie<V> t: charDict.values())
			ret.addAll(t.values());
		
		ret.add(value);
		
		return ret;
	}
	
	/**
	 * How many values are in the Trie
	 * @return The number of values.
	 */
	public Integer size(){
		Integer sum = 0;
		
		for(Trie<V> t: charDict.values())
			sum+=t.size();
		
		return ++sum;
	}
	
	/**
	 * Find all keys that start with the given prefix
	 * @param prefix The prefix to search for
	 * @return A list of all keys in the Trie that start with the prefix.
	 */
	public ArrayList<String> matchPrefix(String prefix){
		if(prefix.length()>0){
			String firstChar = prefix.substring(0,1);
			String rest = prefix.substring(1);
			
			if(charDict.hasKey(firstChar)){
				ArrayList<String> keys = charDict.lookup(firstChar).matchPrefix(rest);
				for(int i=0; i<keys.size(); i++)
					keys.set(i, firstChar+keys.get(i));
				return keys;
			}
			else
				return new ArrayList<String>();
		}
		else{return keys();}
	}
}

class TrieExamples {
	public Trie<Integer> emptyTrie = new NoValue<Integer>(new MTDict<Trie<Integer>>());
	public Trie<Integer> exampleTrie = (Trie<Integer>)emptyTrie.set("a", 20)
																.set("ape", 3)
																.set("api", 30)
																.set("ace", 1)
																.set("an", 7);
 
	public boolean testHasKey(Tester t) {
		return 	t.checkExpect(exampleTrie.hasKey("api"), true) 	&&
				t.checkExpect(exampleTrie.hasKey("a"),true) 	&&
				t.checkExpect(exampleTrie.hasKey("b"),false)	&&
				t.checkExpect(exampleTrie.hasKey("buffalo"),false);
	}
	
	public boolean testLookup(Tester t){
		return 	t.checkExpect(exampleTrie.lookup("api"),30) &&
				t.checkExpect(exampleTrie.lookup("ace"),1);
	}
	
	public boolean testSet(Tester t){
		return 	t.checkExpect(emptyTrie.set("A", 10).values(),
					new ArrayList<Integer>(Arrays.asList(10))) &&
				t.checkExpect(exampleTrie.set("A",10).values(),
					new ArrayList<Integer>(Arrays.asList(10,7,1,30,3,20)));
	}
	
	public boolean testValues(Tester t){
		return 	t.checkExpect(exampleTrie.values(),new ArrayList<Integer>(Arrays.asList(7,1,30,3,20))) &&
				t.checkExpect(emptyTrie.values(),new ArrayList<Integer>()) &&
				t.checkExpect(emptyTrie.set("",20).values(), new ArrayList<Integer>(Arrays.asList(20)));
	}
 
	public boolean testSize(Tester t) {
		Trie<Integer> newTrie = (Trie<Integer>)(exampleTrie.set("cat",12));
		
		return 	t.checkExpect(exampleTrie.size(), 5) 							&&
				t.checkExpect(newTrie.size(), 6)								&&
				t.checkExpect(((Trie<Integer>)(emptyTrie.set("",20))).size(),1) &&
    			t.checkExpect(emptyTrie.size(),0);
	}
	
	public boolean testKeys(Tester t){
		return	t.checkExpect(emptyTrie.keys(), new ArrayList<String>()) &&
				t.checkExpect(exampleTrie.keys(),
						new ArrayList<String>(Arrays.asList("a","an","ace","api","ape"))) &&
				t.checkExpect(exampleTrie.set("hello", 14).set("are",1).keys(),
						new ArrayList<String>(Arrays.asList("hello","a","are","an","ace","api","ape")));
	}
	
	public boolean testMatchPrefix(Tester t){
		return 	t.checkExpect(emptyTrie.matchPrefix(""), new ArrayList<String>()) &&
				t.checkExpect(exampleTrie.matchPrefix("a"),
						new ArrayList<String>(Arrays.asList("a","an","ace","api","ape"))) &&
				t.checkExpect(exampleTrie.matchPrefix("ap"),
						new ArrayList<String>(Arrays.asList("api","ape"))) &&
				t.checkExpect(exampleTrie.matchPrefix("c"),
						new ArrayList<String>()) &&
				t.checkExpect(exampleTrie.matchPrefix("az"),
						new ArrayList<String>());
	}
	
	public static void main(String[] args){
		TrieExamples e = new TrieExamples();
		Tester.runReport(e, false, false);
	}
}