/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;

/**
 * Theater represents a single screen within a movie complex.
 * 
 * INVARIANTS:
 * - theaterNumber is unique to all theaters within a movie complex.
 * - There is never more than one event at a single time in a single theater.
 * - size >= 0
 * 
 * @author Nick
 * @version 12/4/2013
 */
public class Theater {
    private String           theaterName;
    private int              theaterNumber;
    private ArrayList<Event> events    = new ArrayList<Event>();
    private int              basePrice = 0;
    private boolean          isLuxury  = false;
    private int              size;

    /**
     * This is the contructor for <code>Theater</code>
     * 
     * @param theaterName The name of the Theater.
     * @param theaterNumber A unique integer so that each Theater within
     *        MovieComplex has
     *        a different theaterNumber.
     * @param basePrice The price added to any event price in this theater.
     * @param isLuxury Is this a luxury theater? Luxury theaters usually have a
     *        base price > 0, but not always.
     * @param size the number of seats in this theater
     */
    Theater(String theaterName, int theaterNumber, int basePrice,
            boolean isLuxury, int size) {
        this.theaterName = theaterName;
        this.theaterNumber = theaterNumber;
        this.basePrice = basePrice;
        this.isLuxury = isLuxury;
        this.size = size;
    }

    /**
     * Remove the given event from the list of events.
     * 
     * @param e The Event to remove.
     */
    void removeEvent(Event e) {
        this.events.remove(e);
    }

    /**
     * What is the name of this Theater?
     * 
     * @return The Theater's name.
     */
    public String getName() {
        return this.theaterName;
    }

    /**
     * Get the number of this Theater.
     * 
     * @return A number unique to this theater in the complex.
     */
    public int getID() {
        return this.theaterNumber;
    }

    /**
     * How many seats are in this Theater?
     * 
     * @return The Number of Seats in this Theater.
     */
    public int getSize() {
        return this.size;
    }

    /**
     * Add an event to this Theater.
     * 
     * @param event The Event to add
     * @throws OverlappingEventException When the given event overlaps with
     *         another event in this Theater.
     */
    void addEvent(Event event) throws OverlappingEventException {

        // Check for time collisions
        for (Event e : this.events) {
            if (e.isOverlapping(event)) {
                throw new OverlappingEventException(String.format(
                        "%s overlaps %s", e, event, this));
            }
        }

        this.events.add(event);
    }

    /**
     * Get a list of all the Events showing in this Theater in the future
     * ordered in the order they were added to this Theater.
     * 
     * @return A list of Events
     */
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
     * Say a theater undergoes renovation or management <bold>SUDDENLY</bold>
     * decides that
     * the crappy theater number 6 down the hall is fit for a king. This method
     * allows you to change the
     * luxury status of a theater.
     * 
     * @param isLux The new Status.
     */
    void setLuxury(boolean isLux) {
        this.isLuxury = isLux;
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
     * @return <Name>(<Number>):<Size>
     */
    public String toString() {
        return String.format("%s(%d):%d", this.theaterName, this.theaterNumber,
                this.size);
    }
}
