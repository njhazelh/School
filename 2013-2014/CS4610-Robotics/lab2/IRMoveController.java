package l2;

import java.util.ArrayList;

public class IRMoveController {
    private ArrayList<Reading> readings;

    public IRMoveController() {
        this.readings = new ArrayList<Reading>();
    }

    public Boolean frontIsFree() {
        Double front = this.averageLastTen().front;
        Boolean result = front >= 400;

        // if (result)
        //     System.out.println("front is free: " + front);
        // else
        //     System.out.println("front is not free: " + front);

        return result;
    }

    public Boolean backIsFree() {
        Double back = this.averageLastTen().back;
        Boolean result = back >= 400;

        // if (result)
        //     System.out.println("back is free: " + back);
        // else
        //     System.out.println("back is not free: " + back);

        return result;
    }

    public Double calcAngVel() {
        return 0.0;
    }

    public void addReading(Double front, Double back) {
        readings.add(new Reading(front, back));
        if (readings.size() > 10)
            readings.remove(0);
    }

    private Reading averageLastTen() {
        Double front = 0.0;
        Double back  = 0.0;

        for (Reading r : this.readings) {
            front += r.front;
            back  += r.back;
        }

        if (this.readings.size() != 0) {
            front /= this.readings.size();
            back  /= this.readings.size();
        }

        return new Reading(front, back);
    }

    public Double frontBackDiff() {
        Reading avg = this.averageLastTen();

        return avg.front - avg.back;
    }

    public static class Reading {
        public Double front;
        public Double back;

        public Reading(Double front, Double back) {
            this.front = front;
            this.back = back;
        }
    }
}