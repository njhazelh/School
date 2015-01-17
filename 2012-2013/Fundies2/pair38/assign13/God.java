import java.util.ArrayList;
import java.util.Collections;

/**
 * God decides who loves who.
 * @author Nick
 *
 */
public class God {
	
	/**
	 * Randomize the order of the people.
	 * @param people The list of people
	 * @return The list of people in a random order.
	 */
	private static ArrayList<Person> scramble(ArrayList<Person> people){
		ArrayList<Person> scrambledList = new ArrayList<Person>(0);
		
		for(Person p: people)
			scrambledList.add((int)Math.round(Math.random()*scrambledList.size()),p);
		
		return scrambledList;
	}
	
	/**
	 * Make a Set of males and females where all males and all females
	 * have the same preferences, which results in a strictly
	 * numeric coupling. ie. man1 - woman1, man2 - woman2
	 * @param howMany How many people
	 * @return The set of people where the left side of the pair is the
	 * men and the right side is the women.
	 */
	public static Pair<ArrayList<Person>> makeNumericCouples(Integer howMany){
		ArrayList<Person> men = new ArrayList<Person>();
		ArrayList<Person> women = new ArrayList<Person>();
		
		for(Integer i=0; i<howMany; i++){
			men.add(new Person("man"+i));
			women.add(new Person("woman"+i));
		}
		
		for(Integer i=0; i<howMany; i++){
			men.get(i).loadPreferences(women);
			women.get(i).loadPreferences(men);
		}
		
		return new Pair<ArrayList<Person>>(men, women);
	}
	
	/**
	 * Make a Set of males and females where all males have inverted numeric
	 * preference, which results in a strictly anti-numeric coupling.
	 * ie. man0 - woman(n), man1 - woman(n-1), man2 - woman(n-2)
	 * @param howMany How many people
	 * @return The set of people where the left side of the pair is the
	 * men and the right side is the women.
	 */
	public static Pair<ArrayList<Person>> makeAntiNumericCouples(Integer howMany){
		ArrayList<Person> men = new ArrayList<Person>();
		ArrayList<Person> women = new ArrayList<Person>();
		
		for(Integer i=0; i<howMany; i++){
			men.add(new Person("man"+i));
			women.add(new Person("woman"+i));
		}

		ArrayList<Person> womenFlipped = new ArrayList<Person>(women);
		Collections.reverse(womenFlipped);
		
		for(Integer i=0; i<howMany; i++){
			men.get(i).loadPreferences(womenFlipped);
			women.get(i).loadPreferences(men);
		}
		
		return new Pair<ArrayList<Person>>(men, women);
	}
	
	/**
	 * Make a set of people with random preferences.
	 * @param howMany How many people.
	 * @return The set of people where the left side of the pair is the
	 * men and the right side is the women.
	 */
	public static Pair<ArrayList<Person>> makePeople(Integer howMany){
		ArrayList<Person> men = new ArrayList<Person>();
		ArrayList<Person> women = new ArrayList<Person>();
		
		for(Integer i=0; i<howMany; i++){
			men.add(new Person("man"+i));
			women.add(new Person("woman"+i));
		}
		
		for(Integer i=0; i<howMany; i++){
			men.get(i).loadPreferences(scramble(women));
			women.get(i).loadPreferences(scramble(men));
		}
		
		return new Pair<ArrayList<Person>>(men, women);
	}
}
