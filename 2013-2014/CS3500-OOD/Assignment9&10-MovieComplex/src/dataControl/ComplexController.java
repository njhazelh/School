/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;
import java.lang.Thread;

/**
 * ComplexController is a data manager (DataBase) for a movie complex.  It keeps
 * track of all the data of the Movie complex and preserves the data requirements.
 * 
 * INVARIANTS:
 *   - NO TWO EVENTS CAN HAPPEN AT THE SAME TIME IN THE SAME THEATER
 *   - AN EVENT CANNOT SELL MORE TICKETS THAN THERE ARE SEATS AVAILABLE.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class ComplexController implements Runnable {
    private ArrayList<Movie> moviesHidden; // Movies without future Events.
    private ArrayList<Movie> moviesShowing; // Movies with future Events.
    private ArrayList<Theater> theaters; // Theaters to have Events in
    private ArrayList<Sale> sales; // Sales of Tickets to Events.
    
    private int numMovies = 0; // The Number of Movies created.
    private int numTheaters = 0; // The Number of Theaters.
    private int numEvents = 0; // The Number of Events created.
    
    /**
     * RUN THIS IN THE BACKGROUND:
     *  - hide events in the past.
     *  - sleep for 30 seconds.
     *  - repeat
     */
    public void run() {
        while (true) {
            System.out.println("Cleaning Events");
            
            // HIDE PAST EVENTS
            for (Theater t : this.theaters) {
                for (int i = 0; i < t.getEvents().size(); i++) {
                    Event e  = t.getEvents().get(i);
                    
                    if(e.getEndTime() < System.currentTimeMillis()) {
                        e.hide();
                    }
                }
            }
            
            try {
                Thread.sleep(30000); // SLEEP FOR 30 SECONDS
            }
            catch(InterruptedException e) {
                // DO NOTHING
            }
        }
    }
    
    /**
     * CONSTRUCTOR
     */
    public ComplexController() {
        // Start the Thread for removing old Events
        Thread t = new Thread(this);
        t.start();
    }
    
    /**
     * Get a list of all the Movies ever added to this Complex.
     * 
     * @return All the Movies.
     */
    public ArrayList<Movie> getMovies() {
        ArrayList<Movie> temp = new ArrayList<Movie>(this.moviesHidden);
        temp.addAll(this.moviesShowing);
        return temp;
    }
    
    /**
     * Get a list of all the sales made by this Complex.
     * 
     * @return All the Sales
     */
    public ArrayList<Sale> getSales() {
        return new ArrayList<Sale>(this.sales);
    }
    
    /**
     * Get a list of all the Movies with Events listed under Theater.
     * 
     * @return Movies that will be shown in the future.
     */
    public ArrayList<Movie> getCurrentMovies() {
        return new ArrayList<Movie>(this.moviesShowing);
    }
    
    /**
     * Add a Movie to the list of possible Movies for Events.
     * 
     * @param title The title of the Movie
     * @param lengthInSeconds The length of the Movie in seconds
     * @param rating The MPAA rating of the Movie
     */
    public void addMovie(String title, int lengthInSeconds, Rating rating) {
        this.moviesHidden.add(new Movie(numMovies++, title, lengthInSeconds, rating));
    }
    
    /**
     * Add an event.
     * 
     * @param movie The Movie to watch
     * @param theater The Theater to watch it in.
     * @param startTime The time the movie starts in milliseconds since epoch
     * @throws OverlappingEventException When timing overlaps with another event in the given Theater.
     */
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
    
    /**
     * Add another Theater.
     * Used for setting up the Complex. Theaters don't just pop into existence.
     * 
     * @param basePrice The base price for all Events in this Theater.
     * @param isLuxury true = it's luxury, false = it's normal
     * @param size The number of seats in this Theater.
     */
    void addTheater(int basePrice, boolean isLuxury, int size) {
        this.theaters.add(new Theater(numTheaters++, basePrice, isLuxury, size));
    }
    
    /**
     * Buy all the tickets in the given list.
     * All tickets in the given list must be available for order to work,
     * otherwise, no Tickets with be purchased.
     * 
     * @param tickets The tickets to purchase
     * @return A List of the Events where there are not enough seats left
     */
    public ArrayList<Event> buyTickets(ArrayList<ArrayList<Ticket>> tickets) {
        ArrayList<Event> notEnough = new ArrayList<Event>();
        
        for (ArrayList<Ticket> subList : tickets) {
            if (subList.get(0).getEvent().hasNTickets(subList.size())) {
                notEnough.add(subList.get(0).getEvent());
            }
        }
        
        if (notEnough.size() == 0) {
            Sale s = new Sale();
            for (ArrayList<Ticket> subList : tickets) {
                for (Ticket t : subList) {
                    this.buyTicket(t);
                    s.addTicket(t);
                }
            }
            this.sales.add(s);
        }
        
        // RETURN LIST OF SOLDOUT EVENTS
        return notEnough;
    }
    
    /**
     * Puchase a single Ticket.
     * There must be a seat available for the Event on the Ticket
     * 
     * @param t The Ticket to buy
     * @throws SoldOutException if ticket not available
     */
    void buyTicket(Ticket t) {
        if (!t.getEvent().isSoldOut()) {
            t.getEvent().fillSeats(1);
        }
        else {
            throw new SoldOutException(t.getEvent() + " is sold out");
        }
    }
}
