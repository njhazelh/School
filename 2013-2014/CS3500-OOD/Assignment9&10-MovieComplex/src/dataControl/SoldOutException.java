/**
 * 
 */
package dataControl;

/**
 * @author Nick
 *
 */
public class SoldOutException extends RuntimeException {

    /**
     * 
     */
    private static final long serialVersionUID = 3168303764600487546L;

    /**
     * 
     */
    public SoldOutException() { }

    /**
     * @param message
     */
    public SoldOutException(String message) {
        super(message);
    }

    /**
     * @param cause
     */
    public SoldOutException(Throwable cause) {
        super(cause);
    }

    /**
     * @param message
     * @param cause
     */
    public SoldOutException(String message, Throwable cause) {
        super(message, cause);
    }
}
