package dataControl;

/**
 * Movie represents a movie such as "Cinderella", or "The Matrix" in an abstract sense.
 * 
 * Requirements : movieId is a unique integer given by the ComplexController so that
 * two Movies with the same title, length, and rating could still be different movies.
 * Clearly, this would be confusing for viewers, but it's certainly an option.
 * 
 * Example:
 * The movie Cinderella is:
 *  - movieId : # unknown, since given by ComplexController
 *  - title : "Cinderella"
 *  - lengthInMinutes : 74
 *  - rating : Rating.G
 * 
 * @author Nick Jones
 * @version 11/25/2013
 */
public class Movie {
    private int movieId; // unique within ComplexController Movies.
    private String title; // title of movie
    private int lengthInMinutes; // length of movie
    private Rating rating; // MPAA rating of movie.
    
    /**
     * This is the contructor for a Movie. 
     * @param movieId
     * @param title
     * @param lengthInMinutes
     * @param rating
     */
    protected Movie(int movieId, String title, int lengthInMinutes, Rating rating) {
        this.movieId = movieId;
        this.title = title;
        this.lengthInMinutes = lengthInMinutes;
        this.rating = rating;
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
     * Accesses the length of this <code>Movie</code> in minutes.
     * 
     * @return The length of the Movie in minutes.
     */
    public int getLength() {
        return this.lengthInMinutes;
    }
    
    /**
     * Accesses the rating of this <code>Movie</code>.
     * 
     * @return The Rating of this Movie.
     */
    public Rating getRating() {
        return this.rating;
    }
    
    /**
     * Is this <code>Movie</code> equal to that <code>Object</code>?
     * 
     * @param that The <code>Object</code> to compare equality to.
     * @return true if this and that are both instances of <code>Movie</code> with the same movieId
     */
    @Override
    public boolean equals(Object that) {
        return that instanceof Movie &&
               ((Movie)that).movieId == this.movieId;
    }
    
    /**
     * Get the hashCode of this Movie.
     * 
     * hashCode is implemented so that the hashCode/Equals requirements are fulfilled in all cases.
     * a.equals(b) => a.hashCode() == b.hashCode()
     * 
     * @return a non-unique int representing this Movie.
     */
    @Override
    public int hashCode() {
        return this.movieId;
    }
}