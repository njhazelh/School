///////////////////////////////////////////////////////////////////////////////
//  Employees  ////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


// An Employee is one of:
// new Worker(String name, int tasks);
// new boss(String name, String unit, int tasks, LoE peons)

// A List of Employees (LoE) is one of:
// new consloe Employee LoE;
// new mtloe;

interface LoE {
	int length();
	LoE append(LoE loe);
}

class Mtloe implements LoE {

	public int length() {
		return 0;
	}
	public LoE append(LoE loe) {
		return loe;
	}

}

class Consloe implements LoE{
	Employee first;
	LoE rest;

	Consloe(Employee first, LoE rest) {
		this.first = first;
		this.rest = rest;
	}
	public int length() {
		return 1 + this.rest.length();
	}
	public LoE append(LoE loe) {
		if (loe instanceof Mtloe) {
			return this;
		}
		else {
			return new Consloe(this.first, this.rest.append(loe));
		}
	}
}


interface Employee {
	String name = "";
	int tasks = 0;
	int countSubs();
	LoE fullUnit();
	boolean hasPeon(String name);

}

class Worker implements Employee {
	String name;
	int tasks;

	Worker(String name, int tasks) {
		this.name = name;
		this.tasks = tasks;
	}
	public int countSubs() {
		return 0;
	}
	public LoE fullUnit() {
		return new Mtloe();
	}
	public boolean hasPeon(String name) {
		return false;
	}

}

class Boss implements Employee {
	String name;
	String unit;
	int tasks;
	LoE peons;

	Boss(String name, String unit, int tasks, LoE peons) {
		this.name = name;
		this.unit = unit;
		this.tasks = tasks;
		this.peons = peons;
	}

	public int countSubs() {
		return countSubsHelp(this.peons);
	}

	private int countSubsHelp(LoE emps) {
		if (emps instanceof Mtloe) {
			return 0;
		} 
		else {
			return 1 + countSubsHelp(((Consloe) emps).rest);
		}
	}

	public boolean hasPeon(String name) {
		if (this.peons instanceof Mtloe) {
			return false;
		}
		else {
			return hasPeonHelp(name, this.peons);
		}
	}

	private boolean hasPeonHelp(String name, LoE peons) {
		if (peons instanceof Mtloe) {
			return false;
		}
		if (((Consloe) peons).first.name.equals(name)) {
			return true;
		}
		else {
			return hasPeonHelp(name, ((Consloe) peons).rest);
		}
	}

	public LoE fullUnit() {
		return fullUnitHelp(this.peons);
	}

	private LoE fullUnitHelp(LoE list) {
		if (list instanceof Mtloe) {
			return new Mtloe();
		}
		else {
			return new Consloe(((Consloe) list).first, new Mtloe())
			.append((((Consloe) list).first.fullUnit()
					.append(fullUnitHelp(((Consloe) list).rest))));
		}
	}
}



///////////////////////////////////////////////////////////////////////////////
//  Time  /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


// A Time is a new Time(in
// where Hours is an Integer in [0,24)
//   and  Mins is an Integer in [0,60)
class Time {
	int hours;
	int minutes;
	
	Time(int hours, int minutes) {
		this.hours = hours;
		this.minutes = minutes;
	}
	public int minutesFromMid() {
		return (60 * this.hours) + this.minutes;
	}
}

// An Event is a new Event(String name, Time start, Time end)
class Event {
	String name;
	Time start;
	Time end;
	
	Event(String name, Time start, Time end) {
		this.name = name;
		this.start = start;
		this.end = end;
	}
	public int duration() {
		return this.end.minutesFromMid() - this.start.minutesFromMid();
	}
	
	public boolean endBefore(Event e) {
		return e.start.minutesFromMid() > this.end.minutesFromMid();
	}

	public boolean overlap(Event e) {
		if ((this.end.minutesFromMid() < e.start.minutesFromMid())
				|| (e.end.minutesFromMid() < this.start.minutesFromMid())){
			return false;
		}
		else {
			return true;
		}
	}
}

// A Schedule is one of:
// - new NoEvent();
// - new ConsEvent(Event first, Schedule rest);

interface Schedule {
	boolean good();
	int scheduledTime();
	Schedule freeTime();
	Schedule append(Schedule s);
}

class NoEvent implements Schedule {
	
	public boolean good() {
		return true;
	}
	public int scheduledTime() {
		return 0;
	}
	public Schedule freeTime() {
		return new ConsEvent(new Event("Free Time!",
				new Time(0, 0), new Time(23, 59)), new NoEvent());	
	}
	public Schedule append(Schedule s) {
		return s;
	}
}


class ConsEvent implements Schedule {
	Event first;
	Schedule rest;
	
