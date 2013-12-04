package dataControl;

import java.util.ArrayList;

/**
 * 
 * @author Nick
 *
 */
public class ComplexController {
    private ArrayList<Movie> moviesHidden;
    private ArrayList<Movie> moviesShowing;
    private ArrayList<Theater> theaters;
    private ArrayList<Sale> sales;
    
    private int numMovies = 0;
    private int numTheaters = 0;
    private int numEvents = 0;
    
    public void ComplexController() {
        numTheaters = 4;
    }
    
    public ArrayList<Movie> getMovies() {
        ArrayList<Movie> temp = new ArrayList<Movie>(this.moviesHidden);
        temp.addAll(this.moviesShowing);
        return temp;
    }
    
    public ArrayList<Sale> getSales() {
        return new ArrayList<Sale>(this.sales);
    }
    
    public ArrayList<Movie> getCurrentMovies() {
        return new ArrayList<Movie>(this.moviesShowing);
    }
    
    public void addMovie(String title, int lengthInSeconds, Rating rating) {
        this.moviesHidden.add(new Movie(numMovies++, title, lengthInSeconds, rating));
    }
    
    public void addEvent(Movie movie, Theater theater, long startTime) throws OverlappingEventException {
        Event temp = new Event(numEvents++, movie, theater, startTime);
        
        try {
            theater.addEvent(temp);
            if (this.moviesHidden.contains(movie)) {
                this.moviesShowing.add(movie);
                this.moviesHidden.remove(movie);
            }
        }
        catch (OverlappingEventException e) {
            numEvents--;
            throw e;
        }
    }
    
    void addTheater() {
        // TODO
    }
    
    public void buyTicket() {
        
    }
}
