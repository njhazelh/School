Luke-IAmYourFolder 
CS3600, Spring 2014, Project 2
By Victor Monterroso and Nicholas Jones
-------------------------------------------------------------------------------

In this project, we used the FAT implementation, as we decided that the Inode 
layout was too complicated for our liking. Our formatted disk consisted of 
one VCB at the beginning, 100 directory entries to support 100 files, as is 
required, and FAT blocks and DBs depending on the size of the disk we are given.

Our approach included defining the functions as was suggested in the project 
handout, such as implementing the simpler functions such as mount, create, 
delete, and getattr first. We then proceeded to implement functions that dealt
with metadata such as chown, chmod, utimens, since we cached our directory entries
and that made it simpler to implement those functions. Finally, we implemented truncate,
write, and read. 

We are quite proud of the fact that we cached our directory entries and our FAT
entries. This makes our code more efficient, as we do not have to read from disk 
when we are searching for either a directory entry or a FAT entry, making our code
much more efficient. We kept consistency between our cached copy and our disk by 
making a function that would write a specific FAT block or directory entry and including
it every time we altered a block. 

At first, since we hadn't covered file systems in detail, it was hard to understand
exactly what formatting the disk meant. However, as soon as we went over it in class, 
it become much more clear. Some FUSE functions were also unclear, but looking at 
documentation and Piazza helped clarify a lot of questions. We spent a bulk of our 
debugging time with read and write, since we weren't exactly sure which one wasn't working. 
However, we took the time to go over the code together and found the fix for it.

As far as debugging, it was hard to use gdb when FUSE was running a lot of our 
code. Also, because functions such as read and write went hand in hand, it was hard
to know which one was wrong. That was where print statements, looking at the log, and
stepping through the code as partners really helped. 