	ConsEvent(Event first, Schedule rest) {
		this.first = first;
		this.rest = rest;
	}

	public boolean good() {
		if (this.rest instanceof NoEvent) {
			return true;
		}
		if (this.first.endBefore(((ConsEvent) this.rest).first)) {
			return this.rest.good();
		}
		else {
			return false;
		}
	}
	public int scheduledTime() {
		return this.first.duration() + this.rest.scheduledTime();
	}
	public Schedule freeTime() {
		return freeTimeHelp(this, new NoEvent(), (new NoEvent()).freeTime());
	}
	private Schedule freeTimeHelp(Schedule sched, Schedule acc1, Schedule acc2) {
		if (sched instanceof NoEvent) {
			return acc1.append(acc2);
		}
		else {
			return freeTimeHelp(((ConsEvent) sched).rest,
					acc1.append(new ConsEvent(new Event("Free Time!",
							((ConsEvent) acc2).first.start,
							sub1Time(((ConsEvent) sched).first.start)),
							new NoEvent())),
							(new ConsEvent(new Event("Free Time!",
									add1Time(((ConsEvent) sched).first.end),
									((ConsEvent) acc2).first.end), new NoEvent())));
		}	
	}
	
	// INVARIANT: Only to be called on times other than 00:00
	private Time sub1Time(Time t) {
		if ((0 != t.hours) && (0 == t.minutes)) {
			return new Time(t.hours - 1, 59);
		}
		else {
			return new Time(t.hours, t.minutes - 1);
		}
	}
	private Time add1Time(Time t) {
		if ((t.hours != 23) && t.minutes == 59) {
			return new Time(t.hours + 1, 0);
		}
		else {
			return new Time(t.hours, t.minutes + 1);
			}
	}
	public Schedule append(Schedule s) {
		if (s instanceof NoEvent) {
			return s;
		}
		else {
			return new ConsEvent(this.first, this.rest.append(s));
		}
	}
}



///////////////////////////////////////////////////////////////////////////////
//  Organic Molecules  ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// An OrganicMolecule, or OM, is a:
// - new Carbon(Bonds);
// Note: There are no empty OM

		
// A Bonds is one of:
// - new ConsBond(AtomBond, Bonds);
// - new EmptyBond();

// A AtomBond is a:
// new AtomBond(int, Carbon)

// Butane is defined in the Examples class
interface Bonds {
	int countCarbons();
	int countBonds();
	boolean validCarbons();
	int countHydrogens();
}

class EmptyBond implements Bonds {
	public int countCarbons() {
		return 0;
	}
	public int countBonds() {
		return 0; 
	}
	public boolean validCarbons() {
		return true;
	}
	public int countHydrogens() {
		return 0;
	}
}

class ConsBond implements Bonds {
	AtomBond atomBond;
	Bonds rest;
	
	ConsBond(AtomBond atomBond, Bonds rest) {
		this.atomBond = atomBond;
		this.rest = rest;
	}
	
	public int countCarbons() {
		return this.atomBond.carbon.countCarbons() + this.rest.countCarbons();
		}
	public int countBonds() {
		return this.atomBond.bondType + this.rest.countBonds();
	}
	public boolean validCarbons() {
		return this.atomBond.carbon.validRemaining() && this.rest.validCarbons();
	}
	public int countHydrogens() {
		if (this.rest instanceof EmptyBond) {
			return this.atomBond.carbon.countRemainingHydrogens();
		}
		else {
			return (3 - this.atomBond.bondType) + 
					this.rest.countHydrogens();
		}
	}
}

class Carbon {
	Bonds bonds;
	
	Carbon(Bonds bonds){
		this.bonds = bonds;
	}
	
	public int countCarbons() {
		if (this.bonds instanceof EmptyBond) {
			return 1;
		}
		else {
			return 1 + this.bonds.countCarbons();
		}
	}
	public boolean valid() {
		return this.bonds.countBonds() == 4 && this.bonds.validCarbons();
	}
	public boolean validRemaining() {
		return (this.bonds instanceof EmptyBond) ||
				((this.bonds.countBonds() <= 3) && this.bonds.validCarbons());
	}

	public int countHydrogens() {
		if (this.bonds instanceof EmptyBond) {
			return 4;
		}
		else {
			return (4 - this.bonds.countBonds()) + this.bonds.countHydrogens();
		}
	}

	public int countRemainingHydrogens() {
		if (this.bonds instanceof EmptyBond) {
			return 3;
		}
		else {
			return (3 - this.bonds.countBonds()) + this.bonds.countHydrogens();
		}
	}	
	
}


class AtomBond {
	int bondType;
	Carbon carbon;
	
	AtomBond(int bondType, Carbon carbon) {
		this.bondType = bondType;
		this.carbon = carbon;
	}
}
