/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.NoSuchElementException;

/**
 * ComplexController is a data manager (DataBase) for a movie complex. It keeps
 * track of all the data of the Movie complex and preserves the data
 * requirements.
 * 
 * INVARIANTS:
 * - NO TWO EVENTS CAN HAPPEN AT THE SAME TIME IN THE SAME THEATER
 * - AN EVENT CANNOT SELL MORE TICKETS THAN THERE ARE SEATS AVAILABLE.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class ComplexController implements Runnable {
    /**
     * Take the time in milliseconds since epoch and convert it into seconds
     * since the start of the day.
     * 
     * time must be some time today.
     * 
     * @param time time in milliseconds since epoch
     * @return time in seconds since the start of today.
     */
    public static int convertEpochToSecsInDay(long time) {
        GregorianCalendar dayStart = new GregorianCalendar();
        dayStart.set(Calendar.HOUR, 0);
        dayStart.set(Calendar.MINUTE, 0);
        dayStart.set(Calendar.SECOND, 0);
        dayStart.set(Calendar.MILLISECOND, 0);

        return (int) (time - dayStart.getTimeInMillis()) / 1000;
    }

    /**
     * Convert a time of today represented by minutes since 12am into
     * milliseconds since epoch
     * 
     * @param time time of today represented as minutes since 12am
     * @return milliseconds since epoch at time given
     */
    public static long convertMinsInDayToEpoch(int time) {
        GregorianCalendar startTime = new GregorianCalendar();
        startTime.set(Calendar.HOUR, time / 60);
        startTime.set(Calendar.MINUTE, time % 60);
        startTime.set(Calendar.SECOND, 0);
        startTime.set(Calendar.MILLISECOND, 0);

        return startTime.getTimeInMillis();
    }

    private ArrayList<Movie>   moviesHidden; // Movies without future Events.
    private ArrayList<Movie>   moviesShowing; // Movies with future Events.
    private ArrayList<Theater> theaters; // Theaters to have Events in
    private ArrayList<Sale>    sales; // Sales of Tickets to Events.
    private ArrayList<Price>   prices; // Prices of shows for different people
    
    private int                numMovies   = 0; // The Number of Movies created.
    private int                numTheaters = 0; // The Number of Theaters.
    private int                numEvents   = 0; // The Number of Events created.

    private boolean            cleaning    = false; // cleaner thread running?

    /**
     * CONSTRUCTOR
     */
    public ComplexController() {
        this.moviesHidden = new ArrayList<Movie>();
        this.moviesShowing = new ArrayList<Movie>();
        this.prices = new ArrayList<Price>();
        this.sales = new ArrayList<Sale>();
        this.theaters = new ArrayList<Theater>();
    }

    /**
     * Add an event.
     * 
     * @param movie The Movie to watch
     * @param theater The Theater to watch it in.
     * @param startTime The time the movie starts in milliseconds since epoch
     * @throws OverlappingEventException When timing overlaps with another event
     *         in the given Theater.
     */
    public void addEvent(Movie movie, Theater theater, long startTime)
        throws OverlappingEventException {
        Event temp = new Event(++this.numEvents, movie, theater, startTime);

        try {
            theater.addEvent(temp);
            movie.addEvent(temp);

            // Move Movie from hidden to showing
            if (this.moviesHidden.contains(movie)) {
                this.moviesShowing.add(movie);
                this.moviesHidden.remove(movie);
            }
        }
        catch (OverlappingEventException e) {
            this.numEvents--;
            throw e;
        }
    }

    /**
     * Add a Movie to the list of possible Movies for Events.
     * 
     * @param title The title of the Movie
     * @param lengthInSeconds The length of the Movie in seconds
     */
    public void addMovie(String title, int lengthInSeconds) {
        this.moviesHidden.add(new Movie(++this.numMovies, title,
            lengthInSeconds));
    }

    /**
     * Adds the given price to the list of prices.
     * If demographic already exists, then it swaps the cost with the new cost.
     * 
     * @param price The new price to add.
     */
    public void addPrice(Price price) {
        for (Price p : this.prices) {
            if (p.getDemographic().equals(price.getDemographic())) {
                p.setPriceInCents(price.getPriceInCents());
                return;
            }
        }
        // Only gets here if no matching demographic
        this.prices.add(price);
    }

    /**
     * Add another Theater.
     * Used for setting up the Complex. Theaters don't just pop into existence.
     * 
     * @param name the name of this theater.
     * @param basePrice The base price for all Events in this Theater.
     * @param isLuxury true = it's luxury, false = it's normal
     * @param size The number of seats in this Theater.
     */
    public void addTheater(String name, int basePrice, boolean isLuxury,
        int size) throws NoSuchElementException {
        this.theaters.add(new Theater(name, ++this.numTheaters, basePrice,
            isLuxury, size));
    }

    /**
     * Puchase a single Ticket.
     * There must be a seat available for the Event on the Ticket
     * 
     * @param s The Sale representing a ticket
     * @throws SoldOutException if ticket not available
     */
    void buyTicket(Sale s) throws SoldOutException {
        if (!s.getEvent().isSoldOut()) {
            s.getEvent().fillSeats(1);
            this.sales.add(s);
        }
        else {
            throw new SoldOutException(s.getEvent() + " is sold out");
        }
    }

    /**
     * Buy all the tickets in the given list.
     * All tickets in the given list must be available for order to work,
     * otherwise, no Tickets with be purchased.
     * 
     * @param tickets The tickets to purchase (Sales in each array are for same
     *        event.)
     * @return A List of the Events where there are not enough seats left
     */
    public ArrayList<Event> buyTickets(ArrayList<ArrayList<Sale>> tickets) {
        ArrayList<Event> notEnough = new ArrayList<Event>();

        // Check that all tickets are available
        for (ArrayList<Sale> oneEvent : tickets) {
            if (!oneEvent.get(0).getEvent().hasNTickets(oneEvent.size())) {
                notEnough.add(oneEvent.get(0).getEvent());
            }
        }

        // Buy Tickets
        if (notEnough.size() == 0) {
            for (ArrayList<Sale> oneEvent : tickets) {
                for (Sale s : oneEvent) {
                    this.buyTicket(s);
                }
            }

            // RETURN EMPTY LIST OF SOLDOUT EVENTS
            return notEnough;
        }
        else {
            // RETURN LIST OF SOLDOUT EVENTS
            return notEnough;
        }
    }

    /**
     * Find the Event with the given characteristics
     * 
     * @param movieNumber The movie number of the movie of the Event
     * @param theaterNumber The theater number of the Theater of the Evnet
     * @param startTime The Time that the event starts in ms since epoch
     * @return The Event matching the description.
     * @throws NoSuchElementException when no such Event exists
     */
    public Event findEvent(int movieNumber, int theaterNumber, long startTime)
        throws NoSuchElementException {
        Movie m = this.getMovieByID(movieNumber); // For the exception.
        Theater theater = this.getTheaterByID(theaterNumber); // also may throw

        // Find the Event
        for (Event e : theater.getEvents()) {
            int id = e.getMovie().getID();
            long start = ComplexController.convertEpochToSecsInDay(e
                .getStartTime()) / 60;
            boolean t1 = (id == movieNumber);
            boolean t2 = (start == startTime);
            if (t1 && t2) {
                return e;
            }
        }

        // We know that theater exists and Movie exists because otherwise we'd
        // have thrown an error already.
        throw new NoSuchElementException(String.format(
            "No Event showing %s in %s at %d", m, theater, startTime));
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
     * Get a Movie by its ID number
     * 
     * @param id the unique id number to look for.
     * @return The Movie matching that ID number
     * @throws NoSuchElementException when no Movie with id.
     */
    public Movie getMovieByID(int id) {
        // Search though Movies without Events.
        for (Movie m : this.moviesHidden) {
            if (m.getID() == id) {
                return m;
            }
        }

        // Search throw Movies with Events
        for (Movie m : this.moviesShowing) {
            if (m.getID() == id) {
                return m;
            }
        }

        // No Movie with id
        throw new NoSuchElementException(String.format("No %d movie", id));
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
     * Gets the costs of shows for different groups of people
     * 
     * @return the prices of different groups
     */
    public ArrayList<Price> getPrices() {
        return new ArrayList<Price>(this.prices);
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
     * Get the sales for an event for each price in order of the price ID
     * 
     * @param e The Event to find sales for.
     * @return The sales of an event for each price ordered by the price ID.
     */
    public int[] getSalesForEvent(Event e) {
        int[] eventSales = new int[this.prices.size()];
        Arrays.fill(eventSales, 0);

        for (Sale s : this.sales) {
            if (s.getEvent().equals(e)) {
                eventSales[s.getPrice().getID() - 1]++;
            }
        }

        return eventSales;
    }

    /**
     * Get a Theater by its ID number.
     * 
     * @param id the unique id number to look for.
     * @return The Theater matching that ID number.
     * @throws NoSuchElementException when no Theater with id.
     */
    public Theater getTheaterByID(int id) throws NoSuchElementException {
        // Search through Theaters
        for (Theater t : this.theaters) {
            if (t.getID() == id) {
                return t;
            }
        }

        // No Theater with id
        throw new NoSuchElementException(String.format("No %d theater", id));
    }

    /**
     * Get the theaters in this complex
     * 
     * @return the theaters in this complex
     */
    public ArrayList<Theater> getTheaters() {
        return new ArrayList<Theater>(this.theaters);
    }

    /**
     * RUN THIS IN THE BACKGROUND:
     * - hide events in the past.
     * - sleep for 30 seconds.
     * - repeat
     * 
     * Invoke using startCleaning()
     */
    @Override
    public void run() {
        while (this.cleaning) {
            System.out.println("Cleaning Events");

            // HIDE PAST EVENTS
            for (Theater t : this.theaters) {
                for (int i = 0; i < t.getEvents().size(); i++) {
                    Event e = t.getEvents().get(i);

                    if (e.getEndTime() < System.currentTimeMillis()) {
                        e.hide();
                    }
                }
            }

            try {
                Thread.sleep(30000); // SLEEP FOR 30 SECONDS
            }
            catch (InterruptedException e) {
                // DO NOTHING
            }
        }
    }

    /**
     * As time passes Events will pass. This function ensures that the list of
     * future events is correct.
     */
    public void startCleaning() {
        // Start the Thread for removing old Events
        Thread t = new Thread(this);
        this.cleaning = true;
        t.start();
    }

    /**
     * Stop cleaning Events as they pass.
     */
    public void stopCleaning() {
        this.cleaning = false;
    }
}
