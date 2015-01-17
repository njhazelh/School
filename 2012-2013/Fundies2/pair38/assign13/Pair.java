/**
 * Pair<X> Class
 * @author Nicholas Jones, Trevyn Langsford
 *
 * @param <X> Whatever the pair is.
 */
public class Pair<X> {
	private X left;
	private X right;
	
	/**
	 * CONSTRUCTOR
	 * @param left The left side of the pair
	 * @param right The right side of the pair
	 */
	public Pair(X left, X right){
		this.left=left;
		this.right=right;
	}
	
	/**
	 * Get the left side.
	 * @return The left side.
	 */
	public X getLeft(){
		return left;
	}
	
	/**
	 * Get the right side.
	 * @return The right side.
	 */
	public X getRight(){
		return right;
	}
}
