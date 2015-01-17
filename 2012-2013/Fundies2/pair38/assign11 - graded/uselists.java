import tester.*;

///////////////////////////////////////////////////////////////////////////////
//  ListVisitors  /////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

interface ListVisitor<X, Y> {
	Y visitEmpty();
	Y visitCons(X val, List<X> rest);
}

class Length<X> implements ListVisitor<X, Integer> {
	
	public Integer visitEmpty() {
		return 0;
	}
	
	public Integer visitCons(X val, List<X> rest) {
		return 1 + rest.accept(this);
	}
}


class Sum<X> implements ListVisitor<Integer, Integer> {
	
	public Integer visitEmpty() {
		return 0;
	}
	
	public Integer visitCons(Integer val, List<Integer> rest) {
		return val + rest.accept(this);
	}
}

class Reverse<X> implements ListVisitor<X, List<X>> {
	
	public SlowList<X> visitEmpty() {
		return new Empty<X>();
	}
	
	public SlowList<X> visitCons(X val, List<X> rest) {
		return rest.accept(new ReverseHelper<X>(new Empty<X>().cons(val)));
	}
}

class ReverseHelper<X> implements ListVisitor<X, SlowList<X>> {
	SlowList<X> acc;
	
	ReverseHelper(SlowList<X> acc) {
		this.acc = acc;
	}
	
	public SlowList<X> visitEmpty() {
		return this.acc;
	}
	
	public SlowList<X> visitCons(X val, List<X> rest) {
		acc = acc.cons(val);
		return rest.accept(new ReverseHelper<X>(acc));	
	}
}

///////////////////////////////////////////////////////////////////////////////
//  ListFuntions  /////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
interface Fun<X, Y> {
	// Applies the function to the given val.
	Y apply(X val);
}

class NumToString implements Fun<Integer, String> {
	
	NumToString() {}
	public String apply(Integer val) {
		return val.toString();
	}
}


///////////////////////////////////////////////////////////////////////////////
//  ListPredicates  ///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
interface Pred<X> {
	// Asks if the predicate holds on val
	Boolean ask(X val);
}

class ShortStringp implements Pred<String> {
	
	public Boolean ask(String val) {
		return val.length() < 5;
	}
}

