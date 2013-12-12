/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.Calendar;
import java.util.GregorianCalendar;

/**
 * <code>Event</code> represents a single event where people go to the a movie
 * complex to watch a movie.
 * 
 * INVARIANTS:
 * - Start time of event is before end time of event
 * - 0 <= seatsFilled <= theater.size
 * - this.theater != null
 * - this.eventId is unique to this Event in the complex
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class Event {
    private int               eventId;        // The unique event id

    private Movie             movie;          // The movie that will be shown

    private Theater           theater;        // The theater that this event is
                                               // in.

    private int               filledSeats = 0; // The number of seats filled
                                               // for this event.

    private GregorianCalendar startTime;      // The date and time that the
                                               // movie starts.

    /**
     * Create an event with the given values
     * 
     * @param eventId An int unique to this Event in the Complex.
     * @param movie The Movie to show at this Event
     * @param theater The Theater to hold this Event in.
     * @param startTime start time in milliseconds since the epoch.
     */
    Event(int eventId, Movie movie, Theater theater, long startTime) {
        this.eventId = eventId;
        this.movie = movie;
        this.theater = theater;
        this.startTime = new GregorianCalendar();
        this.startTime.setTimeInMillis(startTime);
    }

    /**
     * What time does this Event end?
     * 
     * @return milliseconds since epoch at time of movie ending.
     */
    public long getEndTime() {
        return this.startTime.getTimeInMillis()
                + (this.movie.getLengthInSecs() * 1000);
    }

    /**
     * What is the unique ID for this Event?
     * 
     * @return the event ID.
     */
    public int getID() {
        return this.eventId;
    }
    
    /**
     * @return the start time as milliseconds since epoch
     */
    public long getStartTime() {
        return this.startTime.getTimeInMillis();
    }

    /**
     * Remove this Event from visibility by removing it from the list of Events
     * in the Theater that it's playing in and from the List of Events showing
     * showing this.movie in this.movie
     */
    void hide() {
        this.theater.removeEvent(this);
        this.movie.removeEvent(this);
    }

    /**
     * Have all the seats been taken?
     * 
     * @return true iff all seats are taken.
     */
    public boolean isSoldOut() {
        return this.filledSeats == this.theater.getSize();
    }

    /**
     * Gets the Movie to be shown at this event.
     * 
     * @return The Movie to be shown.
     */
    public Movie getMovie() {
        return this.movie;
    }

    /**
     * What time does the Event end?
     * 
     * @return An Object representing the date and time that the Event ends.
     */
    GregorianCalendar getEndTimeCalendar() {
        GregorianCalendar end = new GregorianCalendar();
        end.setTimeInMillis(this.getEndTime());
        return end;
    }

    /**
     * Is this event overlapping another event?
     * 
     * @param e The Event to compare this to.
     * @return true iff events are in same theater and times overlap.
     */
    boolean isOverlapping(Event e) {
        boolean t1 = (this.theater == e.theater);
        boolean t2 = this.startTime.before(e.getEndTimeCalendar());
        boolean t3 = this.getEndTimeCalendar().after(e.startTime);
        
        return t1 && !((t2 && !t3) || (!t2 && t3));
    }

    /**
     * Add to the number of filled seats.
     * 
     * @param numSold the number of seats to fill.
     */
    void fillSeats(int numSold) {
        this.filledSeats += numSold;
    }

    /**
     * How many seats are filled?
     * 
     * @return The number of seats filled by people.
     */
    public int getFilledSeats() {
        return this.filledSeats;
    }

    /**
     * Does this event have n Tickets left?
     * 
     * @param n number of Tickets to check for (n >= 0)
     * @return true iff there are at least n tickets left to buy.
     */
    public boolean hasNTickets(int n) {
        return (this.theater.getSize() - this.filledSeats) >= n;
    }

    /**
     * Which Theater is this Event in?
     * 
     * @return The Theater thast this Event is in.
     */
    public Theater getTheater() {
        return this.theater;
    }

    /**
     * Get a String of this event
     * 
     * @return A String representing this event
     *         <Title> @ hh:mm(AM|PM) in <Theater>
     */
    @Override
    public String toString() {
        Calendar end = this.getEndTimeCalendar();
        return String
                .format("%s @ %d:%02d%s-%d:%02d%s in %s", this.movie.getTitle(),
                        this.startTime.get(Calendar.HOUR), this.startTime
                                .get(Calendar.MINUTE), this.startTime
                                .get(Calendar.AM_PM) == Calendar.AM ? "AM" :
                                         "PM",
                                end.get(Calendar.HOUR),
                                end.get(Calendar.MINUTE),
                                end.get(Calendar.AM_PM) == Calendar.AM ? "AM"
                                        : "PM",
                                this.theater);
    }
}
