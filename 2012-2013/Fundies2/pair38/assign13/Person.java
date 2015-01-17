import java.util.*;

/**
 * IPerson interface and subclasses
 * @author Nicholas Jones, Trevyn Langsford
 * Date: 4/8/2013
 */
interface IPerson {

	String name();
	// The name of this IPerson
	 
	IPerson intended();
	// This IPerson's intended significant other, if any.
	 
	ArrayList<Person> preferences();
	// People this IPerson would marry, in order of preference.
	 
	ArrayList<Person> possibles();
	// People this IPerson has not proposed to, but is still interested in, in
	// order of preference.
	 
	void loadPreferences(ArrayList<Person> l);
	// Effect: set this IPerson's preferences to the given list.
	 
	void reset();
	// Effect: Reinitialize this IPerson's intended (none), possibles (empty), and
	//preferences (empty).
	 
	Boolean propose();
	// Effect: Propose to the most desired Person not already proposed to.
	// Produces true if proposal is accepted, false if rejected.
	 
	Boolean iLoveYou(Person p);
	// This message represents a proposal from the given Person to this
	// IPerson.
	// Effect: set the intended to the given IPerson, if accepted.
	// Produce true if accepted, false otherwise.
	 
	void iChangedMyMind(Person p);
	// This message represents a break up from the given Person to this
	// IPerson.
	// Effect: set the intended to none.
	// Assume: this IPerson is the given Person's intended and vice versa.
	 
	Boolean iLikeMore(IPerson p1, IPerson p2);
	// Does this IPerson like the first IPerson more than the second?
	 
	Boolean isCouple(Person p);
	// Are this IPerson and the given Person engaged to each other?
	
	Boolean isPerson();
	
	Boolean isEngaged();
	// Is this IPerson engaged?
	
	Boolean isDone();
	// Is this IPerson engaged or ForeverAlone?
}

class Person implements IPerson{
	private String name;
	private IPerson intended;
	private ArrayList<Person> preferences;
	private ArrayList<Person> possibles;
	
	public Person(String name){
		this.name = name;
		this.intended = new NoPerson();
		this.preferences = new ArrayList<Person>(0);
		this.possibles = new ArrayList<Person>(0);
	}
	
//	public Person(String name, ArrayList<IPerson> prefs, ArrayList<IPerson> poss) {
//		this.name = name;
//		this.intended = new NoPerson();
//		this.preferences = prefs;
//		this.possibles = poss;
//	}
	
	public String name(){ return this.name; }
	
	public IPerson intended(){return this.intended; }
	
	public ArrayList<Person> preferences(){ return this.preferences; }

	public ArrayList<Person> possibles(){ return this.possibles; }

	public void loadPreferences(ArrayList<Person> l){
		this.preferences = l;
		this.possibles = l;
	}
	
	public void reset(){
		this.intended = new NoPerson();
		this.preferences = new ArrayList<Person>();
		this.possibles = new ArrayList<Person>();	
	}
	
	public Boolean propose(){
		if (this.possibles.get(0).iLoveYou(this)){
			this.intended.iChangedMyMind(this);
			this.intended = this.possibles.get(0);
			this.possibles.remove(0);
			return true;
		}
		else{
			this.possibles.remove(0);
			return false;
		}
	}
	
	public Boolean iLoveYou(Person p){
		if (!this.intended.isPerson()){
			this.intended = p;
			return true;
		}
		else if (this.iLikeMore(p, this.intended())){
			this.intended.iChangedMyMind(this);
			this.intended = p;
			return true;
		}
		else 
			return false;
	}
	
	
	public void iChangedMyMind(Person p) {
		if (this.intended.equals(p))
			this.intended = new NoPerson();
		else
			throw new RuntimeException("intended mismatch");
	}
		
	
	public Boolean iLikeMore(IPerson p1, IPerson p2) {
		return this.preferences.indexOf(p1) < this.preferences.indexOf(p2);
	}
	
	public Boolean isCouple(Person p) {
		return p.equals(this.intended);
	}
	
	public Boolean isPerson() {
		return true;
	}
	
	public Boolean isEngaged(){
		return intended().isPerson();
	}
	
	public Boolean isDone(){
		return intended().isPerson() || possibles().size()==0;
	}
}

class NoPerson implements IPerson {
	public String name = "";
	public IPerson intended = this;
	public ArrayList<Person> preferences = new ArrayList<Person>(0);
	public ArrayList<Person> possibles = new ArrayList<Person>(0);
	
	NoPerson() {}
	
	public String name() { return this.name; }
	
	public IPerson intended() {return this.intended; }
	
	public ArrayList<Person> preferences() { return this.preferences; }

	public ArrayList<Person> possibles() { return this.possibles; }
	
	public void loadPreferences(ArrayList<Person> l) {}
	
	public void reset() {}
	
	public Boolean propose() {
		return false;
	}
	
	public Boolean iLoveYou(Person p) {
		return false;
	}
	
	public void iChangedMyMind(Person p) {}
	
	public Boolean iLikeMore(IPerson p1, IPerson p2) {
		return false;
	}
	
	public Boolean isCouple(Person p) {
		return false;
	}

	public Boolean isPerson() {
		return false;
	}
	
	public Boolean isEngaged(){
		return false;
	}
	
	public Boolean isDone(){
		return true;
	}
}

