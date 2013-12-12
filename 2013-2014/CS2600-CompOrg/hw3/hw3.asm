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
      

# insertSort:
# Sort the given list into accending lexigraphical order.
# $a0 - Array of addresses of Strings
# $a1 - number of elements in $a0
#
#void insertSort(char *a[], size_t length) {
#     // WAS: size_t i, j;
#     // size_t can be 'unsigned int';  When j decrements from 0 to -1,
#     //  this causes an underflow problem that is not caught by gcc-3.2.
#     int i, j;
# 
#     for(i = 1; i < length; i++) {
#         char *value = a[i];
#         for (j = i-1; j >= 0 && str_lt(value, a[j]); j--) {
#             a[j+1] = a[j];
#         }
#         a[j+1] = value;
#     }
# }
# $t0 - pointer to value at a[i]
# $t1 - number of elements in array
# $t2 - i index
# $t3 - value to place
# $t4 - j index
# $t5 - pointer to value at a[j]
# $t6 - result of str_lt, a[j]
insertionSort:
       move      $t0, $a0 # $t0 = array adddress
       move      $t1, $a1 # $t1 = size
       li        $t2, 1   # i = 1
       add       $t0, $t0, 4 # move pointer to a[i]
#==========================================================
insertionSort_for_outer:
       # if (i >= length) break;
       beq       $t2, $t1, end_insertionSort_for_outer
       # char *value = a[i];
       lw        $t3, 0($t0)
       # j = i - 1
       subi      $t4, $t2, 1
       # *a[j] = *a[i-1] : address of elem at a[j]
       subi      $t5, $t0, 4
#----------------------------------------------------
insertionSort_for_inner:
       # while (j >= 0 &&
       bltz      $t4, end_insertionSort_for_inner
       # str_lt(value, a[j]))
       move      $a0, $t3 # move value into str_lt
       lw        $a1, 0($t5) # move a[j] into str_lt
       
       add       $sp, $sp, -32
       sw        $t0, 0($sp)
       sw        $t1, 4($sp)
       sw        $t2, 8($sp)
       sw        $t3, 12($sp)
       sw        $t4, 16($sp)
       sw        $t5, 20($sp)
       sw        $t6, 24($sp)
       sw        $ra, 28($sp)
       jal       str_lt
       lw        $t0, 0($sp)
       lw        $t1, 4($sp)
       lw        $t2, 8($sp)
       lw        $t3, 12($sp)
       lw        $t4, 16($sp)
       lw        $t5, 20($sp)
       lw        $t6, 24($sp)
       lw        $ra, 28($sp)
       add       $sp, $sp, 32
       
       move      $t6, $v0
       beqz      $t6, end_insertionSort_for_inner
       # a[j+1] = a[j];
       lw        $t6, 0($t5)
       sw        $t6, 4($t5)
       # j--
       subi      $t5, $t5, 4
       subi      $t4, $t4, 1
       j         insertionSort_for_inner
#-----------------------LOOP-------------------------
end_insertionSort_for_inner:
       # a[j+1] = value;
       sw        $t3, 4($t5)
       addi      $t0, $t0, 4 # increment address of i pointer
       addi      $t2, $t2, 1 # i++
       j         insertionSort_for_outer
# ======================LOOP===============================
end_insertionSort_for_outer:
       jr        $ra
 
 
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
