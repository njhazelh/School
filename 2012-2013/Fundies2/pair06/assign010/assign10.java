/**
 * @author Nick Jones
 * @author Trevyn Langsford
 * @version %I%, %G%
 */

import java.util.ArrayList;
import tester.Tester;
import java.util.Arrays;
import java.util.Comparator;
import tester.*;

///////////////////////////////////////////////////////////////////////////////
//  Employees  ////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


// An Employee is one of:
// new Worker(String name, int tasks);
// new boss(String name, String unit, int tasks, LoE peons)

// A List of Employees (LoE) is one of:
// new consloe Employee LoE;
// new mtloe;

interface LoE {
	int length();
	LoE append(LoE loe);
}

class Mtloe implements LoE {

	public int length() {
		return 0;
	}
	public LoE append(LoE loe) {
		return loe;
	}

}

class Consloe implements LoE{
	Employee first;
	LoE rest;

	Consloe(Employee first, LoE rest) {
		this.first = first;
		this.rest = rest;
	}
	public int length() {
		return 1 + this.rest.length();
	}
	public LoE append(LoE loe) {
		if (loe instanceof Mtloe) {
			return this;
		}
		else {
			return new Consloe(this.first, this.rest.append(loe));
		}
	}
}


interface Employee {
	String name = "";
	int tasks = 0;
	int countSubs();
	LoE fullUnit();
	boolean hasPeon(String name);

}

class Worker implements Employee {
	String name;
	int tasks;

	Worker(String name, int tasks) {
		this.name = name;
		this.tasks = tasks;
	}
	public int countSubs() {
		return 0;
	}
	public LoE fullUnit() {
		return new Mtloe();
	}
	public boolean hasPeon(String name) {
		return false;
	}

}

class Boss implements Employee {
	String name;
	String unit;
	int tasks;
	LoE peons;

	Boss(String name, String unit, int tasks, LoE peons) {
		this.name = name;
		this.unit = unit;
		this.tasks = tasks;
		this.peons = peons;
	}

	public int countSubs() {
		return countSubsHelp(this.peons);
	}

	private int countSubsHelp(LoE emps) {
		if (emps instanceof Mtloe) {
			return 0;
		} 
		else {
			return 1 + countSubsHelp(((Consloe) emps).rest);
		}
	}

	public boolean hasPeon(String name) {
		if (this.peons instanceof Mtloe) {
			return false;
		}
		else {
			return hasPeonHelp(name, this.peons);
		}
	}

	private boolean hasPeonHelp(String name, LoE peons) {
		if (peons instanceof Mtloe) {
			return false;
		}
		if (((Consloe) peons).first.name.equals(name)) {
			return true;
		}
		else {
			return hasPeonHelp(name, ((Consloe) peons).rest);
		}
	}

	public LoE fullUnit() {
		return fullUnitHelp(this.peons);
	}

	private LoE fullUnitHelp(LoE list) {
		if (list instanceof Mtloe) {
			return new Mtloe();
		}
		else {
			return new Consloe(((Consloe) list).first, new Mtloe())
			.append((((Consloe) list).first.fullUnit()
					.append(fullUnitHelp(((Consloe) list).rest))));
		}
	}
}



///////////////////////////////////////////////////////////////////////////////
//  Time  /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


// A Time is a new Time(in
// where Hours is an Integer in [0,24)
//   and  Mins is an Integer in [0,60)
class Time {
	int hours;
	int minutes;
	
	Time(int hours, int minutes) {
		this.hours = hours;
		this.minutes = minutes;
	}
	public int minutesFromMid() {
		return (60 * this.hours) + this.minutes;
	}
}

// An Event is a new Event(String name, Time start, Time end)
class Event {
	String name;
	Time start;
	Time end;
	
	Event(String name, Time start, Time end) {
		this.name = name;
		this.start = start;
		this.end = end;
	}
	public int duration() {
		return this.end.minutesFromMid() - this.start.minutesFromMid();
	}
	
	public boolean endBefore(Event e) {
		return e.start.minutesFromMid() > this.end.minutesFromMid();
	}

	public boolean overlap(Event e) {
		if ((this.end.minutesFromMid() < e.start.minutesFromMid())
				|| (e.end.minutesFromMid() < this.start.minutesFromMid())){
			return false;
		}
		else {
			return true;
		}
	}
}

