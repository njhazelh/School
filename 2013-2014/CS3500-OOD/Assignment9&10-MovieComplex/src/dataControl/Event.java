package dataControl;

import java.util.Calendar;

/**
 * <code>Event</code> represents a single event
 * 
 * @author Nick
 * 
 */
public class Event {
    private int     eventId;  // The unique event id
    private Movie   movie;    // The movie that will be shown
    private Theater theater;  // The theater that this event is in.
    private Calendar    startTime; // The date and time that the movie starts.

    /**
     * 
     * @param eventId
     * @param movie
     * @param theater
     * @param startTime
     */
    protected Event(int eventId, Movie movie, Theater theater, Calendar startTime) {
        this.eventId = eventId;
        this.movie = movie;
        this.theater = theater;
        this.startTime = startTime;
    }
    
    /**
     * 
     * @return
     */
    public Date getEndTime() {
        int year = this.startTime.getWeekYear() + this.movie.getLength() 
                % 60 % 24 % 365
                + this.startTime.isLeapYear(this.startTime.getWeekYear()) ? 1 : 0;
        return new Date();
    }
}
