import tester.Tester;

// A [List X] implements
// - cons : X -> [List X]
//   Cons given element on to this list.
// - first : -> X
//   Get the first element of this list 
//   INVARIANT: (only defined on non-empty lists).
// - rest : -> [List X]
//   Get the rest of this 
//   INVARIANT: (only defined on non-empty lists).
// - list-ref : Natural -> X
//   Get the ith element of this list 
//   INVARIANT: (only defined for lists of i+1 or more elements)
// - length : -> Natural
//   Compute the number of elements in this list.
 
// empty is a [List X] for any X.



///////////////////////////////////////////////////////////////////////////////
//  QuickLists  ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// A Binary Tree (BT) is a
// - new Node<X>(X val, Integer size, BT<X> left, BT<X> right)
// - new Leaf<X>(X val)

// A Forest is one of:
// - new ConsForest<X>(BT<X> bt, Forest<X> rest)
// - new NoForest<X>();

interface Forest<X> {
	//Cons given element on to this list.
	Forest<X> cons(X elem);
	
	//Get the first element of this list 
	// INVARIANT: (only defined on non-empty lists).
	X first();
	
	// Get the rest of this 
	// INVARIANT: (only defined on non-empty lists).
	Forest<X> rest();
	
	// Get the ith element of this list 
	// INVARIANT: (only defined for lists of i+1 or more elements)	
	X listRef(Integer i);
	
	// Compute the number of elements in this list.
	Integer length();
	
	// How many trees are in the forest?
	Integer forestLength();
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

class ConsForest<X> implements Forest<X> {
	BT<X> bt;
	Forest<X> rest;
	
	ConsForest(BT<X> bt, Forest<X> rest) {
		this.bt = bt;
		this.rest = rest;
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

class NoForest<X> implements Forest<X> {
	
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


class Examples {

	BT<String> leaf = new Leaf<String>("a");
	BT<String> small_tree = new Node<String>("c", 3, new Leaf<String>("b"),
			new Leaf<String>("a"));
	BT<String> mid_tree = new Node<String>("g", 7, 
			new Node<String>(
					"f", 3, new Leaf<String>("e"), new Leaf<String>("d")),
			new Node<String>(
					"c", 3, new Leaf<String>("b"), new Leaf<String>("a")));
	BT<String> large_tree = new Node<String>("z", 15, mid_tree, mid_tree);
	
	Forest<String> s_empty = new NoForest<String>();
	Forest<String> small_forest = new ConsForest<String>(small_tree, 
			new NoForest<String>());
	Forest<String> mid_forest = new ConsForest<String>(small_tree,
			new ConsForest<String>(mid_tree, new NoForest<String>()));
	Forest<String> large_forest = new ConsForest<String>(small_tree,
			new ConsForest<String>(mid_tree, 
					new ConsForest<String>(large_tree, new NoForest<String>())));
	
	Forest<String> ls = s_empty.cons("a").cons("b").cons("c").cons("d").cons("e");
	

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
		t.checkExpect(s_empty.length(), 0);
		t.checkExpect(s_empty.forestLength(), 0);
		t.checkExpect(s_empty.cons("a"),
				new ConsForest<String>(leaf, s_empty));
		
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
								s_empty)));
		t.checkExpect(mid_forest.rest(), 
				new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"),
								new ConsForest<String>(mid_tree, 
										s_empty))));
		t.checkExpect(new ConsForest<String>(leaf, new NoForest<String>()).rest(), 
				new NoForest<String>());

		t.checkExpect(new ConsForest<String>(new Leaf<String>("a"), s_empty).cons("b"),
				new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"), s_empty)));
		t.checkExpect(new ConsForest<String>(new Leaf<String>("b"),
						new ConsForest<String>(new Leaf<String>("a"), s_empty)).cons("c"),
						small_forest);
		t.checkExpect(new ConsForest<String>(small_tree, new ConsForest<String>(small_tree, s_empty)).cons("z"),
				new ConsForest<String>(new Node<String>("z", 7, small_tree, small_tree), s_empty));
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
}
