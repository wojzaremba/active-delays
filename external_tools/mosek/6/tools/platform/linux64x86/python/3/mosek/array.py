"""
    Mosek/Python Array Module. A minimal array implementation.

    Copyright: $$copyright
"""

import sys
if sys.version_info[0] == 2 and sys.version_info[1] < 5:
    raise ImportError('Invalid python version')
try:
    import ctypes
except ImportError:
    raise ImportError('Array module requires ctypes')

import operator


try:              
    long()
except NameError: 
    long = int

class UnsupportedMethod(Exception): pass
class UnimplementedMethod(Exception): pass
def unimplemented(f):
    def _unimplemented(*args):
        raise UnimplementedMethod('Not implemented: %s' % f.__name__)
    return _unimplemented

float64 = float
class int32(int): pass
class int64(int): pass

try:
    _isSequenceType = operator.isSequenceType
except AttributeError:
    # Python 3.X have deprecated isSequenceType
    def _isSequenceType(o):
        return hasattr(o,'__len__') and (hasattr(o,'__iter__') or hasattr(o,'__getitem__'))

def zeros(size,dtype=None):
    """
    Create an array of zeros of the given size.

    Arguments:
     size - Number of elements in the array.
     dtype - (Optional) Type of the array to create.
    """
    return ndarray(size=size,fill=0,dtype=dtype)
def ones(size,dtype=None):
    """
    Create an array of ones of the given size.

    Arguments:
     size - Number of elements in the array.
     dtype - (Optional) Type of the array to create.
    """
    return ndarray(size=size,fill=1,dtype=dtype)
def array(values,dtype=None):
    """
    Create an array from a list of values.

    Arguments:
     values - A list of values
     dtype - (Optional) type of the array to construct.
    Returns
     A new array.
    """
    return ndarray(values,dtype=dtype)

@unimplemented
def resize(value,new_shape): pass
def arange(*args): return array(range(*args),int32)
@unimplemented
def take(a, indices): pass
@unimplemented
def sort(a): pass
@unimplemented
def argsort(a): pass

