Project 4 - VNTP (VictorNickTransport Protocol)
Victor Monterroso, Nicholas Jones
Systems & Networks (CS3600)
Spring 2014
-------------------------------------------------------------------------------
For the final project, we implemented a version very similar to TCP Reno. The
reason we decided to do this was because it was the variation of TCP that we 
went over in class in detail. Though this project wasn't exactly TCP, as there 
was no bidirectional communication, it was fairly close to it since there were 
ACKs, timeouts, reordering, and a FIN (the EOF packet). 

The biggest challenge for this project was that there were many moving pieces and
various issues that had to be dealt with. We had to deal firstly, we deal with
implementing the sliding window, which involved queueing packets on the sender
side in case there were timeouts. Secondly, we decided to tackle the issue of
reordered packets. In order to deal with it, we had the receiver queue packets
that were received out of order in order to be able to print them to standard 
output in order. Next, we dealt with timeouts. We followed the Reno policy of 
sending duplicate ACKs for packets that are out of order. When 3 duplicate ACKs
have been received by the sender, the sender resends the packet that hasn't gotten
there yet. Lastly, we added a simple checksum in order to handle corruption. We
implemented it over the data we were sending and included it as a field in the 
header. 

For debugging, GDB was complicated because two programs had to be running simultaneously
and it was just going too fast to be able to go at it in a reasonable pace. That is
where mylog came in handy. With it, we were able to output the information that we
were both sending and receiving and got a good feel for what was going on in terms of
packets being sent, received, and how they were being dealt with. With many moving parts, 
the log was pivotal to tracking down and removing bugs.

We are most proud of our queueing structure, our implementation of handling 
timeouts, and the neat structure of our code.