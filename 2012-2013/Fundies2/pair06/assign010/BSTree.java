import java.util.Comparator;

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


