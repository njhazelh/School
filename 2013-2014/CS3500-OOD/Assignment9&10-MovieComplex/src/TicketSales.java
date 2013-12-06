/* Name; Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.InputMismatchException;
import java.util.NoSuchElementException;
import java.util.Scanner;

import dataControl.ComplexController;
import dataControl.Event;
import dataControl.Movie;
import dataControl.Price;
import dataControl.Sale;
import dataControl.Theater;

/**
 * TicketSales is the class required by WebCat
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class TicketSales {
    /**
     * MAIN
     * 
     * @param argv cmd args
     */
    public static void main(String[] argv) {
        TicketSales prog = new TicketSales();
        prog.initCinema("cinema.txt");
        prog.processOrders("orders.txt");
        String sales = prog.reportSales();
        String manager = prog.managerReport();
        String log = prog.logReport();

        System.out.println(String.format("SALES\n%sMANAGER\n%sLOG\n%s", sales,
                manager, log));
    }
    
    // FIELDS
    private ComplexController control     = new ComplexController();
    private ArrayList<String> log         = new ArrayList<String>();
    private ArrayList<String> manReport   = new ArrayList<String>();

    private ArrayList<String> salesReport = new ArrayList<String>();

    /**
     * Add the Movie with the information in the given line
     * 
     * Line should be of format: <title>:<length in minutes>
     * 
     * @param line The information about the Movie to add.
     * @return true iff everything worked
     */
    public boolean addMovie(String line) {
        Scanner lScnr = new Scanner(line);
        lScnr.useDelimiter(":");

        try {
            String title = lScnr.next();
            int lengthInMinutes = lScnr.nextInt();
            this.control.addMovie(title, lengthInMinutes * 60);
            lScnr.close();
            return true;
        }
        catch (Exception e) {
            this.log.add(String.format("Malformed Movie Line: %s", line));
            lScnr.close();
            return false;
        }
    }

    /**
     * Add a new price with the information in the given line.
     * 
     * If the demographic in the line already exists then it swaps out the cost
     * with the new cost.
     * 
     * Line should be of format: <demographic>,<price>
     * 
     * @param line The information about the price too add.
     * @return true iff everything worked.
     */
    public boolean addPrice(String line) {
        Scanner lScnr = new Scanner(line);
        lScnr.useDelimiter(":");

        try {
            String demog = lScnr.next();
            int costInCents = lScnr.nextInt() * 100;
            this.control.addPrice(new Price(demog, costInCents, this.control
                    .getPrices().size() + 1));
            lScnr.close();
            return true;
        }
        catch (Exception e) {
            this.log.add(String.format("Malformed Price Line: %s", line));
            lScnr.close();
            return false;
        }
    }

    /**
     * Add a show with the information in the given line.
     * Line should be of format: <movie index>,<theater index>,<start time>
     * 
     * @param line The information to add.
     * @return true iff everything worked.
     */
    boolean addShow(String line) {
        Scanner lScnr = new Scanner(line);
        lScnr.useDelimiter(",");
        int movieNum;
        int theaterNum;
        int start;

        try {
            movieNum = lScnr.nextInt();
            theaterNum = lScnr.nextInt();
            start = lScnr.nextInt();
            Theater theater = this.control.getTheaterByID(theaterNum);
            Movie movie = this.control.getMovieByID(movieNum);
            long startTime = ComplexController.convertMinsInDayToEpoch(start);
            this.control.addEvent(movie, theater, startTime);
            lScnr.close();
            return true;
        }
        // Catch input or data Exceptions
        catch (Exception e) {
            // Malformed input
            if ((e instanceof NoSuchElementException)
                    || (e instanceof InputMismatchException)
                    || (e instanceof ArrayIndexOutOfBoundsException)) {
                this.log.add(String.format("Malformed Show Line: %s", line));
            }
            // No Theater with ID OR
            // NO Movie with ID OR
            // Show overlaps another show in the same Theater
            else {
                this.log.add(String.format("%s: %s", line, e));
            }
            lScnr.close();
            return false;
        }
    }

    /**
     * Add the Theater with the information in the given line
     * 
     * Line should be of format: <Name>:<size>
     * 
     * @param line The information about the Theater to add.
     * @return true iff everything worked
     */
    public boolean addTheater(String line) {
        Scanner lScnr = new Scanner(line);
        lScnr.useDelimiter(":");

        try {
            String name = lScnr.next();
            int size = lScnr.nextInt();
            this.control.addTheater(name, 0, false, size);
            lScnr.close();
            return true;
        }
        catch (Exception e) {
            this.log.add(String.format("Malformed Theater Line: %s", line));
            lScnr.close();
            return false;
        }
    }

    /**
     * @return the complex controller.
     */
    public ComplexController getController() {
        return this.control;
    }

    /**
     * Init the Complex Controller using the specs in the file.
     * 
     * @param fileName File to init Cinema From
     */
    public void initCinema(String fileName) {
        Scanner scnr = null;
        String mode = null;

        try {
            scnr = new Scanner(new File(fileName));
        }
        catch (FileNotFoundException e) {
            System.err.println(e);
            System.exit(1);
        }

        while (scnr.hasNextLine()) {
            String line = scnr.nextLine();

            // Set Mode
            if (line.equals("Movies") || line.equals("Shows")
                    || line.equals("Theaters") || line.equals("Prices")) {
                mode = line;
                continue;
            }
            // End Operations
            else if (line.equals("End")) {
                break;
            }

            // Add a Movie
            if (mode.equals("Movies")) {
                this.addMovie(line);
            }
            // Add a Show
            else if (mode.equals("Shows")) {
                this.addShow(line);
            }
            // Add a Theater
            else if (mode.equals("Theaters")) {
                this.addTheater(line);
            }
            // Add a Price.
            else if (mode.equals("Prices")) {
                this.addPrice(line);
            }
        }
        scnr.close();
    }

    /**
     * Get a String of all the errors in the log.
     * 
     * 1 error per line.
     * 
     * @return a String of all the errors in the log
     */
    public String logReport() {
        String logString = "";

        for (String s : this.log) {
            logString += s + "\n";
        }

        return logString;
    }

    /**
     * Report to the Manager
     * 
     * @return the manager report
     */
    public String managerReport() {
        String output = "";
        int i = 1;

        for (String s : this.manReport) {
            output += String.format("Report %d\n%s", i++, s);
        }

        return output;
    }

    /**
     * Creates another report for the manager.
     * for each event:
     * <movie id>, <theater num>, <start>, <sales per price>
     * ...
     */
    public void newManReport() {
        String report = "";

        // For each movie
        for (Movie m : this.control.getMovies()) {
            for (Event e : m.getEvents()) {
                String line = "";

                // add title, theater, time
                line += String.format("%s,%s,%d,%d", m.getTitle(), e
                        .getTheater().getName(), ComplexController
                        .convertEpochToSecsInDay(e.getStartTime()) / 60, e
                        .getTheater().getSize());

                // Add sales for each price
                for (int i : this.control.getSalesForEvent(e)) {
                    line += "," + i;
                }

                // Add line to report
                report += line + "\n";
            }
        }
        // store report
        this.manReport.add(report);
    }

    /**
     * Add a new sales report.
     * 
     * @param e event for report
     * @param sales number of tickets purchased for each price.
     * @param worked to make the total cost either sum or 0
     */
    public void newSalesReport(Event e, int[] sales, boolean worked) {
        String report = "";

        report += String.format("%d,%d,%d", e.getMovie().getID(), e
                .getTheater().getID(), ComplexController
                .convertEpochToSecsInDay(e.getStartTime()) / 60);

        for (int i : sales) {
            report += String.format(",%d", i);
        }

        int sum = 0;
        int i = 0;

        if (worked) {
            for (Price p : this.control.getPrices()) {
                sum += (p.getPriceInCents() / 100) * sales[i++];
            }
        }

        this.salesReport.add(report + "," + sum);
    }

    /**
     * Process all the orders in the given file
     * 
     * @param fileName The file to process.
     */
    public void processOrders(String fileName) {
        Scanner scnr = null;
        Scanner lScnr = null;

        try {
            scnr = new Scanner(new File(fileName));
        }
        catch (FileNotFoundException e) {
            System.err.println(e);
            System.exit(1);
        }

        while (scnr.hasNext()) {
            String line = scnr.nextLine();

            if (line.equals("report")) {
                this.newManReport();
            }
            else {
                try {
                    lScnr = new Scanner(line);
                    lScnr.useDelimiter(",");

                    // parse line
                    int movieNumber = lScnr.nextInt();
                    int theaterNumber = lScnr.nextInt();
                    int startTime = lScnr.nextInt();
                    Event event = this.control.findEvent(movieNumber,
                            theaterNumber, startTime);

                    // Get Number of tickets for each price
                    int[] tickets = new int[this.control.getPrices().size()];
                    for (int i = 0; i < this.control.getPrices().size(); i++) {
                        tickets[i] = (lScnr.hasNext() ? lScnr.nextInt() : 0);
                    }

                    // Build Array of Array of Sales for each Price
                    ArrayList<ArrayList<Sale>> tics =
                            new ArrayList<ArrayList<Sale>>();
                    tics.add(new ArrayList<Sale>());

                    for (int i = 0; i < tickets.length; i++) {
                        int j = tickets[i];
                        Sale s = new Sale(this.control.getPrices().get(i),
                                event);
                        for (int k = 0; k < j; k++) {
                            tics.get(0).add(s);
                        }
                    }

                    // buy tickets
                    this.newSalesReport(event, tickets, this.control
                            .buyTickets(tics).size() == 0);

                    lScnr.close();
                }
                catch (Exception e) {
                    // Malformed input
                    if ((e instanceof NoSuchElementException)
                            || (e instanceof InputMismatchException)
                            || (e instanceof ArrayIndexOutOfBoundsException)) {
                        this.log.add(String.format("Malformed Order Line: %s"
                                + e, line));
                    }
                    // No Theater with ID OR
                    // NO Movie with ID OR
                    // Show overlaps another show in the same Theater
                    else {
                        this.log.add(String.format("%s: %s", line, e));
                    }
                    lScnr.close();
                }
            }
        }

        scnr.close();
    }

    /**
     * Report all the sales made.
     * 
     * @return the sales report
     */
    public String reportSales() {
        String report = "";

        for (String s : this.salesReport) {
            report += s + "\n";
        }

        return report;
    }
}