class ndarray:
    @staticmethod
    def __int32_ctype(v):  return ctypes.c_int
    @staticmethod
    def __int64_ctype(v):  return ctypes.c_longlong
    @staticmethod
    def __double_ctype(v): return ctypes.c_double
    @staticmethod
    def __bool_ctype(v):   return ctypes.c_int

    __errcodeconv = { 1 : ValueError,
                      2 : ValueError,
                      3 : IndexError }
    @staticmethod
    def __makeexception(errcode,msg=None):
        err = ndarray.__errcodeconv[errcode]
        if msg is not None:
            return err(msg)
        else:
            return err()

    def unsupported_method(self,*args):
        raise UnsupportedMethod('The method is not supported for this array type')

    def __setupfunctions(self,t,ct):
        assert t in [ 'int32', 'int64','double','bool' ]
        array_unop      = [ 'neg' ]
        array_binop     = [ 'add','sub','mul','div','invsub','invdiv' ]
        array_cmpop     = [ 'eq','lt','le','gt','ge' ]
        array_invcmpop  = [ 'eq','ge','gt','le','lt' ]

        d = { 't' : t, 'ct' : ct }
       
        setattr(self,'_ndarray__new_array__values_size',                        
                getattr(__library__, 'mosek_new_%(t)sarray__%(t)sp_size' % d))
        setattr(self,'_ndarray__new_array__array_start_stop_step_shallow',      
                getattr(__library__,'mosek_new_%(t)sarray__%(t)sarray_start_stop_step_shallow' % d))
        setattr(self,'_ndarray__new_array__array',                              
                getattr(__library__,'mosek_new_%(t)sarray__%(t)sarray'    % d))
        setattr(self,'_ndarray__new_array__size_value', 
                getattr(__library__,'mosek_new_%(t)sarray__size_%(t)s'    % d))
        setattr(self,'_ndarray__delete_array__array',
                getattr(__library__,'mosek_delete_%(t)sarray__%(t)sarray' % d))

        setattr(self,'_ndarray__getitem__array_index_valuep',
                getattr(__library__, 'mosek_getitem__%(t)sarray_index_valuep' % d))
        setattr(self,'_ndarray__getslice__array_start_stop_step_arrayp',
                getattr(__library__, 'mosek_getslice__%(t)sarray_start_stop_step_arrayp' % d))
        setattr(self,'_ndarray__getslice__array_start_step_arrayp',
                getattr(__library__, 'mosek_getslice__%(t)sarray_start_step_arrayp' % d))
        setattr(self,'_ndarray__setslice__array_start_stop_step_array',
                getattr(__library__, 'mosek_setslice__%(t)sarray_start_stop_step_array' % d))
        setattr(self,'_ndarray__setslice__array_start_stop_step_value',
                getattr(__library__, 'mosek_setslice__%(t)sarray_start_stop_step_value' % d))
        setattr(self,'_ndarray__setslice__array_start_stop_step_values_size',
                getattr(__library__, 'mosek_setslice__%(t)sarray_start_stop_step_values_size' % d))
        setattr(self,'_ndarray__setslice__array_start_step_array',
                getattr(__library__, 'mosek_setslice__%(t)sarray_start_step_array' % d))
        setattr(self,'_ndarray__setslice__array_start_step_value',
                getattr(__library__, 'mosek_setslice__%(t)sarray_start_step_value' % d))
        setattr(self,'_ndarray__setitem__array_index_value',
                getattr(__library__, 'mosek_setitem__%(t)sarray_index_value' % d))
        setattr(self,'_ndarray__array_length',
                getattr(__library__, 'mosek_length__%(t)sarray' % d))
        
        setattr(self,'_ndarray__sum__array_valuep', 
                getattr(__library__, 'mosek_sum__%(t)sarray_valuep' % d))
        setattr(self,'_ndarray__dot__array_array_valuep',
                getattr(__library__, 'mosek_dot__%(t)sarray_%(t)sarray_valuep' % d))
        setattr(self,'_ndarray__getdataptr__array',
                getattr(__library__, 'mosek_getdataptr__%(t)sarray' % d))
        setattr(self,'_ndarray__getsteplength__array',
                getattr(__library__, 'mosek_getsteplength__%(t)sarray' % d))

        for op,invop in zip(array_cmpop,array_invcmpop):
            d['op'] = op
            d['invop'] = invop
            setattr(self,'_ndarray__%(op)s__array_array_arrayp'    % d,getattr(__library__,'mosek_%(op)s__%(t)sarray_%(t)sarray_boolarrayp' % d))
            setattr(self,'_ndarray__%(op)s__array_value_arrayp'    % d,getattr(__library__,'mosek_%(op)s__%(t)sarray_%(t)s_boolarrayp' % d))
            setattr(self,'_ndarray__inv%(op)s__array_array_arrayp' % d,getattr(__library__,'mosek_%(invop)s__%(t)sarray_%(t)sarray_boolarrayp' % d))
            setattr(self,'_ndarray__inv%(op)s__array_value_arrayp' % d,getattr(__library__,'mosek_%(invop)s__%(t)sarray_%(t)s_boolarrayp' % d))
            for which in [ 'all','any' ]:
                d['which'] = which
                setattr(self,'_ndarray__%(op)s_%(which)s__array_array_boolp'    % d,getattr(__library__,'mosek_%(which)s_%(op)s__%(t)sarray_%(t)sarray_boolp' % d))
                setattr(self,'_ndarray__%(op)s_%(which)s__array_value_boolp'    % d,getattr(__library__,'mosek_%(which)s_%(op)s__%(t)sarray_%(t)s_boolp' % d))
                setattr(self,'_ndarray__inv%(op)s_%(which)s__array_array_boolp' % d,getattr(__library__,'mosek_%(which)s_%(invop)s__%(t)sarray_%(t)sarray_boolp' % d))
                setattr(self,'_ndarray__inv%(op)s_%(which)s__array_value_boolp' % d,getattr(__library__,'mosek_%(which)s_%(invop)s__%(t)sarray_%(t)s_boolp' % d))
        if t != 'bool':
            setattr(self,'_ndarray__sort__array',getattr(__library__,'mosek_sort__%(t)sarray' % d))
            for indext in [ 'int32', 'int64' ]:
                d['idxt'] = indext
                setattr(self,'_ndarray__argsort__%(idxt)sarray_array' % d,getattr(__library__,'mosek_argsort__%(idxt)sarray_%(t)sarray' % d))

            for op in array_unop:
                d['op'] = op
                setattr(self,'_ndarray__inplace_%(op)s__array' % d,getattr(__library__,'mosek_inplace_%(op)s__%(t)sarray' % d))

            for op in array_binop:
                d['op'] = op
                setattr(self,'_ndarray__inplace_%(op)s__array_array' % d,getattr(__library__,'mosek_inplace_%(op)s__%(t)sarray_%(t)sarray' % d))
                setattr(self,'_ndarray__inplace_%(op)s__array_value' % d,getattr(__library__,'mosek_inplace_%(op)s__%(t)sarray_%(t)s' % d))
                setattr(self,'_ndarray__%(op)s__array_array_arrayp'  % d,getattr(__library__,'mosek_%(op)s__%(t)sarray_%(t)sarray_%(t)sarrayp' % d))
                setattr(self,'_ndarray__%(op)s__array_value_arrayp'  % d,getattr(__library__,'mosek_%(op)s__%(t)sarray_%(t)s_%(t)sarrayp' % d))
            

        else: 
            for op in array_unop:
                d['op'] = op
                setattr(self,'_ndarray__inplace_%(op)s__array' % d,self.unsupported_method)

            for op in array_binop:
                d['op'] = op
                setattr(self,'_ndarray__inplace_%(op)s__array_array' % d,self.unsupported_method)
                setattr(self,'_ndarray__inplace_%(op)s__array_value' % d,self.unsupported_method)
                setattr(self,'_ndarray__%(op)s__array_array_arrayp'  % d,self.unsupported_method)
                setattr(self,'_ndarray__%(op)s__array_value_arrayp'  % d,self.unsupported_method)

    @staticmethod
    def __deducedatatype(value,dtype):
        if dtype is int32 or (dtype is None and (len(value) == 0 or type(value[0]) == int)):
            dtype = int32
            tname = 'int32'
            ctype = ctypes.c_int
            tconv = int
        elif dtype is int64:
            dtype = int64
            tname = 'int64'
            ctype = ctypes.c_longlong
            tconv = long
        elif dtype is float64 or (dtype is None and isinstance(value[0],float)):
            dtype = float64
            tname = 'double'
            ctype = ctypes.c_double
            tconv = float
        elif dtype is bool or (dtype is None and isinstance(value[0],float)):
            dtype = bool
            tname = 'bool'
            ctype = ctypes.c_int
            tconv = bool
        else:
            raise TypeError('Unexpected data type for array')
        return dtype,tname,ctype,tconv

    def __all_cmp(self,other,op):
        res = ctypes.c_int()
        if isinstance(other,ndarray):
            r = getattr(self,'_ndarray__%s_all__array_array_boolp' % op)(self.__nativep,other.__nativep,ctypes.byref(res))
            if r != 0:
                raise self.__makeexception(r,'Failed to compare arrays')
        elif _isSequenceType(other):
            other = ndarray(other,dtype=self.__dtype)
            r = getattr(self,'_ndarray__%s_all__array_array_boolp' % op)(self.__nativep,other.__nativep,ctypes.byref(res))
            if r != 0:
                raise self.__makeexception(r,'Failed to compare array and value')
        else:
            r = getattr(self,'_ndarray__%s_all__array_value_boolp' % op)(self.__nativep,other,ctypes.byref(res))
            if r != 0:
                raise self.__makeexception(r,'Failed to compare array and value')

        return bool(res.value)
    def __any_cmp(self,other,op):
        res = ctypes.c_int()
        if isinstance(other,ndarray):
            r = getattr(self,'_ndarray__%s_any__array_array_boolp' % op)(self.__nativep,other.__nativep,ctypes.byref(res))
            if r != 0:
                raise ValueError('Failed to compare arrays')
        elif _isSequenceType(other):
            other = ndarray(other,dtype=self.__dtype)
            r = getattr(self,'_ndarray__%s_any__array_array_boolp' % op)(self.__nativep,other.__nativep,ctypes.byref(res))
            if r != 0:
                raise ValueError('Failed to compare array and value')
        else:
            r = getattr(self,'_ndarray__%s_any__array_value_boolp' % op)(self.__nativep,other,ctypes.byref(res))
            if r != 0:
                raise ValueError('Failed to compare array and value')
        return bool(res.value)


    def __init__(self,value=None,dtype=None,size=None,fill=None,op=None,slice=None):
        """
        \param value Values to put in the array.
        \param dtype Array type (int,long,float,bool).
        \param size  Length of the array.
        \param fill  Value to fill in the array.
       
        Possible combinations of arguments:
         value and, optionally, dtype. 
            Create an array using the values. If dtype is given, convert
            values, otherwise try to deduce the dtype from values.
         size and, optionally, dtype and fill. 
            Create an array of size elements. Of dtype is given, use this type,
            otherwise make an int32 array. If fill is given, fill the aray
            with this value, otherwise use default value.
         op = (lhs, operation, rhs). 
            Where lhs and rhs are either arrays or values, and operation is one
            a string: 'add', 'sub', 'mul', 'div', 'eq', 'lt', 'le', 'gt' or
            'ge'. Create an array by applying the operation the the two
            operands; the first four operations will promote the operand types
            so they are the same, then return an array of that type as the
            result of the operation. The remaining operations require lhs and
            rhs to have same type, and returns a boolean array.  If both
            operands are arrays, they must have same length.
         slice = (other,slice).
            Where slice is a slice object and other is the array object to take
            a slice of.
        """
        if dtype is not None and dtype not in [ int32, int64, float64, bool]:
            raise ValueError("Invalid type for array")
        self.__nativep = None
        if value is not None:
            #print "value = ",value
            self.__length = len(value)
            if not isinstance(value,ndarray):
                self.__dtype,self.__tname,self.__ctype,self.__typeconv = self.__deducedatatype(value,dtype)
                self.__setupfunctions(self.__tname,self.__ctype)

                #print self.__dtype, self.__ctype, self.__typeconv, self.__tname
               
                initvals = (self.__ctype * len(value))(*value)
                #if self.__dtype is bool:
                #    print "initvals = ",initvals,[i for i in initvals]
                self.__nativep = self.__new_array__values_size(initvals,len(value))
                if self.__nativep is None:
                    raise MemoryError('Failed to create array')
                #if self.__dtype is bool:
                #    print "bool array =",self
            else:
                self.__dtype,self.__tname,self.__ctype,self.__typeconv = value.__dtype, value.__tname, value.__ctype, value.__typeconv
                self.__setupfunctions(self.__tname,self.__ctype)
                
                self.__nativep = self.__new_array__array(value.__nativep)
        elif op is not None:
            lhs,opr,rhs = op
            if isinstance(lhs,ndarray) and isinstance(rhs,ndarray):
                if lhs.__dtype != rhs.__dtype:
                    # auto-promotion not implemented yet
                    raise TypeError('Incompatible array types for operation')
                elif len(lhs) != len(rhs):
                    raise TypeError('Arrays do not have same length')
                
                if opr in [ 'add','sub','mul','div' ]:
                    self.__dtype = lhs.__dtype
                    self.__tname = lhs.__tname
                    self.__ctype = lhs.__ctype
                    self.__typeconv = lhs.__typeconv

                    self.__setupfunctions(self.__tname,self.__ctype)
                    func = getattr(self,'_ndarray__%s__array_array_arrayp' % opr)
                    arg1 = lhs.__nativep
                    arg2 = rhs.__nativep
                elif opr in [ 'lt','le','gt','ge','eq' ]:
                    self.__dtype = bool
                    self.__tname = 'bool'
                    self.__ctype = ctypes.c_int
                    self.__typeconv = bool

                    self.__setupfunctions(self.__tname,self.__ctype)
                    func = getattr(lhs,'_ndarray__%s__array_array_arrayp' % opr)
                    arg1 = lhs.__nativep
                    arg2 = rhs.__nativep
                else:
                    raise TypeError('Invalid operation "%s"' % opr)
            elif isinstance(lhs,ndarray):
                if opr in [ 'add','sub','mul','div' ]:
                    self.__dtype = lhs.__dtype
                    self.__tname = lhs.__tname
                    self.__ctype = lhs.__ctype
                    self.__typeconv = lhs.__typeconv

                    self.__setupfunctions(self.__tname,self.__ctype)
                    func = getattr(lhs,'_ndarray__%s__array_value_arrayp' % opr)
                    arg1 = lhs.__nativep
                    arg2 = rhs
                elif opr in [ 'lt','le','gt','ge','eq' ]:
                    self.__dtype = bool
                    self.__tname = 'bool'
                    self.__ctype = ctypes.c_int
                    self.__typeconv = bool

                    self.__setupfunctions(self.__tname,self.__ctype)
                    func = getattr(lhs,'_ndarray__%s__array_value_arrayp' % opr)
                    arg1 = lhs.__nativep
                    arg2 = rhs
                else:
                    raise TypeError('Invalid operation "%s"' % opr)

                if   lhs.__tname in [ 'int32', 'int64' ]:
                    rhs = long(rhs)
                elif lhs.__tname in [ 'double' ]:
                    rhs = float(rhs)
                elif lhs.__tname in [ 'bool' ]:
                    rhs = bool(rhs)

                else:
                    assert 0
            elif isinstance(rhs,ndarray):
                if opr in [ 'add','sub','mul','div' ]:
                    self.__dtype = rhs.__dtype
                    self.__tname = rhs.__tname
                    self.__ctype = rhs.__ctype
                    self.__typeconv = rhs.__typeconv

                    self.__setupfunctions(self.__tname,self.__ctype)
                    if opr in [ 'add','mul' ]:
                        func = getattr(rhs,'_ndarray__%s__array_value_arrayp' % opr)
                    else:
                        func = getattr(rhs,'_ndarray__inv%s__array_value_arrayp' % opr)
                    
                    arg1 = rhs.__nativep
                    arg2 = lhs
                elif opr in [ 'lt','le','gt','ge','eq' ]:
                    self.__dtype = bool
                    self.__tname = 'bool'
                    self.__ctype = ctypes.c_int
                    self.__typeconv = bool

                    self.__setupfunctions(self.__tname,self.__ctype)
                    func = getattr(rhs,'_ndarray__%inv%s__array_value_arrayp' % opr) 
                    arg1 = rhs.__nativep
                    arg2 = lhs
                else:
                    raise TypeError('Invalid operation "%s"' % opr)
            else:
                raise VaueError('Invaid operands')

            tmpp = ctypes.c_void_p()
            #print "self = ",repr(self),self.__dtype
            #print "op = ",op
            res = func(arg1,arg2,ctypes.byref(tmpp))
            self.__nativep = tmpp.value
            if res != 0:
                raise ValueError('Failed to create array')
            self.__length = int(self.__array_length(self.__nativep))
        elif slice is not None:
            slice,other = slice
            self.__dtype = other.__dtype
            self.__ctype = other.__ctype
            self.__tname = other.__tname
            self.__typeconv = other.__typeconv 
            self.__setupfunctions(self.__tname,self.__ctype)

            start = slice.start or 0
            stop  = slice.stop 
            step  = slice.step  or 1

            if stop is None or stop > other.__length:
                stop = other.__length
            
            self.__nativep = None
            tmpp = ctypes.c_void_p()

            r = other.__getslice__array_start_stop_step_arrayp(other.__nativep,start,stop,step,ctypes.byref(tmpp))

            if r == 0:
                self.__nativep = tmpp.value
            else:
                raise ValueError("Failed to create array")
            self.__length = int(self.__array_length(self.__nativep))
        elif size is not None:
            if dtype is None:
                if fill is None:
                    self.__dtype = int32
                    self.__ctype = ctypes.c_int
                    self.__tname = 'int32'
                    self.__typeconv = int
                elif isinstance(fill,bool):
                    self.__dtype = bool
                    self.__ctype = ctypes.c_int
                    self.__tname = 'bool'
                    self.__typeconv = bool
                elif isinstance(fill,long):
                    self.__dtype = int64
                    self.__ctype = ctypes.c_longlong
                    self.__tname = 'int64'
                    self.__typeconv = long 
                elif isinstance(fill,int):
                    self.__dtype = int32
                    self.__ctype = ctypes.c_int
                    self.__tname = 'int32'
                    self.__typeconv = int
                elif isinstance(fill,float):
                    self.__dtype = float
                    self.__ctype = ctypes.c_double
                    self.__tname = 'double'
                    self.__typeconv = float
                else:
                    raise TypeError('Invalid type for array fill')
            else:
                if fill is None:
                    fill = 0
                if   dtype is bool:
                    self.__ctype = ctypes.c_int
                    self.__tname = 'bool'
                    self.__typeconv = bool
                elif dtype is int64 or dtype is long:
                    self.__ctype = ctypes.c_longlong
                    self.__tname = 'int64'
                    self.__typeconv = long
                elif dtype is int32 or dtype is int:
                    self.__ctype = ctypes.c_int
                    self.__tname = 'int32'
                    self.__typeconv = int
                elif dtype is float64:
                    self.__ctype = ctypes.c_double
                    self.__tname = 'double'
                    self.__typeconv = float
                else:
                    raise TypeError('Invalid type indicator')
                self.__dtype = dtype
            self.__setupfunctions(self.__tname,self.__ctype)
            self.__nativep = self.__new_array__size_value(size,fill)
            self.__length = int(size)
        else:
            raise ValueError('Invalid arguments for array constructor')
        self.dtype = self.__dtype
        assert self.__nativep is not None
        assert self.__dtype is not int
    
    def __del__(self):
        if hasattr(self,'_ndarray__nativep') and self.__nativep is not None:
            self.__delete_array__array(self.__nativep)
    def __str__(self):
        return '[ %s ]' % ','.join([ str(self[i]) for i in range(len(self))])
    def getsteplength(self):
        """
        Return a the data step length. A length of 1 means contiguous data.
        """
        return self.__getsteplength__array(self.__nativep)
    def getdatacptr(self):
        """
        Return a C void pointer to the data array data.
        """
        return ctypes.cast(self.__getdataptr__array(self.__nativep),self.__getdataptr__array.restype)
    def __len__ (self): return self.__length
    def __add__ (self,other): return ndarray(op=(self,'add',other))
    def __radd__(self,other): return ndarray(op=(other,'add',self))
    def __sub__ (self,other): return ndarray(op=(self,'sub',other))
    def __rsub__(self,other): return ndarray(op=(other,'sub',self))
    def __mul__ (self,other): return ndarray(op=(self,'mul',other))
    def __rmul__(self,other): return ndarray(op=(other,'mul',self))
    def __div__ (self,other): return ndarray(op=(self,'div',other))
    def __rdiv__(self,other): return ndarray(op=(other,'div',self))
    def __lt__  (self,other): return ndarray(op=(self,'lt',other))
    def __le__  (self,other): return ndarray(op=(self,'le',other))
    def __gt__  (self,other): return ndarray(op=(self,'gt',other))
    def __ge__  (self,other): return ndarray(op=(self,'ge',other))
    def __eq__  (self,other): return ndarray(op=(self,'eq',other))
    def all_eq  (self,other): return self.__all_cmp(other,'eq')
    def all_lt  (self,other): return self.__all_cmp(other,'lt')
    def all_le  (self,other): return self.__all_cmp(other,'le')
    def all_gt  (self,other): return self.__all_cmp(other,'gt')
    def all_ge  (self,other): return self.__all_cmp(other,'ge')
    def any_eq  (self,other): return self.__any_cmp(other,'eq')
    def any_lt  (self,other): return self.__any_cmp(other,'lt')
    def any_le  (self,other): return self.__any_cmp(other,'le')
    def any_gt  (self,other): return self.__any_cmp(other,'gt')
    def any_ge  (self,other): return self.__any_cmp(other,'ge')

    def sum(self):
        """
        Sum elements in the array.
        """
        val = self.__ctype()
        r = self.__sum__array_valuep(self.__nativep,ctypes.byref(val))
        if r != 0:
            raise ValueError('Failed to sum array')
        return val.value
    
    def dot(self,other):
        """
        Compute the inner product between the array and another array.
        """
        if not isinstance(other,ndarray) and _isSequenceType(other):
            other = ndarray(other,dtype=self.__dtype)
        if isinstance(other,ndarray):
            val = self.__ctype()
            r = self.__dot__array_array_valuep(self.__nativep,other.__nativep, ctypes.byref(val))
            if r != 0:
                raise ValueError('Failed to sum array')
            return val.value
        else:
            raise TypeError('Invalid right-hand side for inner product')
    def sort(self):
        self.__sort__array(self.__nativep)
    def argsort(self,indexes):
        if not isinstance(indexes, ndarray) or \
           not (indexes.__dtype is int32 or indexes.__dtype is int64):
            raise TypeError('the method argsort can only be applied to integer arrays')
        if indexes.__dtype is int32:
            r = self.__argsort__int32array_array(indexes.__nativep, self.__nativep)
        elif indexes.__dtype is int64:
            r = self.__argsort__int64array_array(indexes.__nativep, self.__nativep)
        else:
            raise TypeError('the method argsort can only be applied to integer arrays')
        if r != 0:
            raise self.__makeexception(r,'Failed to sort array')
    
    def __getitem__(self,key):
        if   isinstance(key,slice):
            return ndarray(slice=(key,self))
        elif isinstance(key, int) or isinstance(key,long):
            res = self.__ctype()
            r = self.__getitem__array_index_valuep(self.__nativep, key, ctypes.byref(res))
            if r != 0:
                raise self.__makeexception(r,'Failed to get item')
        
            return self.__typeconv(res.value)
        else:
            raise KeyError('Invalid index type')
        
    def __setitem__(self,key,val):
        if   isinstance(key,slice):
            start = key.start or 0
            stop  = key.stop
            if stop is None or stop > self.__length:
                # Note: Sometimes 'stop' appears as None, sometimes as maxint.
                stop = self.__length
            step  = key.step or 1
                
            r = 0
            if isinstance(val,ndarray):
                r = self.__setslice__array_start_stop_step_array(self.__nativep,start,stop,step,val.__nativep)
            elif isinstance(val, ctypes.Array) and val._type_ is self.__ctype:
                # special case to avoid creating a temporary array object
                r = self.__setslice__array_start_stop_step_values_size(self.__nativep,start,stop,step,val,len(val))
            elif _isSequenceType(val):
                aval = ndarray(val,self.__dtype)
                r = self.__setslice__array_start_stop_step_array(self.__nativep,start,stop,step,aval.__nativep)
            else:
                # otherwise treat it as a single value
                r = self.__setslice__array_start_stop_step_value(self.__nativep,start,stop,step,val)
            if r != 0:
                raise self.__makeexception(r,'Failed to set slice')
        elif isinstance(key, int) or isinstance(key,long):
            r = self.__setitem__array_index_value(self.__nativep, key, self.__ctype(val))
            if r != 0:
                raise self.__makeexception(r,'Failed to set item')
        else:
            raise KeyError('Invalid index type')