// A Schedule is one of:
// - new NoEvent();
// - new ConsEvent(Event first, Schedule rest);

interface Schedule {
	boolean good();
	int scheduledTime();
	Schedule freeTime();
	Schedule append(Schedule s);
}

class NoEvent implements Schedule {
	
	public boolean good() {
		return true;
	}
	public int scheduledTime() {
		return 0;
	}
	public Schedule freeTime() {
		return new ConsEvent(new Event("Free Time!",
				new Time(0, 0), new Time(23, 59)), new NoEvent());	
	}
	public Schedule append(Schedule s) {
		return s;
	}
}


class ConsEvent implements Schedule {
	Event first;
	Schedule rest;
	
	ConsEvent(Event first, Schedule rest) {
		this.first = first;
		this.rest = rest;
	}

	public boolean good() {
		if (this.rest instanceof NoEvent) {
			return true;
		}
		if (this.first.endBefore(((ConsEvent) this.rest).first)) {
			return this.rest.good();
		}
		else {
			return false;
		}
	}
	public int scheduledTime() {
		return this.first.duration() + this.rest.scheduledTime();
	}
	public Schedule freeTime() {
		return freeTimeHelp(this, new NoEvent(), (new NoEvent()).freeTime());
	}
	private Schedule freeTimeHelp(Schedule sched, Schedule acc1, Schedule acc2) {
		if (sched instanceof NoEvent) {
			return acc1.append(acc2);
		}
		else {
			return freeTimeHelp(((ConsEvent) sched).rest,
					acc1.append(new ConsEvent(new Event("Free Time!",
							((ConsEvent) acc2).first.start,
							sub1Time(((ConsEvent) sched).first.start)),
							new NoEvent())),
							(new ConsEvent(new Event("Free Time!",
									add1Time(((ConsEvent) sched).first.end),
									((ConsEvent) acc2).first.end), new NoEvent())));
		}	
	}
	
	// INVARIANT: Only to be called on times other than 00:00
	private Time sub1Time(Time t) {
		if ((0 != t.hours) && (0 == t.minutes)) {
			return new Time(t.hours - 1, 59);
		}
		else {
			return new Time(t.hours, t.minutes - 1);
		}
	}
	private Time add1Time(Time t) {
		if ((t.hours != 23) && t.minutes == 59) {
			return new Time(t.hours + 1, 0);
		}
		else {
			return new Time(t.hours, t.minutes + 1);
			}
	}
	public Schedule append(Schedule s) {
		if (s instanceof NoEvent) {
			return s;
		}
		else {
			return new ConsEvent(this.first, this.rest.append(s));
		}
	}
}



///////////////////////////////////////////////////////////////////////////////
//  Organic Molecules  ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// An OrganicMolecule, or OM, is a:
// - new Carbon(Bonds);
// Note: There are no empty OM

		
// A Bonds is one of:
// - new ConsBond(AtomBond, Bonds);
// - new EmptyBond();

// A AtomBond is a:
// new AtomBond(int, Carbon)

// Butane is defined in the Examples class
interface Bonds {
	int countCarbons();
	int countBonds();
	boolean validCarbons();
	int countHydrogens();
}

class EmptyBond implements Bonds {
	public int countCarbons() {
		return 0;
	}
	public int countBonds() {
		return 0; 
	}
	public boolean validCarbons() {
		return true;
	}
	public int countHydrogens() {
		return 0;
	}
}

class ConsBond implements Bonds {
	AtomBond atomBond;
	Bonds rest;
	
	ConsBond(AtomBond atomBond, Bonds rest) {
		this.atomBond = atomBond;
		this.rest = rest;
	}
	
	public int countCarbons() {
		return this.atomBond.carbon.countCarbons() + this.rest.countCarbons();
		}
	public int countBonds() {
		return this.atomBond.bondType + this.rest.countBonds();
	}
	public boolean validCarbons() {
		return this.atomBond.carbon.validRemaining() && this.rest.validCarbons();
	}
	public int countHydrogens() {
		if (this.rest instanceof EmptyBond) {
			return this.atomBond.carbon.countRemainingHydrogens();
		}
		else {
			return (3 - this.atomBond.bondType) + 
					this.rest.countHydrogens();
		}
	}
}

