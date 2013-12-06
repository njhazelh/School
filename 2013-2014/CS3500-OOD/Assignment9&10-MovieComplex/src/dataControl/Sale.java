/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

/**
 * Sale keeps track of a single Sale of a Ticket for an event
 * 
 * @author Nick Jones
 * @version 12/3/2013
 */
public class Sale {
    private Price price;
    private Event event;

    /**
     * Constructor
     * @param price The price associated with this sale
     * @param event The event assocaited with this sale.
     */
    public Sale(Price price, Event event) {
        this.price = price;
        this.event = event;
    }

    /**
     * @return the price
     */
    public Price getPrice() {
        return price;
    }

    /**
     * @return the event
     */
    public Event getEvent() {
        return event;
    }
    
}
