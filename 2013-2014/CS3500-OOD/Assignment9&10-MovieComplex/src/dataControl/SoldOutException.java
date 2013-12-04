/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

/**
 * SoldOutException represents the case where somehow checks get buypassed, and
 * the ComplexController attempts to purchase a Ticket to a sold out event.
 * 
 * @author Nick Jones
 * @version 12/3/2013
 */
public class SoldOutException extends RuntimeException {

    /**
     * Apparently I need this.
     */
    private static final long serialVersionUID = 3168303764600487546L;

    /**
     * CONSTRUCTOR
     */
    public SoldOutException() { }
    
    /**
     * @param message The message of this exception
     */
    public SoldOutException(String message) {
        super(message);
    }

    /**
     * @param cause The reason this was thrown
     */
    public SoldOutException(Throwable cause) {
        super(cause);
    }

    /**
     * @param message The message of this Exception
     * @param cause The reason this was thrown
     */
    public SoldOutException(String message, Throwable cause) {
        super(message, cause);
    }
}
