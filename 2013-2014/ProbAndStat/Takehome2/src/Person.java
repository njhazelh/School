import java.util.Scanner;
import java.util.ArrayList;
import java.io.File;
import java.io.FileNotFoundException;

public class Person {
	int index;
	public Double without;
	public Double with;
	public int trait;
	
	public Person(int index, Double without, Double with, int trait) {
		this.index = index;
		this.without = without;
		this.with = with;
		this.trait = trait;
	}
	
	@Override
	public String toString() {
		return "" + index + ": " + trait + " " + without + " " + with; 
	}
	
	public static Double mean(ArrayList<Person> ar, boolean control) {
		Double result = 0.0;
		
		if (control) {
			for (Person p : ar) {
				result += p.without;
			}
		}
		else {
			for (Person p : ar) {
				result += p.with;
			}
		}
		
		return result/ar.size();
	}
	
	public static Double std(ArrayList<Person> ar, Double mean, boolean control) {
		Double result = 0.0;
		
		if (control) {
			for (Person p : ar) {
				result += Math.pow(p.without - mean, 2);
			}
		}
		else {
			for (Person p : ar) {
				result += Math.pow(p.with - mean, 2);
			}
		}
		
		return Math.sqrt(result/ar.size());
	}
	
	public static Double percentZero(ArrayList<Person> ar) {
		Double result = 0.0;
		
		for(Person p : ar) {
			result += (p.trait + 1) % 2;
		}
		
		return result / ar.size() * 100;
	}
	
	public static void main(String[] args) {
		int numControl = 10;
		int numTest =  10;
		
		assert(numControl + numTest <= 1000);
		
		try {
			Scanner scnr = new Scanner(new File("Experiment-Student.txt")); 
			
			ArrayList<Person> ar = new ArrayList<Person>();
			ArrayList<Person> control = new ArrayList<Person>();
			ArrayList<Person> test = new ArrayList<Person>();
			
			int i = 1;
			while(scnr.hasNextLine()) {
				String line = scnr.nextLine();
				Scanner lScnr = new Scanner(line);
				
				int trait = lScnr.nextInt();
				Double without = lScnr.nextDouble();
				Double with = lScnr.nextDouble();
				Person p = new Person(i++, without, with, trait);
				
				ar.add(p);
			}
			
			
			for (i=0; i<numControl; i++) {
				int rand = (int)(ar.size() * Math.random());
				control.add(ar.get(rand));
				ar.remove(rand);
			}
			
			for (i=0; i<numTest; i++) {
				int rand = (int)(ar.size() * Math.random());
				test.add(ar.get(rand));
				ar.remove(rand);
			}
			
			System.out.println("\nControl:\n--------------------------");
			
			i=1;
			for(Person p : control)
				System.out.println("" + i++ + ": " + p);
			
			System.out.println("\nTest:\n--------------------------");
			
			i=1;
			for(Person p : test)
				System.out.println("" + i++ + ": " + p);
			
			Double controlMean = Person.mean(control, true);
			Double controlSTD = Person.std(control, controlMean, true);
			Double controlZeroPercent = Person.percentZero(control);
			
			Double testMean = Person.mean(test, false);
			Double testSTD = Person.std(test, testMean, false);
			Double testZeroPercent = Person.percentZero(test);
			
			ArrayList<Person> all = new ArrayList<Person>(control);
			all.addAll(test);
			Double totalZeroPercent = Person.percentZero(all);
			
			System.out.println("\nControl:\n--------------------------");
			System.out.println("mean: " + controlMean);
			System.out.println("std: " + controlSTD);
			System.out.println("%0: " + controlZeroPercent);
			
			System.out.println("\nTest:\n--------------------------");
			System.out.println("mean: " + testMean);
			System.out.println("std: " + testSTD);
			System.out.println("%0: " + testZeroPercent);
			
			System.out.println("\nTotal %0:\n--------------------------");
			System.out.println("" + totalZeroPercent);
			
			Double cv = (testMean - controlMean) / 
					Math.sqrt(Math.pow(testSTD,2)/test.size() +
							  Math.pow(controlSTD,2)/control.size());
			
			System.out.println("\nResult:\n--------------------------");
			System.out.println((Math.abs(cv) > 1.96 ? "reject" : "accept") + " H_0");
			
			scnr.close();
		}
		catch (FileNotFoundException e) { System.out.println("File not found"); System.exit(1); }
	}

}
