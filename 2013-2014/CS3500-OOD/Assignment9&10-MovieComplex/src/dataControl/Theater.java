package dataControl;

import java.util.ArrayList;

/**
 * Theater represents a single screen within a movie complex.
 * 
 * INVARIANTS:
 *  - theaterNumber is unique to all theaters within a movie complex.
 *  - There is never more than one event at a single time in a single theater.
 *  
 * @author Nick
 *
 */
public class Theater {
    private int theaterNumber;
    private ArrayList<Event> events = new ArrayList<Event>();
    private int basePrice = 0;
    private boolean isLuxury = false;
    private int size;
    
    /**
     * This is the contructor for <code>Theater</code>
     * 
     * @param theaterNumber A unique integer so that each Theater within MovieComplex has
     * a different theaterNumber.
     * @param basePrice The price added to any event price in this theater.
     * @param isLuxury Is this a luxury theater? Luxury theaters usually have a base price > 0, but not always.
     */
    Theater(int theaterNumber, int basePrice, boolean isLuxury, int size) {
        this.theaterNumber = theaterNumber;
        this.basePrice = basePrice;
        this.isLuxury = isLuxury;
        this.size = size;
    }
    
    /**
     * Get the number of this Theater.
     * 
     * @return A number unique to this theater in the complex.
     */
    public int getNumber() {
        return this.theaterNumber;
    }
    
    public int getSize() {
        return this.size;
    }
    
    /**
     * Get the unique theaterNumber of this Theater.
     * 
     * @return The theaterNumber for this Theater.
     */
    int getTheaterNumber() {
        return this.theaterNumber;
    }
    
    void addEvent(Event event) throws OverlappingEventException{
        for (Event e : this.events) {
            if (e.isOverlapping(event)) {
                throw new OverlappingEventException();
            }
        }
        
        events.add(event);
    }
    
    public ArrayList<Event> getEvents() {
        return new ArrayList<Event>(this.events);
    }
    
    /**
     * What is the base price of this theater?
     * 
     * @return the base price of this <code>Theater</code> in cents.
     */
    public int getBasePrice() {
        return this.basePrice;
    }
    
    /**
     * This method changes the base price of the theater to something new.
     * This basePrice will be added to all tickets for events here.
     * 
     * @param newPrice The new base price.
     */
    void setBasePrice(int newPrice) {
        this.basePrice = newPrice;
    }
    
    /**
     * Say a theater undergoes renovation or management <bold>SUDDENLY</bold> decides that
     * the crappy theater number 6 down the hall is fit for a king.  This method allows you to change the
     * luxury status of a theater.
     * 
     * @param isLuxury The new Status.
     */
    void setLuxury(boolean isLuxury) {
        this.isLuxury = isLuxury;
    }
    
    /**
     * Is this a luxury theater?
     * 
     * @return true, iff this is a luxury theater.
     */
    public boolean isLuxury() {
        return this.isLuxury;
    }
    
    /**
     * Does that <code>Object</code> equal this <code>Theater</code>?
     * 
     * @param that The <code>Object</code> to compare equality to this.
     * @return true, iff that is an instance of Theater with the same theaterNumber
     * as this.
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof Theater &&
               ((Theater)that).theaterNumber == this.theaterNumber;
    }
    
    /**
     * Get the hashCode of this Movie.
     * 
     * hashCode is implemented so that the hashCode/Equals requirements are fulfilled in all cases.
     * a.equals(b) => a.hashCode() == b.hashCode()
     * 
     * @return a non-unique int representing this Movie.
     */
    public int hashCode() {
       return this.theaterNumber; 
    }
}