# Setup DLL functions:
array_types = [ ('int32',ctypes.c_int), ('int64',ctypes.c_longlong),('double',ctypes.c_double),('bool',ctypes.c_int) ]
array_unop  = [ 'neg' ]
array_binop = [ 'add','sub','mul','div','invsub','invdiv' ]
array_cmpop = [ 'eq','lt','le','gt','ge' ]


import os
#,platform 
#arch,exe = platform.architecture()
#system   = platform.system()
#if    system == 'Darwin':
#    __library__ = ctypes.CDLL(os.path.join(os.path.dirname(__file__),'_array.dylib'))
#elif system == 'Windows':
#    __library__ = ctypes.WinDLL(os.path.join(os.path.dirname(__file__),'_array.dll'))
#elif system == 'Linux':
#    __library__ = ctypes.CDLL(os.path.join(os.path.dirname(__file__),'_array.so'))
#else: # assume linux/posix and .so libs
#    raise ImportError('Unknown system "%s"' % system)


class _native_library:
    """
    Encapsulation of a ctypes DLL; this ensures that we do not accidentially use
    a function that we have not set up before.
    """
    def __init__ (self,basepath,libname,setup):
      self.__funs = {}
      system = __import__('platform').system()
      self.__libname = libname

      if    system == 'Darwin':
          self.__lib = ctypes.CDLL(os.path.join(basepath,'%s.dylib' % libname))
      elif system == 'Windows':
          self.__lib = ctypes.WinDLL(os.path.join(basepath,'%s.dll' % libname))
      elif system == 'Linux':
          self.__lib = ctypes.CDLL(os.path.join(basepath,'%s.so' % libname))
      else: # assume linux/posix and .so libs
          raise ImportError('Unknown system "%s"' % system)
            
      for name,argtps,rettp in setup:
        f = getattr(self.__lib,name)
        f.argtypes = argtps
        f.restype  = rettp
        self.__funs[name] = f
    def __getattr__ (self,attr):
      return self.__funs[attr]
    def __repr__ (self):
      names = self.__funs.keys()
      names.sort()
      return "DLL(%s):\n\t" % self.__libname + '\n\t'.join(names)

        
