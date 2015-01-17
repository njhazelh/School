/**
 * @author Nick Jones
 * @author Trevyn Langsford
 * @version %I%, %G%
 */

import java.util.ArrayList;
import java.util.Arrays;
import tester.Tester;

interface Dict<V>{
	public Boolean hasKey(String key);
	public V lookup(String key);
	public Dict<V> set(String key, V value);
	public ArrayList<String> keys();
	public ArrayList<V> values();
}

class MTDict<V> implements Dict<V>{
	/**
	 * Does the empty dictionary contain a key? NO!
	 * @param key	The key to search for
	 * @return False, it's empty, so no keys.
	 */
	public Boolean hasKey(String key){
		return false;
	}
	
	/**
	 * Lookup a key in an empty dictionary <u>Expect an Error</u>
	 * @param key	The key to look for
	 * @return Nothing, ever, other than a RuntimeException
	 */
	public V lookup(String key){
		throw new RuntimeException("Key not found!");
	}
	
	/**
	 * Add a key-value pair to the Dictionary
	 * @param key		The key to associate with the value.
	 * @param value		The value to associate with the key.
	 * @return A new Dictionary with the pair added.
	 * @see ListDict
	 */
	public ListDict<V> set(String key, V value){
		return new ListDict<V>(key, value, this);
	}
	
	/**
	 * Get the keys in this empty dictionary
	 * @return An empty list
	 */
	public ArrayList<String> keys(){
		return new ArrayList<String>();
	}
	
	/**
	 * Get the values in this list
	 * @return An empty list
	 */
	public ArrayList<V> values(){
		return new ArrayList<V>();
	}
}

class ListDict<V> implements Dict<V>{
	private String key;
	private V value;
	private Dict<V> rest;
	
	/**
	 * THE CONSTRUCTOR
	 * @param 	key		The key associated with the value being added
	 * @param 	value	The value associated with the key being added
	 * @param 	rest	The rest of the Dictionary previously created
	 */
	public ListDict(String key, V value, Dict<V> rest){
		this.key=key;
		this.value=value;
		this.rest=rest;
	}
	
	/**
	 * Is a particular key in the dictionary?
	 * @param 	key	The key to look for
	 * @return	If it's in the dict T, else F.
	 */
	public Boolean hasKey(String key){
		return 	this.key.equals(key) ||
				this.rest.hasKey(key);
	}
	
	/**
	 * Find the value associated with a particular key.
	 * @param 	key		The key to look for
	 * @return 	The value associated with the key.
	 */
	public V lookup(String key) throws RuntimeException{
		if(this.key.equals(key))
			return value;
		else
			return this.rest.lookup(key);
	}
	
	/**
	 * Add a new pair to the Dictionary or replace existing value
	 * @param	key		The key to associate with the value
	 * @param	value	The value to associate with the key
	 * @return	A new ListDict with the new pair.
	 */
	public ListDict<V> set(String key, V value){
		if(this.key.equals(key))
			return new ListDict<V>(key,value,rest);
		else
			return new ListDict<V>(this.key,this.value,rest.set(key,value));
	}
	
	/**
	 * Get the keys in this dictionary
	 * @return A list of Strings
	 */
	public ArrayList<String> keys(){
		ArrayList<String> restOfKeys = rest.keys();
		restOfKeys.add(key);
		
		return restOfKeys;
	}
	
	/**
	 * Get the values in this list
	 * @return A list of the values in this Dict
	 */
	public ArrayList<V> values(){
		ArrayList<V> restOfValues = rest.values();
		restOfValues.add(value);
		
		return restOfValues;
	}
}

class DictExamples{
	public MTDict<Integer> mt = new MTDict<Integer>();
	public ListDict<Integer> exampleDict = mt.set("a",1)
												.set("b",2)
												.set("c",3)
												.set("e",5);
	
	public boolean testHasKey(Tester t){
		return 	t.checkExpect(mt.hasKey("a"),false) &&
				t.checkExpect(exampleDict.hasKey("a"),true) &&
				t.checkExpect(exampleDict.hasKey("d"),false);
	}
	
	public boolean testLookup(Tester t){
		return 	t.checkExpect(exampleDict.lookup("a"),1) &&
				t.checkExpect(exampleDict.lookup("b"),2) &&
				t.checkExpect(exampleDict.lookup("e"),5) &&
				t.checkExpect(exampleDict.lookup("c"),3);
	}
	
	public boolean testSet(Tester t){
		Dict<Integer> d = exampleDict.set("qwerty", 1000);
		return t.checkExpect(d.lookup("qwerty"),1000);
	}
	
	public boolean testKeys(Tester t){
		return 	t.checkExpect(mt.keys(), new ArrayList<String>()) &&
				t.checkExpect(exampleDict.keys(),
						new ArrayList<String>(Arrays.asList("e","c","b","a")));
	}
	
	public boolean testValues(Tester t){
		return 	t.checkExpect(mt.values(), new ArrayList<Integer>()) &&
				t.checkExpect(exampleDict.values(),
						new ArrayList<Integer>(Arrays.asList(5,3,2,1)));
	}
	
	public static void main(String[] args){
		DictExamples e = new DictExamples();
		Tester.runReport(e, false, false);
	}
	
}