class Carbon {
	Bonds bonds;
	
	Carbon(Bonds bonds){
		this.bonds = bonds;
	}
	
	public int countCarbons() {
		if (this.bonds instanceof EmptyBond) {
			return 1;
		}
		else {
			return 1 + this.bonds.countCarbons();
		}
	}
	public boolean valid() {
		return this.bonds.countBonds() == 4 && this.bonds.validCarbons();
	}
	public boolean validRemaining() {
		return (this.bonds instanceof EmptyBond) ||
				((this.bonds.countBonds() <= 3) && this.bonds.validCarbons());
	}

	public int countHydrogens() {
		if (this.bonds instanceof EmptyBond) {
			return 4;
		}
		else {
			return (4 - this.bonds.countBonds()) + this.bonds.countHydrogens();
		}
	}

	public int countRemainingHydrogens() {
		if (this.bonds instanceof EmptyBond) {
			return 3;
		}
		else {
			return (3 - this.bonds.countBonds()) + this.bonds.countHydrogens();
		}
	}	
	
}


class AtomBond {
	int bondType;
	Carbon carbon;
	
	AtomBond(int bondType, Carbon carbon) {
		this.bondType = bondType;
		this.carbon = carbon;
	}
}


///////////////////////////////////////////////////////////////////////////////
//  Binary Trees  /////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


//
//          +-------------+
//          |  IBT<T>     |<----------+
//          +-------------+<--------+ |
//            /_\   /_\             | |
//             |     |              | |
//+--------------+  +-----------+   | |
//| Node<T>      |  | Leaf<T>   |   | |
//+--------------+  +-----------+   | |
//| T val        |                  | |
//| IBT<T> left  |------------------+ |
//| IBT<T> right |--------------------+
//+--------------+

interface IBT<T> {
	<Y> Y accept(ListVisitor<T, Y> visitor);
}

class Node<T> implements IBT<T> {
	T val;
	IBT<T> left;
	IBT<T> right;

	Node(T val, IBT<T> left, IBT<T> right) {
		this.val = val;
		this.left = left;
		this.right = right;
	}

	public <Y> Y accept(ListVisitor<T, Y> visitor) {
		return visitor.visitNode(this.val, this.left, this.right);
	}

}

class Leaf<T> implements IBT<T> {

	Leaf() {}

	public <Y> Y accept(ListVisitor<T, Y> visitor) {
		return visitor.visitLeaf();
	}
}

///////////////////////////////////////////////////////////////////////////////
//  ListVisitors  /////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

interface ListVisitor<T, Y> {
	Y visitLeaf();	
	Y visitNode(T val, IBT<T> left, IBT<T> right);
}

//Does not account for the case when the right branch of the
//tree goes more left than the left branch.
class LeftMost<T> implements ListVisitor<T, T> {
	T acc;

	public T visitLeaf() {
		throw new RuntimeException("No leftmost value");
	}

	public T visitNode(T val, IBT<T> left, IBT<T> right) {
		acc = val;
		if (left instanceof Leaf) {
			return this.acc;
		}
		else {
			return left.accept(this);
		}
	}
}


//Does not account for the case when the left branch of the
//tree goes more right than the right branch.
class RightMost<T> implements ListVisitor<T, T> {
	T acc;

	public T visitLeaf() {
		throw new RuntimeException("No leftmost value");
	}

	public T visitNode(T val, IBT<T> left, IBT<T> right) {
		acc = val;
		if (right instanceof Leaf) {
			return this.acc;
		}
		else {
			return right.accept(this);
		}
	}
}

/*
//Produces a negative integer if t1 is "less than" t2.
//Produces a positive integer if t1 is "greater than" t2.
//Produces zero if t1 is "equal to" t2.
int compare(T t1, T t2);
 */


///////////////////////////////////////////////////////////////////////////////
//  Runners  //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//Represents a runner with name, age (in years), bib number, and time
//(in minutes).
class Runner {
	String name;
	Integer age;
	Integer bib;
	Integer time;
	Runner(String name, Integer age, Integer bib, Integer time) {
		this.name = name;
		this.age = age;
		this.bib = bib;
		this.time = time;
	}
}

