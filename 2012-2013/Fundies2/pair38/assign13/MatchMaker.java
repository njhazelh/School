/**
 * MatchMaker Class
 * @author Nicholas Jones, Trevyn Langsford
 * Date: 4/8/2013
 */

import java.util.ArrayList;

public class MatchMaker {

	/**
	 * Are all people engaged or out of possibles?
	 * @param people The list of people to check
	 * @return <code>true</code> if all are done, else <code>false</code>
	 */
	private Boolean areAllDone(ArrayList<Person> people){
		for(Person p: people)
			if(!p.isDone())
				return false;
		
		return true;
	}
	
	/**
	 * How many unengaged people are there?
	 * Used to monitor state of algorithm
	 * @param people The set of people to count
	 * @return The number of people unengaged
	 */
	public static Integer countUnengaged(ArrayList<Person> people){
		Integer i=0;
		
		for(Person p: people)
			if(!p.isEngaged())
				i++;
		
		return i;
	}
	
	/**
	 * Construct couple pairs.
	 * @param people List of either men or women
	 * @return A list of couples with given gender first in pair.
	 */
	private ArrayList<Pair<String>> getCouples(ArrayList<Person> people){
		ArrayList<Pair<String>> couples = new ArrayList<Pair<String>>();
		
		for(Person p: people)
			if(p.isEngaged())
				couples.add(new Pair<String>(p.name(), p.intended().name()));
		
		return couples;
	}
	
	/**
	 * Find the most stable configuration.
	 * @param men The list of men
	 * @param women The list of women
	 * @return The most stable list of couples possible.
	 */
	public ArrayList<Pair<String>> courtship(ArrayList<Person> men, ArrayList<Person> women){
		while(!areAllDone(men)){
			for(Person man: men)
				while(!man.isDone())
					man.propose();
			//System.out.println(countUnengaged(men)+" unengaged men left.");
		}
		
		return getCouples(men);
	}
	
	/**
	 * MAIN METHOD
	 * @param args Command line arguments
	 */
	public static void main(String[] args) {
		//Pair<ArrayList<Person>> people = God.makePeople(1000);
		//Pair<ArrayList<Person>> people = God.makeNumericCouples(10000);
		Pair<ArrayList<Person>> people = God.makeAntiNumericCouples(1000);
		
		ArrayList<Person> men = people.getLeft();
		ArrayList<Person> women = people.getRight();
		
		// Need a way to generate couples
		
		MatchMaker mm = new MatchMaker();
		ArrayList<Pair<String>> couples = mm.courtship(men, women);
		
		// PRINT OUT THE LIST OF COUPLES
		for(Pair<String> couple: couples)
			System.out.printf("%s, %s\n",couple.getLeft(),couple.getRight());
	}
}
