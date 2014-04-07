/**
*
*/

package l2;

/**
*
*
*/
public class Line {
    private Double theta;
    private Double xIntercept;
    private Double yIntercept;

    /**
    *
    *
    */
    public Line(Double theta, Double xIntercept, Double yIntercept) {
        this.theta = theta;
        this.xIntercept = xIntercept;
        this.yIntercept = yIntercept;
    }


    /**
    *
    *
    */
    public static Line calcLineByPoints(Double x1, Double y1, Double x2, 
        Double y2) {

        Double theta;
        Double xIntercept;
        Double yIntercept;

        if (x1.equals(x2) && y1.equals(y2)) {
            throw new NoSuchLineException(
                "calcLineByPoints: p1 and p2 cannot be equal");
        }
        else if (y1.equals(y2)) {
            theta = 0.0;
            xIntercept = null;
            yIntercept = y1;
        }
        else if (x1.equals(x2)) {
            theta = Math.PI / 2.0;
            xIntercept = x1;
            yIntercept = null;
        }
        else {
            Double dx = x1 - x2;
            Double dy = y1 - y2;

            theta = Math.atan(dy / dx);
            yIntercept = y1 - dy / dx * x1;
            xIntercept = -yIntercept / ( dy / dx );
        }

        return new Line(theta, xIntercept, yIntercept);
    }

    /**
    *
    *
    */
    public Boolean isOnLine(Double x, Double y, Double theshold) {
        Double m = Math.tan(this.theta);

        if (this.theta == 0.0)
            return y >= this.yIntercept - theshold &&
                   y <= this.yIntercept + theshold;
        else if (this.theta == Math.PI / 2.0)
            return x >= this.xIntercept - theshold &&
                   x <= this.xIntercept + theshold;
        else
            return y >= m * x + yIntercept - theshold &&
                   y <= m * x + yIntercept + theshold;
    }

    /**
    *
    *
    */
    public static class NoSuchLineException extends RuntimeException {
        public NoSuchLineException(String message) {
            super(message);
        }
    }
}