///////////////////////////////////////////////////////////////////////////////
//  Comparators  //////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class CompareAge implements Comparator<Runner> {

	public int compare(Runner r1, Runner r2) {
		if (r1.age < r2.age) {
			return -1;
		}
		if (r1.age > r2.age) {
			return 1;
		}
		else {return 0;}
	}
}

class IsSorted<T> implements ListVisitor<T, Boolean> {
	Comparator<T> comp;

	IsSorted(Comparator<T> comp) {
		this.comp = comp;
	}

	public Boolean visitLeaf() {
		return true;
	}

	public Boolean visitNode(T val, IBT<T> left, IBT<T> right) {
		if (left instanceof Leaf && right instanceof Leaf){
			return true;
		}
		if (left instanceof Leaf || right instanceof Leaf) {
			return false;
		}
		else {
			return (0 > comp.compare(((Node<T>) left).val, ((Node<T>) right).val))
					&& left.accept(this) && right.accept(this);
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
//  Binary Search Trees  //////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*
+-----------+
| IBST<T>   |
+-----------+
    /_\
     |
+--------------------+
| BST<T>             |
+--------------------+
| Comparator<T> comp |
| IBT<T> bt          |
+--------------------+
 */

interface IBST<T> {

	// Insert given element into this binary search tree.
	// (The resulting tree must be sorted.)
	IBST<T> insert(T elem);

	// Get the smallest element in this binary search tree.
	// (Raise a run-time exception if there is no such element.)
	T min();

	// Get the largest element in this binary search tree.
	// (Raise a run-time exception if there is no such element.)
	T max();

}

class BST<T> implements IBST<T> {
	Comparator<T> comp;
	IBT<T> bt;

	BST(Comparator<T> comp, IBT<T> bt) {
		this.comp = comp;
		this.bt = bt;
	}

	public T min() {
		return this.bt.accept(new LeftMost<T>());
	}
	public T max() {
		return this.bt.accept(new RightMost<T>());
	}

	public IBST<T> insert(T elem) {
		if (this.bt instanceof Leaf) {
			return new BST<T>(this.comp,
					new Node<T>(elem, new Leaf<T>(), new Leaf<T>()));
		}
		else {
			return new BST<T>(this.comp, this.insertHelp(this.bt, elem));
		}
	}

	private IBT<T> insertHelp(IBT<T> bt, T elem) {
		if (bt instanceof Leaf) {
			return new Node<T>(elem, new Leaf<T>(), new Leaf<T>());
		}
		if (this.comp.compare(elem, ((Node<T>) bt).val) < 0) {
			return new Node<T>(((Node<T>) bt).val,
					this.insertHelp(((Node<T>) bt).left, elem),
					((Node<T>) bt).right);
		}
		//if (this.comp.compare(elem, ((Node<T>) bt).val) >= 0) {
		else {return new Node<T>(((Node<T>) bt).val,
				((Node<T>) bt).left,
				this.insertHelp(((Node<T>) bt).right, elem));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//  Examples/Tests  ///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class Examples {
	IBT<Integer> intibt = new Node<Integer>(1, 
			new Node<Integer>(2, new Leaf<Integer>(), new Leaf<Integer>()),
			new Node<Integer>(3, new Leaf<Integer>(), new Leaf<Integer>()));
	void testDirMost(Tester t) {
		t.checkExpect(intibt.accept(new LeftMost<Integer>()), 2);
		t.checkExpect(intibt.accept(new RightMost<Integer>()), 3);
	}

	Runner run1 = new Runner("Finn", 13, 1, 500);
	Runner run2 = new Runner("Jake", 17, 2, 520);
	Runner run3 = new Runner("Marceline", 19, 3, 510);
	Runner run4 = new Runner("Bubblegum", 15, 4, 495);
	Runner run5 = new Runner("Ice King", 32, 5, 700);

	IBT<Runner> runibt_unsort = new Node<Runner>(run1, 
			new Node<Runner>(run2, new Leaf<Runner>(), new Leaf<Runner>()),
			new Node<Runner>(run3, new Leaf<Runner>(), new Leaf<Runner>()));

	IBT<Runner> runibt_sort = new Node<Runner>(run2, 
			new Node<Runner>(run1, new Leaf<Runner>(), new Leaf<Runner>()),
			new Node<Runner>(run3, new Leaf<Runner>(), new Leaf<Runner>()));
	void testIsSorted(Tester t) {
		t.checkExpect(runibt_unsort.accept
				(new IsSorted<Runner>(new CompareAge())), false);
		t.checkExpect(runibt_sort.accept
				(new IsSorted<Runner>(new CompareAge())), true);
	}

	IBST<Runner> runbst = new BST<Runner>(new CompareAge(),
			new Node<Runner>(run2, 
					new Node<Runner>(run1, new Leaf<Runner>(), new Leaf<Runner>()),
					new Node<Runner>(run3, new Leaf<Runner>(), new Leaf<Runner>())));
	void testIBT(Tester t) {
		t.checkExpect(runbst.min(), run1);
		t.checkExpect(runbst.max(), run3);
		t.checkExpect(runbst.insert(run4), 
				new Node<Runner>(run2, 
						new Node<Runner>(run1, new Leaf<Runner>(),
								new Node<Runner>(run4, 
										new Leaf<Runner>(), new Leaf<Runner>())),
						new Node<Runner>(run3, new Leaf<Runner>(), new Leaf<Runner>())));
		t.checkExpect(runbst.insert(run5),
				new Node<Runner>(run2, 
						new Node<Runner>(run1, new Leaf<Runner>(), new Leaf<Runner>()),
						new Node<Runner>(run3, new Leaf<Runner>(), 
								new Node<Runner>(run5, 
										new Leaf<Runner>(), new Leaf<Runner>()))));
	}

	Worker hank = new Worker("Hank", 3);
	Worker bill = new Worker("Bill", 1);
	Worker kevin = new Worker("Kevin", 2);
	Boss frank = new Boss("Frank", "Facilities", 5,
			new Consloe(hank, new Mtloe()));
	Consloe steve_peons = new Consloe(bill, 
			new Consloe(frank, new Consloe(kevin, new Mtloe())));
	Boss steve = new Boss("Steve", "Accounting", 4, steve_peons);
	Mtloe mt_loe = new Mtloe();
	
	
	void testLOE(Tester t) {
		
		t.checkExpect(hank.countSubs(), 0);
		t.checkExpect(steve.countSubs(), 4);
		t.checkExpect(kevin.fullUnit(), new Mtloe());
		t.checkExpect(frank.fullUnit(), 
				new Consloe(hank, new Mtloe()));
	}
	
	Event breakfast = new Event("Breakfast,", 
			new Time(6, 30), new Time(7, 45));
	Event lunch = new Event("Lunch",
			new Time(12, 00), new Time(12, 30));
	Event dinner = new Event("Dinner", 
			new Time(17, 00), new Time(19, 45));
	
	Schedule meal_sched = new ConsEvent(breakfast,
			new ConsEvent(lunch, new ConsEvent(dinner, new NoEvent())));
	
	void testSchedule(Tester t) {
		t.checkExpect(meal_sched.good(), true);
		t.checkExpect(new ConsEvent(dinner, new ConsEvent(lunch, new NoEvent())),
				false);
		t.checkExpect(meal_sched.scheduledTime(), 270);
		//t.checkExpect(meal_sched.freeTime(), ...)
		t.checkExpect(new NoEvent().append(new ConsEvent(lunch, new NoEvent())),
				(new ConsEvent(lunch, new NoEvent())));
		t.checkExpect(new ConsEvent(lunch, new NoEvent()).
				append(new ConsEvent(dinner, new NoEvent())),
				new ConsEvent(lunch, new ConsEvent(dinner, new NoEvent())));
	}
	
	Carbon butane =
		    new Carbon(new ConsBond(new AtomBond(1, 
		    		new Carbon(new ConsBond(new AtomBond(1, 
		    				new Carbon(new ConsBond(new AtomBond(1, 
		    						new Carbon(new EmptyBond())), 
		    					new EmptyBond()))), 
		    				new EmptyBond()))), 
		    			new EmptyBond()));
	
	void testCarbon(Tester t) {
		t.checkExpect(butane.countCarbons(), 4);
		t.checkExpect(butane.countHydrogens(), 10);
		t.checkExpect(butane.valid(), true);
	}
}


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
