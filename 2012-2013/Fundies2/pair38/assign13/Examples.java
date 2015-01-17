import tester.*;
import java.util.*;

class Examples {

	/**
	 * A test of the Person object
	 * @param t The tester object
	 */
	public void testPeople(Tester t) {
		//NoPerson nop = new NoPerson();
		
		Person bob = new Person("Bob");
		Person hank = new Person("Hank");
		
		Person jane = new Person("Jane");
		Person sara = new Person("Sara");
		
		ArrayList<Person> bobsplist = new ArrayList<Person>(0);
		bobsplist.add(jane);
		bobsplist.add(sara);

		ArrayList<Person> hanksplist = new ArrayList<Person>(0);
		hanksplist.add(sara);
		hanksplist.add(jane);
		

		
		ArrayList<Person> janesplist = new ArrayList<Person>(0);
		janesplist.add(bob);
		janesplist.add(hank);

		ArrayList<Person> sarasplist = new ArrayList<Person>(0);
		sarasplist.add(hank);
		sarasplist.add(bob);
		
		bob.loadPreferences(bobsplist);
		hank.loadPreferences(hanksplist);
		
		jane.loadPreferences(janesplist);
		sara.loadPreferences(sarasplist);
		

		t.checkExpect(bob.intended().isPerson(), false);
		t.checkExpect(bob.possibles().size(), 2);
		t.checkExpect(bob.possibles().get(0), jane);
		bob.propose();
		t.checkExpect(bob.intended(), jane);
		t.checkExpect(bob.possibles().get(0), sara);
		
		bob.reset();
		ArrayList<Person> l1 = new ArrayList<Person>();
		l1.add(sara);
		bob.loadPreferences(l1);
	
		bob.propose();
		t.checkExpect(bob.intended(), sara);
		t.checkExpect(sara.intended(), bob);
		hank.propose();
		t.checkExpect(hank.intended(), sara);
		t.checkExpect(sara.intended(), hank);
		t.checkExpect(bob.intended().isPerson(), false);
		
		hank.reset();
		bob.reset();
		sara.reset();
		jane.reset();
		
		bob.loadPreferences(bobsplist);
		hank.loadPreferences(hanksplist);
		jane.loadPreferences(janesplist);
		sara.loadPreferences(sarasplist);
	}
	
	/**
	 * A test of the MatchMaker algorithm
	 * @param t The tester object
	 */
	public void testAlgorithm(Tester t){
		Pair<ArrayList<Person>> numeric = God.makeNumericCouples(100);
		Pair<ArrayList<Person>> antiNumeric = God.makeAntiNumericCouples(100);
		MatchMaker mm = new MatchMaker();
		
		ArrayList<Pair<String>> numericResult = new ArrayList<Pair<String>>();
		ArrayList<Pair<String>> antiNumericResult = new ArrayList<Pair<String>>();
		
		for(Integer i=0; i<numeric.getLeft().size(); i++)
			numericResult.add(new Pair<String>(numeric.getLeft().get(i).name(),
					numeric.getRight().get(i).name()));
		
		for(Integer i=0; i<antiNumeric.getLeft().size(); i++)
			antiNumericResult.add(new Pair<String>(antiNumeric.getLeft().get(i).name(), 
					antiNumeric.getRight().get(antiNumeric.getRight().size()-i-1).name()));
		
		t.checkExpect(mm.courtship(numeric.getLeft(), numeric.getRight()),
				numericResult);
		t.checkExpect(mm.courtship(antiNumeric.getLeft(), antiNumeric.getRight()),
				antiNumericResult);
	}

}
