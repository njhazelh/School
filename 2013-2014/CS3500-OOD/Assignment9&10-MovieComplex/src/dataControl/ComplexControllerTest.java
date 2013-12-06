/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
package dataControl;

import java.util.ArrayList;
import java.util.Arrays;

import org.junit.Assert;
import org.junit.Test;

/**
 * ComplexControllerTest tests the functionality of the ComplexController class
 * in dataControl
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class ComplexControllerTest {

    /**
     * Test ComplexController
     */
    @Test
    public void test() {
        ComplexController control = new ComplexController();
        Price p1 = new Price("child", 1000, 1);
        Price p2 = new Price("adult", 1200, 2);

        // Get Movies
        Assert.assertTrue("control movies",
            control.getMovies().equals(new ArrayList<Movie>()));
        Assert.assertTrue("control theaters",
            control.getTheaters().equals(new ArrayList<Theater>()));
        
        // Add data
        control.addMovie("a", 600);
        control.addMovie("b", 400);
        
        // Check movie by Id when they're hidden
        Assert.assertEquals("movie by id", control.getMovieByID(1), control
            .getMovies().get(0));
        Assert.assertEquals("movie by id 2", control.getMovieByID(2), control
            .getMovies().get(1));
        
        // Add More Data
        control.addPrice(p1);
        control.addPrice(p2);
        control.addPrice(p1);
        control.addTheater("ta", 0, false, 100);
        control.addTheater("tb", 1, true, 300);
        control.addEvent(control.getMovieByID(1), control.getTheaterByID(1),
            ComplexController.convertMinsInDayToEpoch(0));
        control.addEvent(control.getMovieByID(2), control.getTheaterByID(2),
            ComplexController.convertMinsInDayToEpoch(20));
        control.addEvent(control.getMovieByID(2), control.getTheaterByID(2),
            ComplexController.convertMinsInDayToEpoch(50));
        
        // Get prices
        Assert
            .assertTrue(
                "prices",
                control.getPrices().equals(
                    new ArrayList<Price>(Arrays.asList(p1, p2))));
        
        // Check time conversion
        Assert.assertEquals("ms->day->ms", ComplexController
            .convertEpochToSecsInDay(ComplexController
                .convertMinsInDayToEpoch(600)),
            600 * 60);

        // CHECK THE CURRENT MOVIES
        Assert.assertEquals("current movies",
            control.getCurrentMovies().get(0),
            control.getMovieByID(1));
        Assert.assertEquals("current movies 2",
            control.getCurrentMovies().get(1),
            control.getMovieByID(2));

        // FIND AN EVENT
        Assert.assertEquals(
            "find event",
            control.findEvent(1, 1, 0),
            control.getMovieByID(1).getEvents().get(0));
        Assert.assertEquals(
            "find event",
            control.findEvent(2, 2, 50),
            control.getMovieByID(2).getEvents().get(1));

        // Get Movies by ID when showing
        Assert.assertEquals("movie by id", control.getMovieByID(1), control
            .getMovies().get(0));
        Assert.assertEquals("movie by id 2", control.getMovieByID(2), control
            .getMovies().get(1));

        // Empty sales
        Assert.assertTrue("get sales",
            control.getSales().equals(new ArrayList<Sale>()));

        // Get Theaters by ID
        Assert.assertEquals("theater by id", control.getTheaterByID(1), control
            .getTheaters().get(0));
        Assert.assertEquals("theater by id", control.getTheaterByID(2), control
            .getTheaters().get(1));

        // Check for no sales
        Assert.assertEquals(
            "sales for event",
            control.getSalesForEvent(control.getMovies().get(0).getEvents()
                .get(0))
            [0], 0);
        Assert.assertEquals(
            "sales for event",
            control.getSalesForEvent(control.getMovies().get(0).getEvents()
                .get(0))
            [1], 0);

        // Start and stop the cleaning Thread
        control.startCleaning();
        control.stopCleaning();
    }
}