///////////////////////////////////////////////////////////////////////////////
//  Filters  //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class Filter<X> implements ListVisitor<X, List<X>>{
	Pred<X> question;
	
	Filter(Pred<X> question) {
		this.question = question;
	}
	
	public List<X> visitEmpty() {
		return new Empty<X>();
	}
	public List<X> visitCons(X val, List<X> rest) {
		if (this.question.ask(val)) {
			return rest.accept(this).cons(val);
		}
		else {
			return rest.accept(this);
		}
	}
	
	public List<X> foldEmpty() {
		return new Empty<X>();
	}
	public List<X> foldCons(X val, List<X> rest) {
		if (this.question.ask(val)) {
			return rest.cons(val);
		}
		else {
			return rest;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//  Maps  /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class Map<X, Y> implements ListVisitor<X, List<Y>> {
	Fun<X, Y> fun;
	
	Map(Fun<X, Y> fun) {
		this.fun = fun;
	}
	
	public List<Y> visitEmpty() {
		return new Empty<Y>();
	}
	
	public List<Y> visitCons(X val, List<X> rest) {
		return rest.accept(this).cons(this.fun.apply(val));
	}
	
	public List<Y> foldEmpty() {
		return new Empty<Y>();
	}
	
	public List<Y> foldCons(X val, List<Y> rest) {
		return rest.cons(fun.apply(val));
	}
}

///////////////////////////////////////////////////////////////////////////////
//  Folds  ////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
interface ListFold<X, Y> {
	Y foldEmpty();
	Y foldCons(X n, Y m);
}

class ProdFold implements ListFold<Integer, Integer> {
	
	public Integer foldEmpty() {
		return 1;
	}
	
	public Integer foldCons(Integer n, Integer m) {
		return n * m;
	}
}

class StringAppendFold implements ListFold<String, String> {
	
	public String foldEmpty() {
		return "";
	}
	
	public String foldCons(String n, String m) {
		return n + m;
	}
}

class ListRef<X> implements ListVisitor<X, X> {
	Integer pos;
	
	ListRef(Integer pos) {
		this.pos = pos;
	}
	
	public X visitEmpty() {
		throw new RuntimeException("i cannot be greater than the length of the list");
	}
	
	public X visitCons(X val, List<X> rest) {
		if (this.pos == 0) {
			return val;
		}
		else {
			return rest.accept(new ListRef<X>(this.pos - 1));
		}
	}

}


///////////////////////////////////////////////////////////////////////////////
//  Lists  ////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

interface List<X> {
	// The length of the list
	Integer length();
	// The first element of non-empty list
	X first();
	// The rest of a non-empty list
	List<X> rest();
	// Adds the element to the beginning of the list
	List<X> cons(X elem);
	// Retrieves the ith element of the list.
	// i must be less than the length of the list.
	X listRef(Integer i);
	// Accepts ListVisitors
	<Y> Y accept(ListVisitor<X, Y> visitor);
	// Accepts Folds
	<Y> Y fold(ListFold<X, Y> folder);
}


///////////////////////////////////////////////////////////////////////////////
//  SlowLists  ////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

interface SlowList<X> extends List<X> {
	Integer length();
	X first();
	SlowList<X> rest();
	SlowList<X> cons(X elem);
	X listRef(Integer i);
	<Y> Y accept(ListVisitor<X, Y> visitor);

}

class Empty<X> implements SlowList<X> {

	Empty() {}

	public <Y> Y accept(ListVisitor<X, Y> visitor) {
		return visitor.visitEmpty();
	}
	
	public <Y> Y fold(ListFold<X, Y> folder) {
		return folder.foldEmpty();
	}

	public Integer length() {
		return 0;
	}

	public X first() {
		throw new RuntimeException("An empty list has no elements");
	}

	public SlowList<X> rest() {
		throw new RuntimeException("An empty list has no elements");
	}

	public SlowList<X> cons(X elem) {
		return new Cons<X>(elem, this);
	}

	public X listRef(Integer i) {
		throw new RuntimeException("An empty list has no elements");
	}
}

class Cons<X> implements SlowList<X> {
	X val;
	SlowList<X> rest;

	Cons(X val, SlowList<X> rest) {
		this.val = val;
		this.rest = rest;
	}

	public <Y> Y accept(ListVisitor<X, Y> visitor) {
		return visitor.visitCons(this.val, this.rest());
	}

	public <Y> Y fold(ListFold<X, Y> folder) {
		return folder.foldCons(this.first(), this.rest().fold(folder));
	}
	
	public Integer length() {
		return 1 + this.rest.length();
	}

	public X first() {
		return this.val;
	}

	public SlowList<X> rest() {
		return this.rest;
	}

	public SlowList<X> cons(X elem) {
		return new Cons<X>(elem, this);
	}

	public X listRef(Integer i) {
		if (i == 0) {
			return this.val;
		}
		else {
			return this.rest.listRef(i - 1);
		}
	}
}




///////////////////////////////////////////////////////////////////////////////
//  QuickLists  ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//A Binary Tree (BT) is a
//- new Node<X>(X val, Integer size, BT<X> left, BT<X> right)
//- new Leaf<X>(X val)

//A Forest is one of:
//- new ConsForest<X>(BT<X> bt, Forest<X> rest)
//- new NoForest<X>();

interface Forest<X> extends List<X> {
	Forest<X> cons(X elem);
	X first();
	Forest<X> rest();
	X listRef(Integer i);
	Integer length();
	Integer forestLength();
	<Y> Y accept(ListVisitor<X, Y> visitor);
}

interface BT<X> {
	Integer size();
	X listRef(Integer i);
	X val();

}

class Node<X> implements BT<X> {
	X val;
	Integer size;
	BT<X> left;
	BT<X> right;

	Node(X val, Integer size, BT<X> left, BT<X> right) {
		this.val = val;
		this.size = size;
		this.left = left;
		this.right = right;
	}

	public X val() {
		return this.val;
	}

	public Integer size() {
		return this.size;
	}

	public X listRef(Integer i) {
		if (i == 0) {
			return this.val;
		}
		if (i <= ((this.size - 1) / 2) ) {
			return this.left.listRef(i - 1);
		}
		else {
			return this.right.listRef((i - ((this.size - 1) / 2) - 1));
		}
	}
}

class Leaf<X> implements BT<X> {
	X val;

	Leaf(X val) {
		this.val = val;
	}

	public X val() {
		return this.val;
	}

	public Integer size() {
		return 1;
	}

	public X listRef(Integer i) {
		if (i == 0) {
			return this.val;
		}
		else {
			throw new RuntimeException("i was longer than the length of the list");
		}
	}
}

class NoForest<X> implements Forest<X> {
	
	NoForest() {}
	
	public <Y> Y accept(ListVisitor<X, Y> visitor) {
		return visitor.visitEmpty();
	}
	
	public <Y> Y fold(ListFold<X, Y> folder) {
		return folder.foldEmpty();
	}
		
	public Forest<X> cons(X elem) {
		return new ConsForest<X>(new Leaf<X>(elem), this);
	}

	public Integer length() {
		return 0;
	}

	public X first() {
		throw new RuntimeException("An empty list has no first");
	}

	public Forest<X> rest() {
		throw new RuntimeException("an empty list has no rest");
	}

	public X listRef(Integer i) {
		throw new RuntimeException("an empty list has no elements");
	}

	public Integer forestLength() {
		return 0;
	}
}


class ConsForest<X> implements Forest<X> {
	BT<X> bt;
	Forest<X> rest;

	ConsForest(BT<X> bt, Forest<X> rest) {
		this.bt = bt;
		this.rest = rest;
	}
	
	public <Y> Y fold(ListFold<X, Y> folder) {
		return folder.foldCons(this.first(), this.rest().fold(folder));
	}
	
	public <Y> Y accept(ListVisitor<X, Y> visitor) {
		return visitor.visitCons(this.bt.val(), this.rest());
	}

	public Integer length() {
		return this.bt.size() + this.rest.length();
	}

	public X first() {
		return this.bt.val();
	}

	public Forest<X> rest() {
		if (this.bt.size() == 1) {
			return this.rest;
		}
		else {
			return new ConsForest<X>(((Node<X>) this.bt).left,
					new ConsForest<X>(((Node<X>) this.bt).right, this.rest));
		}
	}

	public X listRef(Integer i) {
		if (i < this.bt.size()) {
			return this.bt.listRef(i);
		}
		else {
			return this.rest.listRef((i - 1) - (this.bt.size() - 1));
		}
	}

	public Integer forestLength() {
		return 1 + this.rest.forestLength();
	}

	public Forest<X> cons(X elem) {
		if (this.length() == 1) {
			return new ConsForest<X>(new Leaf<X>(elem), this);
		}
		if (this.length() == 2) {
			return new ConsForest<X>(new Node<X>(elem, 3, this.bt, 
					((ConsForest<X>) this.rest).bt),
					new NoForest<X>());
		}
		if (this.forestLength() >= 2 && this.bt.size() == ((ConsForest<X>) this.rest).bt.size()) {
			return new ConsForest<X>(new Node<X>(elem, 1 + this.bt.size() + ((ConsForest<X>) this.rest).bt.size(),
					this.bt, ((ConsForest<X>) this.rest).bt), new NoForest<X>());
		}
		else {
			return new ConsForest<X>(new Leaf<X>(elem), this);
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
//  Examples  /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class Examples {

	
	//SlowLists
//	SlowList s_empty = new Empty();
	SlowList<Integer> s_emptyi = new Empty<Integer>();
	SlowList<String> s_emptys = new Empty<String>();
	
	
	
	// Quicklists
	BT<String> leaf = new Leaf<String>("a");
	BT<String> small_tree = new Node<String>("c", 3, new Leaf<String>("b"),
			new Leaf<String>("a"));
	BT<String> mid_tree = new Node<String>("g", 7, 
			new Node<String>(
					"f", 3, new Leaf<String>("e"), new Leaf<String>("d")),
					new Node<String>(
							"c", 3, new Leaf<String>("b"), new Leaf<String>("a")));
	BT<String> large_tree = new Node<String>("z", 15, mid_tree, mid_tree);

//	Forest q_empty = new NoForest();
	Forest<String> q_emptys = new NoForest<String>();
	Forest<Integer> q_emptyi= new NoForest<Integer>();
	Forest<String> small_forest = new ConsForest<String>(small_tree, 
			new NoForest<String>());
	Forest<String> mid_forest = new ConsForest<String>(small_tree,
			new ConsForest<String>(mid_tree, new NoForest<String>()));
	Forest<String> large_forest = new ConsForest<String>(small_tree,
			new ConsForest<String>(mid_tree, 
					new ConsForest<String>(large_tree, new NoForest<String>())));

	Forest<String> ls = q_emptys.cons("a").cons("b").cons("c").cons("d").cons("e");


	void testTrees(Tester t) {
		t.checkExpect(small_tree.listRef(0), "c");
		t.checkExpect(small_tree.listRef(1), "b");
		t.checkExpect(small_tree.listRef(2), "a");
		t.checkExpect(mid_tree.listRef(4), "c");
		t.checkExpect(mid_tree.listRef(6), "a");

		t.checkExpect(leaf.size(), 1);
		t.checkExpect(leaf.listRef(0), "a");		
	}

	void testForests(Tester t) {
		t.checkExpect(small_forest.length(), 3);
		t.checkExpect(mid_forest.length(), 10);
		t.checkExpect(q_emptyi.length(), 0);
		t.checkExpect(q_emptyi.forestLength(), 0);
		t.checkExpect(q_emptys.cons("a"),
				new ConsForest<String>(leaf, q_emptys));

		t.checkExpect(mid_forest.listRef(0), "c");
		t.checkExpect(mid_forest.listRef(1), "b");
		t.checkExpect(mid_forest.listRef(2), "a");
		t.checkExpect(mid_forest.listRef(3), "g");
		t.checkExpect(mid_forest.listRef(4), "f");
		t.checkExpect(mid_forest.listRef(6), "d");

		t.checkExpect(small_forest.forestLength(), 1);
		t.checkExpect(mid_forest.forestLength(), 2);
		t.checkExpect(large_forest.forestLength(), 3);

		t.checkExpect(small_forest.first(), "c");

		t.checkExpect(small_forest.rest(),
				new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"),
								q_emptys)));
		t.checkExpect(mid_forest.rest(), 
				new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"),
								new ConsForest<String>(mid_tree, 
										q_emptys))));
		t.checkExpect(new ConsForest<String>(leaf, new NoForest<String>()).rest(), 
				new NoForest<String>());

		t.checkExpect(new ConsForest<String>(new Leaf<String>("a"), q_emptys).cons("b"),
				new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"), q_emptys)));
		t.checkExpect(new ConsForest<String>(new Leaf<String>("b"),
				new ConsForest<String>(new Leaf<String>("a"), q_emptys)).cons("c"),
				small_forest);
		t.checkExpect(new ConsForest<String>(small_tree, new ConsForest<String>(small_tree, q_emptys)).cons("z"),
				new ConsForest<String>(new Node<String>("z", 7, small_tree, small_tree), q_emptys));
		t.checkExpect(mid_forest.cons("a"),
				new ConsForest<String>(leaf, mid_forest));	
	}

	void testls(Tester t) {
		t.checkExpect(ls.length(), 5);
		t.checkExpect(ls.first(), "e");
		t.checkExpect(ls.rest().first(), "d");
		t.checkExpect(ls.rest().rest().first(), "c");
		t.checkExpect(ls.rest().rest().rest().first(), "b");
		t.checkExpect(ls.rest().rest().rest().rest().first(), "a");

		t.checkExpect(ls.listRef(0), "e");
		t.checkExpect(ls.listRef(1), "d");
		t.checkExpect(ls.listRef(2), "c");
		t.checkExpect(ls.listRef(3), "b");
		t.checkExpect(ls.listRef(4), "a");
	}
	
	//ListVisitors
	ListVisitor<String, Integer> len = new Length<String>();
	ListVisitor<Integer, Integer> sum = new Sum<Integer>();
	ListVisitor<String, List<String>> rev = new Reverse<String>();
	
	void testListVisitors(Tester t) {
		t.checkExpect(s_emptys.accept(len), 0);
		t.checkExpect(q_emptys.accept(len), 0);
		t.checkExpect(s_emptys.cons("c").cons("b").cons("c").accept(len), 3);
		t.checkExpect(q_emptys.cons("c").cons("b").cons("a").accept(len), 3);
		
		t.checkExpect(s_emptyi.accept(sum), 0);
		t.checkExpect(q_emptyi.accept(sum), 0);
		t.checkExpect(s_emptyi.cons(3).cons(4).cons(7).accept(sum), 14);
		t.checkExpect(q_emptyi.cons(3).cons(4).cons(7).accept(sum), 14);
		
		t.checkExpect(s_emptys.accept(rev), s_emptys);
		t.checkExpect(q_emptys.accept(rev), s_emptys);
		t.checkExpect(s_emptys.cons("a").cons("b").cons("c").accept(rev),
				s_emptys.cons("c").cons("b").cons("a"));
		t.checkExpect(q_emptys.cons("a").cons("b").cons("c").accept(rev),
				s_emptys.cons("c").cons("b").cons("a"));
		
	}

	//Funcs & Preds
	void testFuncsPreds(Tester t) {
		t.checkExpect(new NumToString().apply(5), "5");
		t.checkExpect(new ShortStringp().ask("hi"), true);
		t.checkExpect(new ShortStringp().ask("hello"), false);
	}

	//Filters
	Filter<String> ss_filter = new Filter<String>(new ShortStringp());
	
	void testFilters(Tester t) {
		t.checkExpect(q_emptys.cons("Hi").cons("Hello World").cons("LOL").accept(ss_filter)
				,s_emptys.cons("Hi").cons("LOL"));
	}
	
	//Maps
	Map<Integer, String> numstring = new Map<Integer, String>(new NumToString());
	
	void testMaps(Tester t) {
		t.checkExpect(q_emptyi.cons(5).cons(3).cons(1).accept(numstring),
			s_emptys.cons("5").cons("3").cons("1"));
	}
	
	//Folds
	void testFolds(Tester t) {
		t.checkExpect(q_emptyi.cons(5).cons(3).cons(1).fold(new ProdFold()), 15);
		t.checkExpect(q_emptys.cons("a").cons("b").cons("c").fold(new StringAppendFold()),
				"cba");
		t.checkExpect(s_emptys.cons("a").cons("b").cons("c").accept(new ListRef<String>(1)), "b");
	}	
}

// ListRef cannot be written as a fold. In the fold, the rest of the list has
// already been computed into a single element. The fold interface was more
// elegant for map because the rest of the list had already been filtered,
// so we only had to return the rest of the list.
