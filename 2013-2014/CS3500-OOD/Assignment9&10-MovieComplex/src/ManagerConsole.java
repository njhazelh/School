/* Name: Nicholas Jones
 * Email: njhazelh@zimbra.ccs.neu.edu
 * Comments: n/a
 */
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.InputMismatchException;
import java.util.Scanner;

import dataControl.Event;
import dataControl.Movie;
import dataControl.Price;
import dataControl.Theater;

/**
 * ManagerConsole provides some basic functions for the manager.
 * 
 * @author Nick Jones
 * @version 12/4/2013
 */
public class ManagerConsole {
    /**
     * MAIN
     * 
     * @param args cmd arguments
     */
    public static void main(String[] args) {
        ManagerConsole mc = new ManagerConsole();
        mc.run();
    }

    // FIELDS
    private TicketSales control;
    private boolean     running = true;
    private PrintStream out     = System.out;
    private Scanner     in      = new Scanner(System.in);

    /**
     * CONSTRUCTOR
     */
    public ManagerConsole() {
        this.control = new TicketSales();
    }

    /**
     * Add an event to the complex
     */
    public void addEvent() {
        int movie = this.requireInt("Enter the movie number: ");
        int theater = this.requireInt("Enter the theater number: ");
        int start = this
            .requireInt("Enter the minutes since 12am at the start: ");

        this.control.addShow(String.format("%d,%d,%d", movie, theater, start));
    }

    /**
     * Add a Movie to the Complex
     */
    public void addMovie() {
        String name = this.requireString("Enter the title: ");
        int length = this.requireInt("Enter the length in minutes");

        this.control.addMovie(String.format("%s:%d", name, length));
    }

    /**
     * Add a Price to the Complex
     */
    public void addPrice() {
        String demographic = this.requireString("Enter the demographic name: ");
        int price = this
            .requireInt("Enter the price of the ticket in dollars > 0: ");

        this.control.addPrice(String.format("%s:%d", demographic, price));
    }

    /**
     * Add a theater to the Complex
     */
    public void addTheater() {
        String name = this.requireString("Enter the name: ");
        int size = this.requireInt("Enter the size: ");
        this.control.addTheater(String.format("%s:%d", name, size));
    }

    /**
     * Analyze the line for significance and run it.
     * 
     * @param line the line to run
     */
    public void analyzeAndRunLine(String line) {
        ArrayList<String> parts = this.tokenizeLine(line);

        if (parts.size() > 0) {
            String first = parts.get(0);

            if (first.equals("addMovie")) {
                this.addMovie();
            }
            else if (first.equals("addEvent")) {
                this.addEvent();
            }
            else if (first.equals("report")) {
                this.report();
            }
            else if (first.equals("log")) {
                this.log();
            }
            else if (first.equals("addPrice")) {
                this.addPrice();
            }
            else if (first.equals("exit")) {
                this.running = false;
            }
            else if (first.equals("addTheater")) {
                this.addTheater();
            }
            else if (first.equals("list")) {
                parts.remove(0);
                this.list(parts);
            }
            else {
                this.printHelp();
            }
        }
        else {
            this.printHelp();
        }
    }

    /**
     * List whatever is in the args
     * 
     * @param args argument about what to list
     */
    public void list(ArrayList<String> args) {
        if (args.size() == 0) {
            this.printListHelp();
        }
        else if (args.get(0).equals("movies")) {
            this.listMovies();
        }
        else if (args.get(0).equals("theaters")) {
            this.listTheaters();
        }
        else if (args.get(0).equals("events")) {
            this.listEvents();
        }
        else if (args.get(0).equals("prices")) {
            this.listPrices();
        }
        else {
            this.printListHelp();
        }
    }

    /**
     * List the events
     */
    public void listEvents() {
        ArrayList<Movie> movies = this.control.getController().getMovies();

        for (Movie m : movies) {
            for (Event e : m.getEvents()) {
                System.out.println(e);
            }
        }
    }

    /**
     * List the movies
     */
    public void listMovies() {
        ArrayList<Movie> movies = this.control.getController().getMovies();

        for (Movie m : movies) {
            System.out.println(m);
        }
    }

    /**
     * List the prices
     */
    public void listPrices() {
        ArrayList<Price> prices = this.control.getController().getPrices();

        for (Price p : prices) {
            System.out.println(p);
        }
    }

    /**
     * List the theaters
     */
    public void listTheaters() {
        ArrayList<Theater> theaters = this.control.getController()
            .getTheaters();

        for (Theater t : theaters) {
            System.out.println(t);
        }
    }

    /**
     * Print the log
     */
    public void log() {
        this.out.println(this.control.logReport());
    }

    /**
     * Print the help info
     */
    public void printHelp() {
        String[][] commands = {
            { "addMovie", "add a movie to the complex" },
            { "addPrice", "add/change a price to the complex" },
            { "report", "give a management report" },
            { "addEvent", "add an event to the complex" },
            { "log", "print the error log" },
            { "addTheater", "add a theater to the complex" },
            { "exit", "exit the command line" },
            { "list", "list either movies, prices, theaters, or events" } };
        this.out.println("Commands:");
        for (String[] cmd : commands) {
            this.out.println(String.format("%s -- %s", cmd[0], cmd[1]));
        }
    }

    /**
     * Print the help info for list
     */
    public void printListHelp() {
        this.out.println("Syntax: list <what to list>");
        String[][] commands = {
            { "movies", "list all movies" },
            { "theaters", "list all theaters" },
            { "events", "list all events" },
            { "prices", "list all prices" } };
        this.out.println("List commands:");
        for (String[] cmd : commands) {
            this.out.println(String.format("%s -- %s", cmd[0], cmd[1]));
        }
    }

    /**
     * Print the manager report
     */
    public void report() {
        this.control.newManReport();
        this.out.println(this.control.managerReport());
    }

    /**
     * Get an int from the user
     * 
     * @param prompt the prompt for the int
     * @return the int received
     */
    public int requireInt(String prompt) {
        while (true) {
            try {
                this.out.print(prompt);
                int i = Integer.parseInt(this.in.nextLine());
                if (i < 0) {
                    throw new InputMismatchException();
                }
                return i;
            }
            catch (Exception e) {
                this.out.println("Please enter a positive integer");
                this.out.flush();
            }
        }
    }

    /**
     * Get a String from the user
     * 
     * @param prompt the prompt for the String
     * @return the String received
     */
    public String requireString(String prompt) {
        this.out.print(prompt);
        this.out.flush();
        String i = this.in.nextLine();

        return i;
    }

    /**
     * run the console
     */
    public void run() {
        do {
            this.out.print("manager> ");
            String line = this.in.nextLine();
            this.analyzeAndRunLine(line);
        } while (this.running);
        this.in.close();
    }

    /**
     * Break a line along its whitespace.
     * 
     * @param line the line to tokenize
     * @return the tokenized line
     */
    public ArrayList<String> tokenizeLine(String line) {
        ArrayList<String> parts = new ArrayList<String>();
        Scanner scnr = new Scanner(line);

        while (scnr.hasNext()) {
            parts.add(scnr.next());
        }

        scnr.close();
        return parts;
    }

}
