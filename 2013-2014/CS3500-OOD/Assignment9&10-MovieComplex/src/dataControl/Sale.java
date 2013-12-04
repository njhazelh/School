/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;

/**
 * Sale keeps track of a single Sale of Tickets.
 * 
 * Tickets can be to different Events at different times.
 * All tickets in a Sale ensure access to a seat the the purchased event.
 * 
 * @author Nick Jones
 * @version 12/3/2013
 */
public class Sale {
    // The list of tickets in this Sale.
    private ArrayList<Ticket> tickets = new ArrayList<Ticket>();
    
    /**
     * Add a single <code>Ticket</code> to this <code>Sale</code>.
     * 
     * @param t The <code>Ticket</code> to add to this <code>Sale</code>.
     */
    void addTicket(Ticket t) {
        tickets.add(t);
    }
    
    /**
     * Get a list of the <code>Tickets</code> in this <code>Sale</code>.
     * 
     * @return The <code>Tickets</code> in this <code>Sale</code>.
     */
    public ArrayList<Ticket> getTickets() {
        return new ArrayList<Ticket>(this.tickets);
    }
    
    /**
     * How many <code>Tickets</code> are in this Sale?
     * 
     * @return The number of Tickets in this Sale.
     */
    public int ticketsInSale() {
        return this.tickets.size();
    }
}
