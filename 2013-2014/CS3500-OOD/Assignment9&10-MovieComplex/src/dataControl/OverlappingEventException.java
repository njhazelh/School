/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

/**
 * OverlappingEventException represents the instance where the ComplexController
 * attempts to create an Event in a Theater at the same time as another Event
 * in the same Theater
 * 
 * @author Nick Jones
 * @version 2013
 */
public class OverlappingEventException extends RuntimeException {

    /**
     * Apparently I need this.
     */
    private static final long serialVersionUID = -6611975394243731003L;

    /**
     * CONSTRUCTOR
     */
    public OverlappingEventException() {
        // DO NOTHING
    }

    /**
     * @param msg The message of this exception
     */
    public OverlappingEventException(String msg) {
        super(msg);
    }

    /**
     * @param msg The message of this Exception
     * @param cause The reason this was thrown
     */
    public OverlappingEventException(String msg, Throwable cause) {
        super(msg, cause);
    }
}
