package dataControl;

/**
 * Rating refers to the rating of a movie according to the MPAA rating system.
 * 
 * G - General Audiences (Everyone)
 * PG - Parental Guidance (Some material not suitable for children)
 * PG_13 - Parents Strongly Cautioned (May be inappropriate for children under 13.)
 * R - Restricted (Children under 17 require accompanying parent or guardian)
 * NC_17 - No one 17 and under admitted. (Adults only)
 * 
 * @author Nick Jones
 * @version 11/25/2013
 *
 */
public enum Rating {
    G,
    PG,
    PG_13,
    R,
    NC_17;
}
