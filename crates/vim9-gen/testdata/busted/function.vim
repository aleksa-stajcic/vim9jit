vim9script

def Test_default_args()
  def MyCoolFunc(x = 5)
    return x
  enddef

  assert_equal(MyCoolFunc(), 5)
  assert_equal(MyCoolFunc(10), 10)
enddef

def Test_inplace()
  var explicit = [3, 2, 1]
  explicit = sort(explicit)
  assert_equal([1, 2, 3], explicit)

  var inplace = [3, 2, 1]
  sort(inplace)
  assert_equal([1, 2, 3], inplace)

  var expr_sort = sort([3, 2, 1])
  sort([3, 2, 1])
  assert_equal([1, 2, 3], expr_sort)
enddef

def Test_insert_inplace()
  var foo = [1, 2, 3]
  var bar = insert(foo, 4, len(foo))
  assert_equal(foo, bar)

  insert(bar, 5, len(bar))
  assert_equal([1, 2, 3, 4, 5], bar)
  assert_equal(foo, bar)
enddef

def Test_insert_inplace()
  var foo = [1, 3, 2]
  reverse(sort(foo))
  assert_equal([3, 2, 1], foo)
enddef
