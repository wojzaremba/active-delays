function nothing = assert(condition)

if (~condition)
  error('assert failed');
end
