# Nicholas Jones
# Problem Set 3
# Due: 10/9/2013
# Prof. Gene Cooperman

      .data
      .align     5
array:
      .asciiz    "Joe"
      .align     5
      .asciiz    "Jenny"
      .align     5
      .asciiz    "Jill"
      .align     5
      .asciiz    "John"
      .align     5
      .asciiz    "Jeff"
      .align     5
      .asciiz    "Joyce"
      .align     5
      .asciiz    "Jerry"
      .align     5
      .asciiz    "Janice"
      .align     5
      .asciiz    "Jake"
      .align     5
      .asciiz    "Jonna"
      .align     5
      .asciiz    "Jack"
      .align     5
      .asciiz    "Jocelyn"
      .align     5
      .asciiz    "Jessie"
      .align     5
      .asciiz    "Jess"
      .align     5
      .asciiz    "Janet"
      .align     5
      .asciiz    "Jane"
      .align     5
data: .space    64
start_text:
      .asciiz    "Initial array is:\n"
final_text:
      .asciiz    "Insertion sort is finished!\n"
array_open:
     .asciiz     "["
array_close:
     .asciiz     " ]\n"
space_char:
     .asciiz     " "
num_elems:
     .word       16
elem_size:
     .word       32 
     
     .globl main
     
     .text
main:
# Init. Array of addresses
      la         $a0, array
      la         $a1, data
      lw         $a2, elem_size
      lw         $a3, num_elems
      jal        prep_addr_array
#  printf("Initial array is:\n");
      li         $v0, 4
      la         $a0, start_text
      syscall
#  print_array(data, size);
      la        $a0, data
      lw        $a1, num_elems
      jal       print_array
#  insertSort(data, size);
      la      $a0, data
      lw      $a1, num_elems
      jal     insertionSort
#  printf("Insertion sort is finished!\n");
      li         $v0, 4
      la         $a0, final_text
      syscall
#  print_array(data, size);
      la        $a0, data
      lw        $a1, num_elems
      jal       print_array
#  exit(0);
      li       $v0, 10
      syscall
      

# quickSort
# sort the given array using quickSort algorithm
# $a0, $t0 - array to sort
# $a1, $t1 - start index >= 0
# $a2, $t2 - end index < size
# $t3 - i
# $t4 - j
# $t5 - *x
# $t6 - *y
# $t7 - pointer to a[i]
# $s0 - pointer to a[j]
#void quicksort(char * a[ ], int first, int last)
#{
#  int i, j;
#  char *x, *t
#
#  x = a[(first + last) /2];
#  i = first; j = last;
#  /* printf("Quicksort routine is executed! first = %d, last = %d, x = %d\n",
#   *         first, last, x);
#   */
#  for(;;)
#  {
#    while( str_lt(a[i], x) ) i++;
#    while( str_lt(x, a[j])) j--;
#    if (i >= j) break;
#    t = a[i]; a[i] = a[j]; a[j] = t;
#    /* printf("Data is swapped!\n"); */
#    i++; j--;
#  }
#  if(first < i-1) quicksort( a, first, i-1 );
#  if(j+1 < last) quicksort( a, j+1, last );
#}
 quickSort:
      move       $t0, $a0
      move       $t1, $a1
      move       $t2, $a2
      move       $t3, $t1
      move       $t4, $t2
      move
      li         $t6, 2
      add        $t5, $t1, $t2
      div        $t5, $t6
      mflo       $t5
 quickSort_for:
 quickSort_x++_while:
      
# str_lt:
# Is String x less than String y?
# $a0 - pointer to first String, x.
# $a1 - pointer to second String, y.
# Return $a0 = 1 if less than else 0
# If x is longer than y, then x is greater.
#
#int str_lt (char *x, char *y) {
#  for (; *x!='\0' && *y!='\0'; x++, y++) {
#    if ( *x < *y ) return 1;
#    if ( *y < *x ) return 0;
#  }
#  if ( *y == '\0' ) return 0;
#  else return 1;
#}
str_lt:
      move       $t0, $a0 # x = $a0
      move       $t1, $a1 # y = $a1
#----------------------------------------------------
str_lt_while:
      lb         $t2, 0($t0) # load char in x
      lb         $t3, 0($t1) # load char in y
      #  for (; *x!='\0' && *y!='\0'; x++, y++)
      beqz       $t2, end_str_lt_while
      beqz       $t3, end_str_lt_while
      #  if ( *x < *y ) return 1;
      blt        $t2, $t3, str_lt_ret_1
      #  if ( *y < *x ) return 0;
      blt        $t3, $t2, str_lt_ret_0
      add        $t0, $t0, 1 # x++
      add        $t1, $t1, 1 # y++
      j          str_lt_while
#---------------------LOOP---------------------------
end_str_lt_while:
      #  if ( *y == '\0' ) return 0;
      beqz       $t3, str_lt_ret_0
str_lt_ret_1:
      # return 1;
      li         $v0, 1
      jr         $ra
str_lt_ret_0:
      #return 0;
      li         $v0, 0
      jr         $ra
      
      
# prep_addr_array:
# Fill the given space with an array of pointers
# to each elements in the given array of data.
# $a0 - Pointer to array of Data
# $a1 - Pointer to space for address array
# $a2 - size of each element
# $a3 - number of elements
prep_addr_array:
      move       $t0, $a0 # $t0 = pointer to old array
      move       $t1, $a1 # $t1 = pointer to new array space
      move       $t2, $a2 # $t2 = size of each elem
      move       $t3, $a3 # $t3 = num of elems
      addi       $sp, $sp, -4
      sw         $t1, 0($sp) # save the initial pointer to new array
prep_array_for:
      # if ($t3 == 0) break;
      blez       $t3, end_prep_array_for
      # set value of data[i] as $t0
      sw         $t0, 0($t1)
      addi       $t1, $t1, 4
      add        $t0, $t0, $t2
      subi       $t3, $t3, 1 
      j          prep_array_for
end_prep_array_for:
      lw         $v0, 0($sp)
      addi       $sp, $sp, 4
      jr         $ra



# print_array:
# Given an address of an array of addresses of Strings
# print each string - [ s1 s2 s3 ... sn ]
# $a0 - array of addresses
# $a1 - number of elems
#void print_array(char * a[], const int size)
print_array:
      move       $t0, $a0 # array address
      move       $t1, $a1 # num elems
      #printf("[")
      li         $v0, 4
      la         $a0, array_open
      syscall
      #while(size > 0)
print_array_for:
      blez       $t1, end_print_array_for
#  printf("  %s", a[i++]);
      la         $a0, space_char
      syscall
      
      lw         $a0, 0($t0)
      syscall
      
      addi       $t0, $t0, 4
      sub        $t1, $t1, 1
      j          print_array_for
end_print_array_for:
#printf(" ]\n");
      la         $a0, array_close
      syscall
      jr         $ra
