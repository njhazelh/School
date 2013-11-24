# Nicholas Jones
# Computer Organization PS6
# 11/20/2013

# =============================================================================
# ================================= PART 1 ====================================
# =============================================================================

def sum3(nums):
  return sum(nums)

def rotate_left3(nums):
  return nums[1:] + [nums[0]]

def reverse3(nums):
  nums.reverse()
  return nums

def max_end3(nums):
  x = max(nums[0], nums[2])
  return [x,x,x]

def sum2(nums):
  return sum((nums + [0])[:2])

def middle_way(a, b):
  return [a[1],b[1]]

def make_ends(nums):
  return [nums[0], nums[len(nums) - 1]]

def has23(nums):
  return 2 in nums or 3 in nums

def count_evens(nums):
  return [x % 2 for x in nums].count(0)

def big_diff(nums):
  return max(nums) - min(nums)

def centered_average(nums):
  return (sum(nums) - max(nums) - min(nums)) / (len(nums) - 2)

def sum67(nums):
  sum = 0
  ignore = False
  for x in nums:
    if x == 6:
      ignore = True
    elif not ignore:
      sum += x
    elif x == 7:
      ignore = False
  return sum

def has22(nums):
  for i in range(0, len(nums) - 1):
    if nums[i] == nums[i+1] == 2:
      return True
  return False

def extra_end(str):
  return str[len(str)-2: len(str)] * 3

def without_end(str):
  return str[1:len(str)-1]

def double_char(str):
  return "".join([c+c for c in str])

def count_hi(str):
  return str.count("hi")

def cat_dog(str):
  return str.count("cat") == str.count("dog")

def count_code(str):
  count = 0
  for i in range(0, len(str) - 3):
    if str[i:i+2] == "co" and str[i+3] == "e":
      count += 1
  return count

def end_other(a, b):
  a = a.lower()
  b = b.lower()
  return b.endswith(a) or a.endswith(b)

def xyz_there(str):
  return str.count("xyz") - str.count(".xyz") > 0



# =============================================================================
# ================================= PART 2 ====================================
# =============================================================================

def word_count(str):
  return [len(str.split("\n")), len(str.split()), len(str)]

def mycount(str):
  mycount = [str.count(c) for c in "0123456789 \t\n"]
  return mycount + [len(str) - sum(mycount)]