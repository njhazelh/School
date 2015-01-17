#DNS-Not-Shellception
###Victor Monterroso and Nicholas Jones
###CS3600, Spring 2014: Project 3
========================================

##Final Submission
------------------

###Approach
-----------
The difficult parts of this project were the parsing of the packets, and the 
requirement that we convert between normal dotted domain names and the dns 
name format, which may include pointers.  The packet parsing was difficult, 
becuase it required us to access specific bits or bytes at a time, so if we 
weren't careful we could end up accessing data in the wrong place or in the 
wrong order.  The conversion between names was difficult, because we needed to 
follow pointers all over the place and still be able to calculate the correct
size of a converted name in order to allocate enough memory for it.

In order to parse the packet, we wrote functions that parsed or generated 
specific parts of the packet.  For example, when we recieved a packet, we put
all the answer information into Answer structures in an array.  This allowed us 
to work with the data in a much more intuitive manner.

###Testing
----------
We tested our code by comparing a series of more complicated domain names on it.
For example, google.com and twitter.com.  Once we passed all the tests on the 
project server we also sent some requests to public DNS servers such as 8.8.8.8
to see how our results compared.

###Extra Credit
---------------
We completed the extra credit for Name and Mail Server lookups.  Adding this 
functionality was pretty simple after we had completed the rest of the project,
since we already had the functions for converting the names, and we only had
to change the QTYPE in the requests.

##MileStone
-----------
For the milestone, our project is to be able to successfully send the 
appropriate packet in DNS format that inquires about a particular domain name. 

A challenge we faced in completing the milestone was dealing with Endianness and
being slightly confused by the fact that bits were being shifted around within
the bytes. Rather than dealing with bits that were shifting around, we made the
observation that the header part of the packet is already predefined and set for
all outgoing packet for this project. This enabled us to use one char *buffer
and put numeric values whose bits corresponded to the order of the bitfields in
the header. This avoided the bits being shifted around because they were within
numeric values and also helped us by not having to worry about where bits would
get shifted if we had made a structure with bitfields. 

For the domain name portion of the outgoing packet, which is the only section of
variable size, we knew we could determine the size that was needed based on the
number of '.' characters in the domain name, which act as a delimiter and are
replaced by the size of each section. Using this knowledge, we were able to
implement a function which set an incoming domain name into proper format. 

Once that was finished, we just made a bigger buffer and used memcpy to pack all
the relevant sections of the packet together.