funs = []
for at,ct in array_types:
    d = { 't' : at  }
    
    funs.append((('mosek_new_%(t)sarray__%(t)sp_size' % d),[ ctypes.POINTER(ct), ctypes.c_size_t] ,ctypes.c_void_p))
    funs.append((('mosek_new_%(t)sarray__%(t)sarray_start_stop_step_shallow' % d),[ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int] ,ctypes.c_void_p))
    funs.append((('mosek_new_%(t)sarray__%(t)sarray' % d),[ ctypes.c_void_p ] ,ctypes.c_void_p))
    funs.append((('mosek_new_%(t)sarray__size_%(t)s' % d),[ ctypes.c_size_t, ct ] ,ctypes.c_void_p))
    funs.append((('mosek_delete_%(t)sarray__%(t)sarray' % d),[ ctypes.c_void_p ] ,None))

    funs.append((('mosek_getitem__%(t)sarray_index_valuep' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ct) ] ,ctypes.c_int))
    funs.append((('mosek_setitem__%(t)sarray_index_value' % d),[ ctypes.c_void_p, ctypes.c_int, ct ] ,ctypes.c_int))
    
    funs.append((('mosek_getslice__%(t)sarray_start_stop_step_arrayp' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_void_p) ] ,ctypes.c_int))
    funs.append((('mosek_getslice__%(t)sarray_start_step_arrayp' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_void_p) ] ,ctypes.c_int))
    funs.append((('mosek_setslice__%(t)sarray_start_stop_step_array' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_void_p ] ,ctypes.c_int))
    funs.append((('mosek_setslice__%(t)sarray_start_stop_step_value' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ct ] ,ctypes.c_int))
    funs.append((('mosek_setslice__%(t)sarray_start_stop_step_values_size' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ct), ctypes.c_size_t ] ,ctypes.c_int))
    funs.append((('mosek_setslice__%(t)sarray_start_step_array' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_void_p ] ,ctypes.c_int))
    funs.append((('mosek_setslice__%(t)sarray_start_step_value' % d),[ ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ct ] ,ctypes.c_int))
    
    funs.append((('mosek_length__%(t)sarray' % d),[ ctypes.c_void_p ] ,ctypes.c_size_t))
    funs.append((('mosek_sum__%(t)sarray_valuep' % d),[ ctypes.c_void_p, ctypes.POINTER(ct)] ,ctypes.c_int))
    funs.append((('mosek_dot__%(t)sarray_%(t)sarray_valuep' % d),[ ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(ct)] ,ctypes.c_int))
    
    funs.append((('mosek_getdataptr__%(t)sarray' % d),[ ctypes.c_void_p ] ,ctypes.POINTER(ct)))

    funs.append((('mosek_getsteplength__%(t)sarray' % d),[ ctypes.c_void_p ] ,ctypes.c_int))



    for op in array_cmpop:
        d['op'] = op
        funs.append((('mosek_%(op)s__%(t)sarray_%(t)sarray_boolarrayp' % d),[ ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p) ] ,ctypes.c_int))
        funs.append((('mosek_%(op)s__%(t)sarray_%(t)s_boolarrayp' % d),[ ctypes.c_void_p, ct, ctypes.POINTER(ctypes.c_void_p)] ,ctypes.c_int))
        for which in [ 'all','any' ]:
            d['which'] = which
            funs.append((('mosek_%(which)s_%(op)s__%(t)sarray_%(t)sarray_boolp' % d),[ ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(ctypes.c_int) ] ,ctypes.c_int))
            funs.append((('mosek_%(which)s_%(op)s__%(t)sarray_%(t)s_boolp' % d),[ ctypes.c_void_p, ct, ctypes.POINTER(ctypes.c_int) ] ,ctypes.c_int))
    if at != 'bool':
        funs.append((('mosek_sort__%(t)sarray' % d),[ ctypes.c_void_p ] ,None))
        for indext in [ 'int32', 'int64' ]:
            d['idxt'] = indext
            funs.append((('mosek_argsort__%(idxt)sarray_%(t)sarray' % d),[ ctypes.c_void_p, ctypes.c_void_p ] ,ctypes.c_int))

        for op in array_unop:
            d['op'] = op
            funs.append((('mosek_inplace_%(op)s__%(t)sarray' % d),[ ctypes.c_void_p ] ,ctypes.c_int))

        for op in array_binop:
            d['op'] = op
            funs.append((('mosek_inplace_%(op)s__%(t)sarray_%(t)sarray' % d),[ ctypes.c_void_p, ctypes.c_void_p ] ,ctypes.c_int))
            funs.append((('mosek_inplace_%(op)s__%(t)sarray_%(t)s' % d),[ ctypes.c_void_p, ct ] ,ctypes.c_int))
            funs.append((('mosek_%(op)s__%(t)sarray_%(t)sarray_%(t)sarrayp' % d),[ ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p) ] ,ctypes.c_int))
            funs.append((('mosek_%(op)s__%(t)sarray_%(t)s_%(t)sarrayp' % d),[ ctypes.c_void_p, ct, ctypes.POINTER(ctypes.c_void_p) ] ,ctypes.c_int))





        


__library__ = _native_library(os.path.dirname(__file__),'_array',funs)

del array_types, array_unop, array_binop, array_cmpop,d
