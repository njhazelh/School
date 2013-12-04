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
     * 
     * @return
     */
    public long getEndTime() {
        return this.startTime.getTimeInMillis()
                + (this.movie.getLengthInSecs() * 1000);
    }

    /**
     * 
     * @return
     */
    GregorianCalendar getEndTimeCalendar() {
        GregorianCalendar end = new GregorianCalendar();
        end.setTimeInMillis(this.getEndTime());
        return end;
    }

    /**
     * 
     * @param e
     * @return
     */
    boolean isOverlapping(Event e) {
        return (this.theater == e.theater)
                && (this.startTime.before(e.getEndTimeCalendar()) || this
                        .getEndTimeCalendar().after(e.startTime));
    }

    /**
     * 
     * @param numSold
     */
    void fillSeats(int numSold) {
        this.filledSeats += numSold;
    }
    
    public int getFilledSeats() {
        return this.filledSeats;
    }

    /**
     * 
     * @return
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
