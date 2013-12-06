/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;

/**
 * Movie represents a movie such as "Cinderella", or "The Matrix" in an abstract
 * sense.
 * 
 * Requirements : movieId is a unique integer given by the ComplexController so
 * that
 * two Movies with the same title, lengthInSeconds, and rating could still be
 * different movies.
 * Clearly, this would be confusing for viewers, but it's certainly an option.
 * 
 * Example:
 * The movie Cinderella is:
 * - movieId : # unknown, since given by ComplexController
 * - title : "Cinderella"
 * - lengthInSeconds : 74*60
 * 
 * @author Nick Jones
 * @version 11/25/2013
 */
public class Movie {
    private int              movieId;        // unique within ComplexController
                                              // Movies.
    private String           title;          // title of movie
    private int              lengthInSeconds; // lengthInSeconds of movie in
                                              // seconds
    private ArrayList<Event> events;         // Events showing this Movie in
                                              // the future.

    /**
     * This is the contructor for a Movie.
     * 
     * @param movieId unique id for this movie
     * @param title the title of this movie
     * @param lengthInSeconds The length of this movie in seconds
     */
    protected Movie(int movieId, String title, int lengthInSeconds) {
        this.movieId = movieId;
        this.title = title;
        this.lengthInSeconds = lengthInSeconds;
        this.events = new ArrayList<Event>();
    }

    /**
     * Adds the event to the list of events
     * 
     * @param e The Event to add.
     */
    void addEvent(Event e) {
        if (!this.events.contains(e) && e.getMovie().equals(this)) {
            this.events.add(e);
        }
    }

    /**
     * @return the events
     */
    public ArrayList<Event> getEvents() {
        return new ArrayList<Event>(this.events);
    }

    /**
     * What is the ID of this movie?
     * 
     * @return The unique id for this Movie
     */
    public int getID() {
        return this.movieId;
    }

    /**
     * Accesses the lengthInSeconds of this <code>Movie</code> in minutes.
     * 
     * @return The lengthInSeconds of the Movie in seconds.
     */
    public int getLengthInSecs() {
        return this.lengthInSeconds;
    }

    /**
     * Accesses the title of the <code>Movie</code>
     * 
     * @return The title of the Movie.
     */
    public String getTitle() {
        return this.title;
    }

    /**
     * Get the hashCode of this Movie.
     * 
     * hashCode is implemented so that the hashCode/Equals requirements are
     * fulfilled in all cases.
     * a.equals(b) => a.hashCode() == b.hashCode()
     * 
     * @return a non-unique int representing this Movie.
     */
    @Override
    public int hashCode() {
        return this.movieId;
    }

    /**
     * Remove the given Event from the list of Events showing this Movie.
     * 
     * @param e The Event to remove.
     */
    void removeEvent(Event e) {
        this.events.remove(e);
    }

    /**
     * @return a String of this movie. "<title>, <length in mins> minutes"
     */
    @Override
    public String toString() {
        return String.format("%s, %d minutes", this.title,
            this.lengthInSeconds / 60);
    }
}
