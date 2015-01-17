import tester.*;

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
