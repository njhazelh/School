/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

/**
 * Ticket represents all tickets to a particular event for a particular demographic and price.
 * 
 * If two people purchase the same ticket, that Ticket is only one object in the ComplexController.
 * 
 * @author Nick Jones
 * @version 12/3/2013
 */
public class Ticket {
    private Event event;
    private String demographic;
    private int priceInCents;
    
    /**
     * CONSTRUCTOR
     * @param event The event that this ticket is for
     * @param demographic The demographic that this ticket is for
     * @param priceInCents The price of this ticket in cents.
     */
    Ticket(Event event, String demographic, int priceInCents) {
        this.event = event;
        this.demographic = demographic;
        this.priceInCents = priceInCents;
    }
    
    /**
     * What Event is this Ticket for?
     * 
     * @return The Event this Ticket is for.
     */
    public Event getEvent() {
        return this.event;
    }
    
    /**
     * What demographic is this Ticket for?
     * Examples: Senior, Child, Adult...
     *  
     * @return The Demographic of this Ticket
     */
    public String getDemographic() {
        return this.demographic;
    }
    
    /**
     * What is the price of this Ticket
     * 
     * @return The price of this Ticket in cents.
     */
    public int getPrice() {
        return this.priceInCents;
    }
}
