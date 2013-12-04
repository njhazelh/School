/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.GregorianCalendar;

/**
 * <code>Event</code> represents a single event
 * 
 * INVARIANTS:
 * - Start time of event is before end time of event
 * - 0 <= seatsFilled <= theater.size
 * - this.theater != null
 * - this.eventId is unique to this Event in the complex
 * 
 * @author Nick Jones
 * 
 */
public class Event {
    private int               eventId;         // The unique event id
    
    private Movie             movie;           // The movie that will be shown
    
    private Theater           theater;         // The theater that this event is
                                               // in.
    
    private int               filledSeats = 0; // The number of seats filled
                                               // for this event.
    
    private GregorianCalendar startTime;       // The date and time that the
                                               // movie starts.

    /**
     * 
     * @param eventId
     * @param movie
     * @param theater
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
     * Remove this Event from visibility by removing it from the list of Events
     * in the Theater that it's playing in.
     */
    void hide() {
        this.theater.removeEvent(this);
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
        return (this.theater == e.theater)
                && (this.startTime.before(e.getEndTimeCalendar()) || this
                        .getEndTimeCalendar().after(e.startTime));
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
     * @return 
     */
    public int getFilledSeats() {
        return this.filledSeats;
    }
    
    /**
     * Does this event have n Tickets left?
     * 
     * @param n number of Tickets to check for
     * @return true iff there are at least n tickets left to buy.
     */
    public boolean hasNTickets(int n) {
        return this.theater.getSize() - this.filledSeats >= n;
    }

    /**
     * Which Theater is this Event in?
     * 
     * @return The Theater thast this Event is in.
     */
    Theater getTheater() {
        return this.theater;
    }

    /**
     * 
     */
    @Override
    public boolean equals(Object e) {
        return (e instanceof Event) && (((Event) e).eventId == this.eventId);
    }
}
