/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

/**
 * Price represents the Price of seeing a show for a single demographic.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 * 
 */
public class Price {
    private String    demographic;
    private int       priceInCents;
    private final int id;

    /**
     * CONSTRUCTOR
     * 
     * @param demographic The demographic of this price.
     * @param priceInCents The price in cents.
     * @param id the unique id of the price
     */
    public Price(String demographic, int priceInCents, int id) {
        this.demographic = demographic;
        this.priceInCents = priceInCents;
        this.id = id;
    }

    /**
     * Does that Object equal this Price?
     * 
     * @param that The Object to compare this to.
     * @return true iff that is an instance of Price with the same cost an
     *         demographic.
     */
    @Override
    public boolean equals(Object that) {
        return (that instanceof Price)
                && (((Price) that).priceInCents == this.priceInCents)
                && ((Price) that).demographic.equals(this.demographic)
                && (((Price) that).id == this.id);
    }

    /**
     * @return the demographic
     */
    public String getDemographic() {
        return this.demographic;
    }

    /**
     * @return the id
     */
    public int getID() {
        return this.id;
    }

    /**
     * @return the priceInCents
     */
    public int getPriceInCents() {
        return this.priceInCents;
    }

    /**
     * @param demographic the demographic to set
     */
    void setDemographic(String demographic) {
        this.demographic = demographic;
    }

    /**
     * @param priceInCents the priceInCents to set
     */
    void setPriceInCents(int priceInCents) {
        this.priceInCents = priceInCents;
    }

    /**
     * Convert this price to a String
     * 
     * @return <demographic>: $<dollars>.<cents>
     */
    @Override
    public String toString() {
        return String.format("%s: $%d.%02d", this.demographic,
                this.priceInCents / 100, this.priceInCents % 100);
    }
}
