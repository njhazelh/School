/**
 * 
 */
package dataControl;

/**
 * @author Nick
 * 
 */
public class OverlappingEventException extends RuntimeException {

    /**
     * 
     */
    private static final long serialVersionUID = -6611975394243731003L;

    public OverlappingEventException() {
        super();
    }

    public OverlappingEventException(String msg) {
        super(msg);
    }

    public OverlappingEventException(String msg, Throwable cause) {
        super(msg, cause);
    }

    public OverlappingEventException(Throwable cause) {
        super(cause);
    }
}
