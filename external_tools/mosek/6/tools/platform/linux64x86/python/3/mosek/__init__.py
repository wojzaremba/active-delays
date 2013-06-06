"""
    Mosek/Python Module. An Python interface to Mosek.
   
    Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
"""

import ctypes
import threading
import re
import platform
from mosek import array

# Due to a bug in some python versions, lookup may fail in a multithreaded context if not preloaded.
import codecs
codecs.lookup('utf-8')

try:
    import numpy
except ImportError:
    class numpy:
        class ndarray:
            """
            This is a dummy class. It is used as a stub when numpy is not present.
            """
            pass
        

def __makelibname(base):
    libname = None
    sysname = platform.system()
    if  sysname == 'Darwin':
        libname = 'lib%s.dylib' % base
    elif sysname == 'Windows':
        libname = '%s.dll' % base
    elif sysname == 'Linux':
        libname = 'lib%s.so' % base
    else: # assume linux/posix
        raise ImportError('Unknown system "%s"' % sysname)
    return libname

class TypeAcceptError(Exception):
    pass

class MosekException(Exception):
    pass
class Exception(MosekException):
    def __init__(self,res,msg):
        MosekException(self,msg)
        self.msg   = msg
        self.errno = res
    def __str__(self):
        return "(%d) %s" % (self.errno,self.msg)

class Error(Exception):
    pass

class Warning(Exception):
    pass


def _make_intvector(v):
    """
    check validity of data and create an int32 array. if the argument is
    already a valid array, simply return that.
    """
    if isinstance(v,numpy.ndarray):
        if v.ndim != 1:
            raise TypeAcceptError('expected a 1-dimensional array')
        elif v.dtype.type is numpy.int32:
            return v
        else:
            return array.array(v,array.int32)
    elif isinstance(v,array.ndarray):
        if   v.dtype is array.int32:
            return v
        else:
            return array.array(v,array.int32)
    else:
        return array.array(v,array.int32)

def _make_longvector(v):
    """
    check validity of data and create an int64 array. if the argument is
    already a valid array, simply return that.
    """
    if isinstance(v,numpy.ndarray):
        if v.ndim != 1:
            raise TypeAcceptError('expected a 1-dimensional array')
        elif v.dtype.type is numpy.int64:
            return v
        else:
            return array.array(v,array.int64)
    elif isinstance(v,array.ndarray):
        if   v.dtype is array.int64:
            return v
        else:
            return array.array(v,array.int64)
    else:
        return array.array(v,array.int64)

def _make_doublevector(v):
    """
    Check validity of data and create an int32 array. If the argument is
    already a valid array, simply return that.
    """
    if isinstance(v,numpy.ndarray):
        if v.ndim != 1:
            raise TypeAcceptError('Expected a 1-dimensional array')
        elif v.dtype.type is array.float64:
            return v
        else:
            return array.array(v,array.float64)
    elif isinstance(v,array.ndarray):
        if   v.dtype is array.float64:
            return v
        else:
            return array.array(v,array.float64)
    else:
        return array.array(v,array.float64)

def _check_stringlist(v):
    for i in v:
        if not (isinstance(i,str) or isinstance(i,unicode)):
            raise TypeAcceptError('expected an array of string objests')
    return v 

def _check_taskvector(v):
    for i in v:
        if not (i is None or isinstance(i,Task)):
            raise TypeAcceptError('Expected an array of mosek.Task objests')
    return v
def _accept_intvector(v):
    return v

def _accept_str(v):
    if not isinstance(v,str):
        raise TypeAcceotError("Expected a string argument")
    return v
def _make_anyenumvector(e):
    def acceptvector(v):
        for i in v:
            if not isinstance(i,e):
                raise TypeAcceptError("Expected an array of %s values" % e.__name__)
        return array.array(v,array.int32)
    return acceptvector


def _accept_longvector(v):
    return v

def _accept_doublevector(v):
    return v

def _accept_any(v):
    return v


print(array.__file__)
_make_int = int
_make_long = array.long
_make_double = float
def _make_str(v):
    return str(v)


def _accept_anyenum(e):
    def acceptenum(v):
        if isinstance(v,e):
            return v
        else:
            raise TypeError('Expected an %s enum type' % e.__name__)
    return acceptenum

def accepts(*argtlst):
    """
    Decorator for checking function arguments.
    """
    def acceptsfun(fun):
        def accept(*args):
            if len(args) != len(argtlst):
                raise TypeError('Expected %d argument(s) (%d given)' % (len(argtlst), len(args)))
            try:
                return fun(*[ t(a) for (t,a) in zip(argtlst,args) ])
            except TypeAcceptError as e:
                raise TypeError(e)
        accept.__doc__ = fun.__doc__
        accept.__name__ = fun.__name__
        return accept
    return acceptsfun

    


        
    

class EnumBase(int):
    """
    Base class for enums.
    """
    enumnamere = re.compile(r'[a-zA-Z][a-zA-Z0-9_]*$')
    def __new__(cls,value):
        if isinstance(value,int):
            return cls._valdict[value]
        elif isinstance(value,str):
            return cls._namedict[value.split('.')[-1]]
        else:
            raise TypeError("Invalid type for enum construction")
    def __str__(self):
        return '%s.%s' % (self.__class__.__name__,self.__name__)
    def __repr__(self):
        return self.__name__

    @classmethod
    def __iter__(cls):
        return iter(cls._values)
    @classmethod
    def __getitem__(cls,k):
        return cls._values[k]

    @classmethod
    def __len__(cls):
        return len(cls._values)

    @classmethod
    def _initialize(cls, names,values=None):
        for n in names:
            if not cls.enumnamere.match(n):
                raise ValueError("Invalid enum item name '%s' in %s" % (n,cls.__name__))
        if values is None:
            values = range(len(names))
        if len(values) != len(names):
            raise ValueError("Lengths of names and values do not match")
        
        items = []
        for (n,v) in zip(names,values):
            item = int.__new__(cls,v)
            item.__name__ = n
            setattr(cls,n,item)
            items.append(item)

        cls._values   = items
        cls.values    = items
        cls._namedict = dict([ (v.__name__,v) for v in items ])
        cls._valdict  = dict([ (v,v) for v in items ]) # map int -> enum value (sneaky, eh?)
        

def Enum(name,names,values=None):
    """
    Create a new enum class with the given names and values.
    
    Parameters:
     [name]   A string denoting the name of the enum.
     [names]  A list of strings denoting the names of the individual enum values.
     [values] (optional) A list of integer values of the enums. If given, the
       list must have same length as the [names] parameter. If not given, the
       default values 0, 1, ... will be used.
    """
    e = type(name,(EnumBase,),{})
    e._initialize(names,values)
    return e


# module initialization
__libname = __makelibname('mosekxx6_0')
try:
    global __library__
    global __callback_factory__
    global __library_factory__
    __libname = __makelibname('mosekxx6_0')
    if platform.system() == 'Windows':
        __library_factory__ = ctypes.WinDLL 
        __library__ = ctypes.WinDLL(__libname)
        __callback_factory__ = ctypes.WINFUNCTYPE
    elif platform.system() in [ 'Darwin', 'Linux' ]:
        __library_factory__ = ctypes.CDLL 
        __callback_factory__ = ctypes.CFUNCTYPE
    __library__ = __library_factory__(__libname)
except:
    raise ImportError('Failed to import dll "%s"' % __libname)


__progress_cb_type__ = __callback_factory__(ctypes.c_int, ctypes.POINTER(ctypes.c_void_p), ctypes.c_void_p, ctypes.c_int)
__stream_cb_type__   = __callback_factory__(None, ctypes.c_void_p, ctypes.c_char_p)


__library__.MSK_XX_makeenv.restype      =   ctypes.c_int
__library__.MSK_XX_makeenv.argtypes     = [ ctypes.POINTER(ctypes.c_void_p), 
                                         ctypes.c_void_p, 
                                         ctypes.c_void_p, 
                                         ctypes.c_void_p, 
                                         ctypes.c_char_p ] 
__library__.MSK_XX_deleteenv.argtypes   = [ ctypes.POINTER(ctypes.c_void_p) ] # envp
__library__.MSK_XX_deleteenv.restype    =   ctypes.c_int
__library__.MSK_XX_maketask.argtypes    = [ ctypes.c_void_p,# env
                                         ctypes.c_int, # maxnumcon
                                         ctypes.c_int, # maxnumvar
                                         ctypes.POINTER(ctypes.c_void_p)] # taskp
__library__.MSK_XX_maketask.restype     =   ctypes.c_int
__library__.MSK_XX_deletetask.argtypes  = [ ctypes.POINTER(ctypes.c_void_p) ] # envp
__library__.MSK_XX_deletetask.restype   =   ctypes.c_int
__library__.MSK_XX_putcallbackfunc.argtypes      = [ ctypes.c_void_p, __progress_cb_type__, ctypes.c_void_p ]
__library__.MSK_XX_putcallbackfunc.restype       =   ctypes.c_int
__library__.MSK_XX_linkfunctotaskstream.argtypes = [ ctypes.c_void_p,    # task 
                                                  ctypes.c_int,       # whichstream
                                                  ctypes.c_void_p,    # handle
                                                  __stream_cb_type__ ] # func
__library__.MSK_XX_linkfunctotaskstream.restype  =   ctypes.c_int
__library__.MSK_XX_linkfunctoenvstream.argtypes  = [ ctypes.c_void_p,    # env 
                                                  ctypes.c_int,       # whichstream
                                                  ctypes.c_void_p,    # handle
                                                  __stream_cb_type__ ] # func
__library__.MSK_XX_linkfunctoenvstream.restype   =   ctypes.c_int
__library__.MSK_XX_clonetask.restype     = ctypes.c_int
__library__.MSK_XX_clonetask.argtypes    = [ ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p) ]
__library__.MSK_XX_getlasterror64.restype  = ctypes.c_int
__library__.MSK_XX_getlasterror64.argtypes = [ ctypes.c_void_p, # task
                                          ctypes.POINTER(ctypes.c_int), # lastrescode
                                          ctypes.c_int64, # maxlen
                                          ctypes.POINTER(ctypes.c_int64), # msg len
                                          ctypes.c_char_p, ] # msg
__library__.MSK_XX_putresponsefunc.restype  = ctypes.c_int
__library__.MSK_XX_putresponsefunc.argtypes = [ ctypes.c_void_p,  # task
                                             ctypes.c_void_p,  # func
                                             ctypes.c_void_p ] # handle
__library__.MSK_XX_enablegarcolenv.argtypes = [ ctypes.c_void_p ] 
__library__.MSK_XX_enablegarcolenv.restype  =   ctypes.c_int 

__library__.MSK_XX_analyzeproblem.restype  = ctypes.c_int
__library__.MSK_XX_analyzeproblem.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_analyzesolution.restype  = ctypes.c_int
__library__.MSK_XX_analyzesolution.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_initbasissolve.restype  = ctypes.c_int
__library__.MSK_XX_initbasissolve.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_solvewithbasis.restype  = ctypes.c_int
__library__.MSK_XX_solvewithbasis.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_basiscond.restype  = ctypes.c_int
__library__.MSK_XX_basiscond.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_append.restype  = ctypes.c_int
__library__.MSK_XX_append.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_remove.restype  = ctypes.c_int
__library__.MSK_XX_remove.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_appendcone.restype  = ctypes.c_int
__library__.MSK_XX_appendcone.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_double,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_removecone.restype  = ctypes.c_int
__library__.MSK_XX_removecone.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_chgbound.restype  = ctypes.c_int
__library__.MSK_XX_chgbound.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_getaij.restype  = ctypes.c_int
__library__.MSK_XX_getaij.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getapiecenumnz.restype  = ctypes.c_int
__library__.MSK_XX_getapiecenumnz.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getavecnumnz.restype  = ctypes.c_int
__library__.MSK_XX_getavecnumnz.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getavec.restype  = ctypes.c_int
__library__.MSK_XX_getavec.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getaslicenumnz64.restype  = ctypes.c_int
__library__.MSK_XX_getaslicenumnz64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getaslice64.restype  = ctypes.c_int
__library__.MSK_XX_getaslice64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getaslicetrip.restype  = ctypes.c_int
__library__.MSK_XX_getaslicetrip.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getbound.restype  = ctypes.c_int
__library__.MSK_XX_getbound.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getboundslice.restype  = ctypes.c_int
__library__.MSK_XX_getboundslice.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putboundslice.restype  = ctypes.c_int
__library__.MSK_XX_putboundslice.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getc.restype  = ctypes.c_int
__library__.MSK_XX_getc.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getcfix.restype  = ctypes.c_int
__library__.MSK_XX_getcfix.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getcone.restype  = ctypes.c_int
__library__.MSK_XX_getcone.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getconeinfo.restype  = ctypes.c_int
__library__.MSK_XX_getconeinfo.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getcslice.restype  = ctypes.c_int
__library__.MSK_XX_getcslice.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getdouinf.restype  = ctypes.c_int
__library__.MSK_XX_getdouinf.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getdouparam.restype  = ctypes.c_int
__library__.MSK_XX_getdouparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getdualobj.restype  = ctypes.c_int
__library__.MSK_XX_getdualobj.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getintinf.restype  = ctypes.c_int
__library__.MSK_XX_getintinf.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getlintinf.restype  = ctypes.c_int
__library__.MSK_XX_getlintinf.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getintparam.restype  = ctypes.c_int
__library__.MSK_XX_getintparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getmaxnumanz64.restype  = ctypes.c_int
__library__.MSK_XX_getmaxnumanz64.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getmaxnumcon.restype  = ctypes.c_int
__library__.MSK_XX_getmaxnumcon.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getmaxnumvar.restype  = ctypes.c_int
__library__.MSK_XX_getmaxnumvar.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnamelen64.restype  = ctypes.c_int
__library__.MSK_XX_getnamelen64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getname64.restype  = ctypes.c_int
__library__.MSK_XX_getname64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.c_char_p]
__library__.MSK_XX_getnameapi64.restype  = ctypes.c_int
__library__.MSK_XX_getnameapi64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int64,ctypes.c_char_p]
__library__.MSK_XX_getvarname64.restype  = ctypes.c_int
__library__.MSK_XX_getvarname64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int64,ctypes.c_char_p]
__library__.MSK_XX_getconname64.restype  = ctypes.c_int
__library__.MSK_XX_getconname64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int64,ctypes.c_char_p]
__library__.MSK_XX_getnameindex.restype  = ctypes.c_int
__library__.MSK_XX_getnameindex.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumanz.restype  = ctypes.c_int
__library__.MSK_XX_getnumanz.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumanz64.restype  = ctypes.c_int
__library__.MSK_XX_getnumanz64.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getnumcon.restype  = ctypes.c_int
__library__.MSK_XX_getnumcon.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumcone.restype  = ctypes.c_int
__library__.MSK_XX_getnumcone.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumconemem.restype  = ctypes.c_int
__library__.MSK_XX_getnumconemem.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumintvar.restype  = ctypes.c_int
__library__.MSK_XX_getnumintvar.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumparam.restype  = ctypes.c_int
__library__.MSK_XX_getnumparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumqconknz.restype  = ctypes.c_int
__library__.MSK_XX_getnumqconknz.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumqconknz64.restype  = ctypes.c_int
__library__.MSK_XX_getnumqconknz64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getnumqobjnz.restype  = ctypes.c_int
__library__.MSK_XX_getnumqobjnz.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getnumqobjnz64.restype  = ctypes.c_int
__library__.MSK_XX_getnumqobjnz64.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_getnumvar.restype  = ctypes.c_int
__library__.MSK_XX_getnumvar.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getobjname64.restype  = ctypes.c_int
__library__.MSK_XX_getobjname64.argtypes = [ctypes.c_void_p,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.c_char_p]
__library__.MSK_XX_getprimalobj.restype  = ctypes.c_int
__library__.MSK_XX_getprimalobj.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getprobtype.restype  = ctypes.c_int
__library__.MSK_XX_getprobtype.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getqconk64.restype  = ctypes.c_int
__library__.MSK_XX_getqconk64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getqconk.restype  = ctypes.c_int
__library__.MSK_XX_getqconk.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getqobj.restype  = ctypes.c_int
__library__.MSK_XX_getqobj.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getqobj64.restype  = ctypes.c_int
__library__.MSK_XX_getqobj64.argtypes = [ctypes.c_void_p,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getqobjij.restype  = ctypes.c_int
__library__.MSK_XX_getqobjij.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getsolution.restype  = ctypes.c_int
__library__.MSK_XX_getsolution.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getpbi.restype  = ctypes.c_int
__library__.MSK_XX_getpbi.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_int32]
__library__.MSK_XX_getdbi.restype  = ctypes.c_int
__library__.MSK_XX_getdbi.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getdeqi.restype  = ctypes.c_int
__library__.MSK_XX_getdeqi.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_int32]
__library__.MSK_XX_getpeqi.restype  = ctypes.c_int
__library__.MSK_XX_getpeqi.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_int32]
__library__.MSK_XX_getinti.restype  = ctypes.c_int
__library__.MSK_XX_getinti.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getpcni.restype  = ctypes.c_int
__library__.MSK_XX_getpcni.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getdcni.restype  = ctypes.c_int
__library__.MSK_XX_getdcni.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getsolutioni.restype  = ctypes.c_int
__library__.MSK_XX_getsolutioni.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getsolutioninf.restype  = ctypes.c_int
__library__.MSK_XX_getsolutioninf.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getsolutionstatus.restype  = ctypes.c_int
__library__.MSK_XX_getsolutionstatus.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getsolutionslice.restype  = ctypes.c_int
__library__.MSK_XX_getsolutionslice.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_getsolutionstatuskeyslice.restype  = ctypes.c_int
__library__.MSK_XX_getsolutionstatuskeyslice.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int)]
__library__.MSK_XX_getreducedcosts.restype  = ctypes.c_int
__library__.MSK_XX_getreducedcosts.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_gettaskname64.restype  = ctypes.c_int
__library__.MSK_XX_gettaskname64.argtypes = [ctypes.c_void_p,ctypes.c_int64,ctypes.POINTER(ctypes.c_int64),ctypes.c_char_p]
__library__.MSK_XX_getintpntnumthreads.restype  = ctypes.c_int
__library__.MSK_XX_getintpntnumthreads.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getvartype.restype  = ctypes.c_int
__library__.MSK_XX_getvartype.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getvartypelist.restype  = ctypes.c_int
__library__.MSK_XX_getvartypelist.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int)]
__library__.MSK_XX_inputdata64.restype  = ctypes.c_int
__library__.MSK_XX_inputdata64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.c_double,ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_isdouparname.restype  = ctypes.c_int
__library__.MSK_XX_isdouparname.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_isintparname.restype  = ctypes.c_int
__library__.MSK_XX_isintparname.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_isstrparname.restype  = ctypes.c_int
__library__.MSK_XX_isstrparname.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_linkfiletotaskstream.restype  = ctypes.c_int
__library__.MSK_XX_linkfiletotaskstream.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p,ctypes.c_int32]
__library__.MSK_XX_relaxprimal.restype  = ctypes.c_int
__library__.MSK_XX_relaxprimal.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_void_p),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_optimizeconcurrent.restype  = ctypes.c_int
__library__.MSK_XX_optimizeconcurrent.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_void_p),ctypes.c_int32]
__library__.MSK_XX_checkdata.restype  = ctypes.c_int
__library__.MSK_XX_checkdata.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_netextraction.restype  = ctypes.c_int
__library__.MSK_XX_netextraction.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_netoptimize.restype  = ctypes.c_int
__library__.MSK_XX_netoptimize.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_optimizetrm.restype  = ctypes.c_int
__library__.MSK_XX_optimizetrm.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_printdata.restype  = ctypes.c_int
__library__.MSK_XX_printdata.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_printparam.restype  = ctypes.c_int
__library__.MSK_XX_printparam.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_commitchanges.restype  = ctypes.c_int
__library__.MSK_XX_commitchanges.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_putaij.restype  = ctypes.c_int
__library__.MSK_XX_putaij.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_putaijlist.restype  = ctypes.c_int
__library__.MSK_XX_putaijlist.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putavec.restype  = ctypes.c_int
__library__.MSK_XX_putavec.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putaveclist64.restype  = ctypes.c_int
__library__.MSK_XX_putaveclist64.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putbound.restype  = ctypes.c_int
__library__.MSK_XX_putbound.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_double,ctypes.c_double]
__library__.MSK_XX_putboundlist.restype  = ctypes.c_int
__library__.MSK_XX_putboundlist.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putcfix.restype  = ctypes.c_int
__library__.MSK_XX_putcfix.argtypes = [ctypes.c_void_p,ctypes.c_double]
__library__.MSK_XX_putcj.restype  = ctypes.c_int
__library__.MSK_XX_putcj.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_putobjsense.restype  = ctypes.c_int
__library__.MSK_XX_putobjsense.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_getobjsense.restype  = ctypes.c_int
__library__.MSK_XX_getobjsense.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_putclist.restype  = ctypes.c_int
__library__.MSK_XX_putclist.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putcone.restype  = ctypes.c_int
__library__.MSK_XX_putcone.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_double,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_putdouparam.restype  = ctypes.c_int
__library__.MSK_XX_putdouparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_putintparam.restype  = ctypes.c_int
__library__.MSK_XX_putintparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_putmaxnumcon.restype  = ctypes.c_int
__library__.MSK_XX_putmaxnumcon.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_putmaxnumcone.restype  = ctypes.c_int
__library__.MSK_XX_putmaxnumcone.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_getmaxnumcone.restype  = ctypes.c_int
__library__.MSK_XX_getmaxnumcone.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_putmaxnumvar.restype  = ctypes.c_int
__library__.MSK_XX_putmaxnumvar.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_putmaxnumanz64.restype  = ctypes.c_int
__library__.MSK_XX_putmaxnumanz64.argtypes = [ctypes.c_void_p,ctypes.c_int64]
__library__.MSK_XX_putmaxnumqnz64.restype  = ctypes.c_int
__library__.MSK_XX_putmaxnumqnz64.argtypes = [ctypes.c_void_p,ctypes.c_int64]
__library__.MSK_XX_getmaxnumqnz64.restype  = ctypes.c_int
__library__.MSK_XX_getmaxnumqnz64.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_putnadouparam.restype  = ctypes.c_int
__library__.MSK_XX_putnadouparam.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_double]
__library__.MSK_XX_putnaintparam.restype  = ctypes.c_int
__library__.MSK_XX_putnaintparam.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int32]
__library__.MSK_XX_putname.restype  = ctypes.c_int
__library__.MSK_XX_putname.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_char_p]
__library__.MSK_XX_putnastrparam.restype  = ctypes.c_int
__library__.MSK_XX_putnastrparam.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p]
__library__.MSK_XX_putobjname.restype  = ctypes.c_int
__library__.MSK_XX_putobjname.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_putparam.restype  = ctypes.c_int
__library__.MSK_XX_putparam.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p]
__library__.MSK_XX_putqcon.restype  = ctypes.c_int
__library__.MSK_XX_putqcon.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putqconk.restype  = ctypes.c_int
__library__.MSK_XX_putqconk.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putqobj.restype  = ctypes.c_int
__library__.MSK_XX_putqobj.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putqobjij.restype  = ctypes.c_int
__library__.MSK_XX_putqobjij.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_makesolutionstatusunknown.restype  = ctypes.c_int
__library__.MSK_XX_makesolutionstatusunknown.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_putsolution.restype  = ctypes.c_int
__library__.MSK_XX_putsolution.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_putsolutioni.restype  = ctypes.c_int
__library__.MSK_XX_putsolutioni.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_double,ctypes.c_double,ctypes.c_double,ctypes.c_double]
__library__.MSK_XX_putsolutionyi.restype  = ctypes.c_int
__library__.MSK_XX_putsolutionyi.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_double]
__library__.MSK_XX_putstrparam.restype  = ctypes.c_int
__library__.MSK_XX_putstrparam.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p]
__library__.MSK_XX_puttaskname.restype  = ctypes.c_int
__library__.MSK_XX_puttaskname.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_putvartype.restype  = ctypes.c_int
__library__.MSK_XX_putvartype.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_putvartypelist.restype  = ctypes.c_int
__library__.MSK_XX_putvartypelist.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int)]
__library__.MSK_XX_putvarbranchorder.restype  = ctypes.c_int
__library__.MSK_XX_putvarbranchorder.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_getvarbranchpri.restype  = ctypes.c_int
__library__.MSK_XX_getvarbranchpri.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_getvarbranchdir.restype  = ctypes.c_int
__library__.MSK_XX_getvarbranchdir.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_readdata.restype  = ctypes.c_int
__library__.MSK_XX_readdata.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_readparamfile.restype  = ctypes.c_int
__library__.MSK_XX_readparamfile.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_readsolution.restype  = ctypes.c_int
__library__.MSK_XX_readsolution.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p]
__library__.MSK_XX_readsummary.restype  = ctypes.c_int
__library__.MSK_XX_readsummary.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_resizetask.restype  = ctypes.c_int
__library__.MSK_XX_resizetask.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_checkmemtask.restype  = ctypes.c_int
__library__.MSK_XX_checkmemtask.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int32]
__library__.MSK_XX_getmemusagetask64.restype  = ctypes.c_int
__library__.MSK_XX_getmemusagetask64.argtypes = [ctypes.c_void_p,ctypes.POINTER(ctypes.c_int64),ctypes.POINTER(ctypes.c_int64)]
__library__.MSK_XX_setdefaults.restype  = ctypes.c_int
__library__.MSK_XX_setdefaults.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_solutiondef.restype  = ctypes.c_int
__library__.MSK_XX_solutiondef.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_deletesolution.restype  = ctypes.c_int
__library__.MSK_XX_deletesolution.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_undefsolution.restype  = ctypes.c_int
__library__.MSK_XX_undefsolution.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_solutionsummary.restype  = ctypes.c_int
__library__.MSK_XX_solutionsummary.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_optimizersummary.restype  = ctypes.c_int
__library__.MSK_XX_optimizersummary.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_strtoconetype.restype  = ctypes.c_int
__library__.MSK_XX_strtoconetype.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_strtosk.restype  = ctypes.c_int
__library__.MSK_XX_strtosk.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_writedata.restype  = ctypes.c_int
__library__.MSK_XX_writedata.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_readbranchpriorities.restype  = ctypes.c_int
__library__.MSK_XX_readbranchpriorities.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_writebranchpriorities.restype  = ctypes.c_int
__library__.MSK_XX_writebranchpriorities.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_writeparamfile.restype  = ctypes.c_int
__library__.MSK_XX_writeparamfile.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_getinfeasiblesubproblem.restype  = ctypes.c_int
__library__.MSK_XX_getinfeasiblesubproblem.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_void_p)]
__library__.MSK_XX_writesolution.restype  = ctypes.c_int
__library__.MSK_XX_writesolution.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p]
__library__.MSK_XX_primalsensitivity.restype  = ctypes.c_int
__library__.MSK_XX_primalsensitivity.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int),ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_sensitivityreport.restype  = ctypes.c_int
__library__.MSK_XX_sensitivityreport.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_dualsensitivity.restype  = ctypes.c_int
__library__.MSK_XX_dualsensitivity.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_checkconvexity.restype  = ctypes.c_int
__library__.MSK_XX_checkconvexity.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_appendvars.restype  = ctypes.c_int
__library__.MSK_XX_appendvars.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_appendcons.restype  = ctypes.c_int
__library__.MSK_XX_appendcons.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double),ctypes.POINTER(ctypes.c_double)]
__library__.MSK_XX_startstat.restype  = ctypes.c_int
__library__.MSK_XX_startstat.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_stopstat.restype  = ctypes.c_int
__library__.MSK_XX_stopstat.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_appendstat.restype  = ctypes.c_int
__library__.MSK_XX_appendstat.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_core_appendcones.restype  = ctypes.c_int
__library__.MSK_XX_core_appendcones.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_double,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_core_removecones.restype  = ctypes.c_int
__library__.MSK_XX_core_removecones.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_core_append.restype  = ctypes.c_int
__library__.MSK_XX_core_append.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_checkoutlicense.restype  = ctypes.c_int
__library__.MSK_XX_checkoutlicense.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_checkinlicense.restype  = ctypes.c_int
__library__.MSK_XX_checkinlicense.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_echointro.restype  = ctypes.c_int
__library__.MSK_XX_echointro.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_getversion.restype  = ctypes.c_int
__library__.MSK_XX_getversion.argtypes = [ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32),ctypes.POINTER(ctypes.c_int32)]
__library__.MSK_XX_linkfiletoenvstream.restype  = ctypes.c_int
__library__.MSK_XX_linkfiletoenvstream.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_char_p,ctypes.c_int32]
__library__.MSK_XX_initenv.restype  = ctypes.c_int
__library__.MSK_XX_initenv.argtypes = [ctypes.c_void_p]
__library__.MSK_XX_putdllpath.restype  = ctypes.c_int
__library__.MSK_XX_putdllpath.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
__library__.MSK_XX_putlicensedefaults.restype  = ctypes.c_int
__library__.MSK_XX_putlicensedefaults.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.POINTER(ctypes.c_int32),ctypes.c_int32,ctypes.c_int32]
__library__.MSK_XX_putkeepdlls.restype  = ctypes.c_int
__library__.MSK_XX_putkeepdlls.argtypes = [ctypes.c_void_p,ctypes.c_int32]
__library__.MSK_XX_putcpudefaults.restype  = ctypes.c_int
__library__.MSK_XX_putcpudefaults.argtypes = [ctypes.c_void_p,ctypes.c_int32,ctypes.c_int32,ctypes.c_int32]

__scopt__ = None
__scopt_guard__ = threading.Lock()
def __load_scopt__():
    global __scopt__
    __scopt_guard__.acquire()
    try:
        if __scopt__ is None:
            __scopt__ = __library_factory__(__makelibname('scopt'))
            __scopt__.MSK_scbegin.restype  = ctypes.c_int
            __scopt__.MSK_scbegin.argtypes = [ ctypes.c_void_p, # task
                                               ctypes.c_int, # numopro
                                               ctypes.POINTER(ctypes.c_int), # opro
                                               ctypes.POINTER(ctypes.c_int), # oprjo
                                               ctypes.POINTER(ctypes.c_double), # oprfo
                                               ctypes.POINTER(ctypes.c_double), # oprgo
                                               ctypes.POINTER(ctypes.c_double), # oprho
                                               ctypes.c_int, # numoprc
                                               ctypes.POINTER(ctypes.c_int), # oprc
                                               ctypes.POINTER(ctypes.c_int), # opric
                                               ctypes.POINTER(ctypes.c_int), # oprjc
                                               ctypes.POINTER(ctypes.c_double), # oprfc
                                               ctypes.POINTER(ctypes.c_double), # oprgc
                                               ctypes.POINTER(ctypes.c_double), # oprhc
                                               ctypes.POINTER(ctypes.c_void_p),  # schandle
                                               ]
            __scopt__.MSK_scend.restype  = ctypes.c_int
            __scopt__.MSK_scend.argtypes = [ ctypes.c_void_p, # task
                                             ctypes.c_void_p, # schandle
                                             ]
    finally:
        __scopt_guard__.release()
scopr = Enum("scopr", ["ent","exp","log","pow"], [ 0, 1, 2, 3 ])
solveform = Enum("solveform", ["dual","free","primal"], [2,0,1])
accmode = Enum("accmode", ["con","var"], [1,0])
sensitivitytype = Enum("sensitivitytype", ["basis","optimal_partition"], [0,1])
qreadtype = Enum("qreadtype", ["add","drop_lower","drop_upper"], [0,1,2])
iparam = Enum("iparam", ["alloc_add_qnz","ana_sol_basis","ana_sol_print_violated","auto_sort_a_before_opt","auto_update_sol_info","basis_solve_use_plus_one","bi_clean_optimizer","bi_ignore_max_iter","bi_ignore_num_error","bi_max_iterations","cache_license","cache_size_l1","cache_size_l2","check_convexity","check_task_data","concurrent_num_optimizers","concurrent_priority_dual_simplex","concurrent_priority_free_simplex","concurrent_priority_intpnt","concurrent_priority_primal_simplex","cpu_type","data_check","feasrepair_optimize","infeas_generic_names","infeas_prefer_primal","infeas_report_auto","infeas_report_level","intpnt_basis","intpnt_diff_step","intpnt_factor_debug_lvl","intpnt_factor_method","intpnt_max_iterations","intpnt_max_num_cor","intpnt_max_num_refinement_steps","intpnt_num_threads","intpnt_off_col_trh","intpnt_order_method","intpnt_regularization_use","intpnt_scaling","intpnt_solve_form","intpnt_starting_point","lic_trh_expiry_wrn","license_allow_overuse","license_cache_time","license_check_time","license_debug","license_pause_time","license_suppress_expire_wrns","license_wait","log","log_bi","log_bi_freq","log_check_convexity","log_concurrent","log_cut_second_opt","log_factor","log_feasrepair","log_file","log_head","log_infeas_ana","log_intpnt","log_mio","log_mio_freq","log_nonconvex","log_optimizer","log_order","log_param","log_presolve","log_response","log_sensitivity","log_sensitivity_opt","log_sim","log_sim_freq","log_sim_minor","log_sim_network_freq","log_storage","lp_write_ignore_incompatible_items","max_num_warnings","mio_branch_dir","mio_branch_priorities_use","mio_construct_sol","mio_cont_sol","mio_cut_level_root","mio_cut_level_tree","mio_feaspump_level","mio_heuristic_level","mio_hotstart","mio_keep_basis","mio_local_branch_number","mio_max_num_branches","mio_max_num_relaxs","mio_max_num_solutions","mio_mode","mio_node_optimizer","mio_node_selection","mio_optimizer_mode","mio_presolve_aggregate","mio_presolve_probing","mio_presolve_use","mio_root_optimizer","mio_strong_branch","nonconvex_max_iterations","objective_sense","opf_max_terms_per_line","opf_write_header","opf_write_hints","opf_write_parameters","opf_write_problem","opf_write_sol_bas","opf_write_sol_itg","opf_write_sol_itr","opf_write_solutions","optimizer","param_read_case_name","param_read_ign_error","presolve_elim_fill","presolve_eliminator_max_num_tries","presolve_eliminator_use","presolve_level","presolve_lindep_use","presolve_lindep_work_lim","presolve_use","qo_separable_reformulation","read_add_anz","read_add_con","read_add_cone","read_add_qnz","read_add_var","read_anz","read_con","read_cone","read_data_compressed","read_data_format","read_keep_free_con","read_lp_drop_new_vars_in_bou","read_lp_quoted_names","read_mps_format","read_mps_keep_int","read_mps_obj_sense","read_mps_quoted_names","read_mps_relax","read_mps_width","read_q_mode","read_qnz","read_task_ignore_param","read_var","sensitivity_all","sensitivity_optimizer","sensitivity_type","sim_basis_factor_use","sim_degen","sim_dual_crash","sim_dual_phaseone_method","sim_dual_restrict_selection","sim_dual_selection","sim_exploit_dupvec","sim_hotstart","sim_hotstart_lu","sim_integer","sim_max_iterations","sim_max_num_setbacks","sim_network_detect","sim_network_detect_hotstart","sim_network_detect_method","sim_non_singular","sim_primal_crash","sim_primal_phaseone_method","sim_primal_restrict_selection","sim_primal_selection","sim_refactor_freq","sim_reformulation","sim_save_lu","sim_scaling","sim_scaling_method","sim_solve_form","sim_stability_priority","sim_switch_optimizer","sol_filter_keep_basic","sol_filter_keep_ranged","sol_quoted_names","sol_read_name_width","sol_read_width","solution_callback","timing_level","warning_level","write_bas_constraints","write_bas_head","write_bas_variables","write_data_compressed","write_data_format","write_data_param","write_free_con","write_generic_names","write_generic_names_io","write_int_constraints","write_int_head","write_int_variables","write_lp_line_width","write_lp_quoted_names","write_lp_strict_format","write_lp_terms_per_line","write_mps_int","write_mps_obj_sense","write_mps_quoted_names","write_mps_strict","write_precision","write_sol_constraints","write_sol_head","write_sol_variables","write_task_inc_sol","write_xml_mode"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210])
adopcode = Enum("adopcode", ["add","div","exp","log","mul","pow","ret","sub"], [0,3,5,6,2,4,7,1])
solsta = Enum("solsta", ["dual_feas","dual_infeas_cer","integer_optimal","near_dual_feas","near_dual_infeas_cer","near_integer_optimal","near_optimal","near_prim_and_dual_feas","near_prim_feas","near_prim_infeas_cer","optimal","prim_and_dual_feas","prim_feas","prim_infeas_cer","unknown"], [3,6,14,10,13,15,8,11,9,12,1,4,2,5,0])
objsense = Enum("objsense", ["maximize","minimize","undefined"], [2,1,0])
solitem = Enum("solitem", ["slc","slx","snx","suc","sux","xc","xx","y"], [3,5,7,4,6,0,1,2])
boundkey = Enum("boundkey", ["fr","fx","lo","ra","up"], [3,2,0,4,1])
basindtype = Enum("basindtype", ["always","if_feasible","never","no_error","other"], [1,3,0,2,4])
branchdir = Enum("branchdir", ["down","free","up"], [2,0,1])
liinfitem = Enum("liinfitem", ["bi_clean_dual_deg_iter","bi_clean_dual_iter","bi_clean_primal_deg_iter","bi_clean_primal_dual_deg_iter","bi_clean_primal_dual_iter","bi_clean_primal_dual_sub_iter","bi_clean_primal_iter","bi_dual_iter","bi_primal_iter","intpnt_factor_num_nz","mio_intpnt_iter","mio_simplex_iter","rd_numanz","rd_numqnz"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
streamtype = Enum("streamtype", ["err","log","msg","wrn"], [2,0,1,3])
simhotstart = Enum("simhotstart", ["free","none","status_keys"], [1,0,2])
callbackcode = Enum("callbackcode", ["begin_bi","begin_concurrent","begin_conic","begin_dual_bi","begin_dual_sensitivity","begin_dual_setup_bi","begin_dual_simplex","begin_dual_simplex_bi","begin_full_convexity_check","begin_infeas_ana","begin_intpnt","begin_license_wait","begin_mio","begin_network_dual_simplex","begin_network_primal_simplex","begin_network_simplex","begin_nonconvex","begin_optimizer","begin_presolve","begin_primal_bi","begin_primal_dual_simplex","begin_primal_dual_simplex_bi","begin_primal_sensitivity","begin_primal_setup_bi","begin_primal_simplex","begin_primal_simplex_bi","begin_qcqo_reformulate","begin_read","begin_simplex","begin_simplex_bi","begin_simplex_network_detect","begin_write","conic","dual_simplex","end_bi","end_concurrent","end_conic","end_dual_bi","end_dual_sensitivity","end_dual_setup_bi","end_dual_simplex","end_dual_simplex_bi","end_full_convexity_check","end_infeas_ana","end_intpnt","end_license_wait","end_mio","end_network_dual_simplex","end_network_primal_simplex","end_network_simplex","end_nonconvex","end_optimizer","end_presolve","end_primal_bi","end_primal_dual_simplex","end_primal_dual_simplex_bi","end_primal_sensitivity","end_primal_setup_bi","end_primal_simplex","end_primal_simplex_bi","end_qcqo_reformulate","end_read","end_simplex","end_simplex_bi","end_simplex_network_detect","end_write","im_bi","im_conic","im_dual_bi","im_dual_sensivity","im_dual_simplex","im_full_convexity_check","im_intpnt","im_license_wait","im_lu","im_mio","im_mio_dual_simplex","im_mio_intpnt","im_mio_presolve","im_mio_primal_simplex","im_network_dual_simplex","im_network_primal_simplex","im_nonconvex","im_order","im_presolve","im_primal_bi","im_primal_dual_simplex","im_primal_sensivity","im_primal_simplex","im_qo_reformulate","im_simplex","im_simplex_bi","intpnt","new_int_mio","noncovex","primal_simplex","qcone","read_add_anz","read_add_cones","read_add_cons","read_add_qnz","read_add_vars","read_opf","read_opf_section","update_dual_bi","update_dual_simplex","update_dual_simplex_bi","update_network_dual_simplex","update_network_primal_simplex","update_nonconvex","update_presolve","update_primal_bi","update_primal_dual_simplex","update_primal_dual_simplex_bi","update_primal_simplex","update_primal_simplex_bi","write_opf"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116])
problemitem = Enum("problemitem", ["con","cone","var"], [1,2,0])
feature = Enum("feature", ["ptom","pton","ptox","pts"], [2,1,3,0])
sparam = Enum("sparam", ["bas_sol_file_name","data_file_name","debug_file_name","feasrepair_name_prefix","feasrepair_name_separator","feasrepair_name_wsumviol","int_sol_file_name","itr_sol_file_name","param_comment_sign","param_read_file_name","param_write_file_name","read_mps_bou_name","read_mps_obj_name","read_mps_ran_name","read_mps_rhs_name","sensitivity_file_name","sensitivity_res_file_name","sol_filter_xc_low","sol_filter_xc_upr","sol_filter_xx_low","sol_filter_xx_upr","stat_file_name","stat_key","stat_name","write_lp_gen_var_name"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24])
mark = Enum("mark", ["lo","up"], [0,1])
conetype = Enum("conetype", ["quad","rquad"], [0,1])
feasrepairtype = Enum("feasrepairtype", ["optimize_combined","optimize_none","optimize_penalty"], [2,0,1])
iomode = Enum("iomode", ["read","readwrite","write"], [0,2,1])
adoptype = Enum("adoptype", ["constant","none","reference","variable"], [1,0,3,2])
simseltype = Enum("simseltype", ["ase","devex","free","full","partial","se"], [2,3,0,1,5,4])
msgkey = Enum("msgkey", ["mps_selected","reading_file","writing_file"], [1100,1000,1001])
miomode = Enum("miomode", ["ignored","lazy","satisfied"], [0,2,1])
dinfitem = Enum("dinfitem", ["bi_clean_dual_time","bi_clean_primal_dual_time","bi_clean_primal_time","bi_clean_time","bi_dual_time","bi_primal_time","bi_time","concurrent_time","intpnt_dual_feas","intpnt_dual_obj","intpnt_factor_num_flops","intpnt_kap_div_tau","intpnt_order_time","intpnt_primal_feas","intpnt_primal_obj","intpnt_time","mio_construct_solution_obj","mio_heuristic_time","mio_obj_abs_gap","mio_obj_bound","mio_obj_int","mio_obj_rel_gap","mio_optimizer_time","mio_root_optimizer_time","mio_root_presolve_time","mio_time","mio_user_obj_cut","optimizer_time","presolve_eli_time","presolve_lindep_time","presolve_time","qcqo_reformulate_time","rd_time","sim_dual_time","sim_feas","sim_network_dual_time","sim_network_primal_time","sim_network_time","sim_obj","sim_primal_dual_time","sim_primal_time","sim_time","sol_bas_dual_obj","sol_bas_max_dbi","sol_bas_max_deqi","sol_bas_max_pbi","sol_bas_max_peqi","sol_bas_max_pinti","sol_bas_primal_obj","sol_int_max_pbi","sol_int_max_peqi","sol_int_max_pinti","sol_int_primal_obj","sol_itr_dual_obj","sol_itr_max_dbi","sol_itr_max_dcni","sol_itr_max_deqi","sol_itr_max_pbi","sol_itr_max_pcni","sol_itr_max_peqi","sol_itr_max_pinti","sol_itr_primal_obj"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61])
parametertype = Enum("parametertype", ["dou_type","int_type","invalid_type","str_type"], [1,2,0,3])
rescodetype = Enum("rescodetype", ["err","ok","trm","unk","wrn"], [3,0,2,4,1])
prosta = Enum("prosta", ["dual_feas","dual_infeas","ill_posed","near_dual_feas","near_prim_and_dual_feas","near_prim_feas","prim_and_dual_feas","prim_and_dual_infeas","prim_feas","prim_infeas","prim_infeas_or_unbounded","unknown"], [3,5,7,10,8,9,1,6,2,4,11,0])
scalingtype = Enum("scalingtype", ["aggressive","free","moderate","none"], [3,0,2,1])
rescode = Enum("rescode", ["err_ad_invalid_codelist","err_ad_invalid_operand","err_ad_invalid_operator","err_ad_missing_operand","err_ad_missing_return","err_api_array_too_small","err_api_cb_connect","err_api_fatal_error","err_api_internal","err_argument_dimension","err_argument_lenneq","err_argument_perm_array","err_argument_type","err_basis","err_basis_factor","err_basis_singular","err_blank_name","err_cannot_clone_nl","err_cannot_handle_nl","err_con_q_not_nsd","err_con_q_not_psd","err_concurrent_optimizer","err_cone_index","err_cone_overlap","err_cone_rep_var","err_cone_size","err_cone_type","err_cone_type_str","err_data_file_ext","err_dup_name","err_end_of_file","err_factor","err_feasrepair_cannot_relax","err_feasrepair_inconsistent_bound","err_feasrepair_solving_relaxed","err_file_license","err_file_open","err_file_read","err_file_write","err_first","err_firsti","err_firstj","err_fixed_bound_values","err_flexlm","err_huge_aij","err_huge_c","err_identical_tasks","err_in_argument","err_index","err_index_arr_is_too_large","err_index_arr_is_too_small","err_index_is_too_large","err_index_is_too_small","err_inf_dou_index","err_inf_dou_name","err_inf_int_index","err_inf_int_name","err_inf_lint_index","err_inf_lint_name","err_inf_type","err_infeas_undefined","err_infinite_bound","err_int64_to_int32_cast","err_internal","err_internal_test_failed","err_inv_aptre","err_inv_bk","err_inv_bkc","err_inv_bkx","err_inv_cone_type","err_inv_cone_type_str","err_inv_marki","err_inv_markj","err_inv_name_item","err_inv_numi","err_inv_numj","err_inv_optimizer","err_inv_problem","err_inv_qcon_subi","err_inv_qcon_subj","err_inv_qcon_subk","err_inv_qcon_val","err_inv_qobj_subi","err_inv_qobj_subj","err_inv_qobj_val","err_inv_sk","err_inv_sk_str","err_inv_skc","err_inv_skn","err_inv_skx","err_inv_var_type","err_invalid_accmode","err_invalid_ampl_stub","err_invalid_branch_direction","err_invalid_branch_priority","err_invalid_compression","err_invalid_file_name","err_invalid_format_type","err_invalid_iomode","err_invalid_mbt_file","err_invalid_name_in_sol_file","err_invalid_obj_name","err_invalid_objective_sense","err_invalid_sol_file_name","err_invalid_stream","err_invalid_surplus","err_invalid_task","err_invalid_utf8","err_invalid_wchar","err_last","err_lasti","err_lastj","err_license","err_license_cannot_allocate","err_license_cannot_connect","err_license_expired","err_license_feature","err_license_invalid_hostid","err_license_max","err_license_moseklm_daemon","err_license_no_server_support","err_license_server","err_license_server_version","err_license_version","err_link_file_dll","err_living_tasks","err_lp_dup_slack_name","err_lp_empty","err_lp_file_format","err_lp_format","err_lp_free_constraint","err_lp_incompatible","err_lp_invalid_con_name","err_lp_invalid_var_name","err_lp_write_conic_problem","err_lp_write_geco_problem","err_lu_max_num_tries","err_maxnumcon","err_maxnumcone","err_maxnumqnz","err_maxnumvar","err_mbt_incompatible","err_mio_no_optimizer","err_mio_not_loaded","err_missing_license_file","err_mixed_problem","err_mps_cone_overlap","err_mps_cone_repeat","err_mps_cone_type","err_mps_file","err_mps_inv_bound_key","err_mps_inv_con_key","err_mps_inv_field","err_mps_inv_marker","err_mps_inv_sec_name","err_mps_inv_sec_order","err_mps_invalid_obj_name","err_mps_invalid_objsense","err_mps_mul_con_name","err_mps_mul_csec","err_mps_mul_qobj","err_mps_mul_qsec","err_mps_no_objective","err_mps_null_con_name","err_mps_null_var_name","err_mps_splitted_var","err_mps_tab_in_field2","err_mps_tab_in_field3","err_mps_tab_in_field5","err_mps_undef_con_name","err_mps_undef_var_name","err_mul_a_element","err_name_is_null","err_name_max_len","err_nan_in_aij","err_nan_in_blc","err_nan_in_blx","err_nan_in_buc","err_nan_in_bux","err_nan_in_c","err_nan_in_double_data","err_negative_append","err_negative_surplus","err_newer_dll","err_no_basis_sol","err_no_dual_for_itg_sol","err_no_dual_infeas_cer","err_no_init_env","err_no_optimizer_var_type","err_no_primal_infeas_cer","err_no_solution_in_callback","err_nonconvex","err_nonlinear_equality","err_nonlinear_ranged","err_nr_arguments","err_null_env","err_null_pointer","err_null_task","err_numconlim","err_numvarlim","err_obj_q_not_nsd","err_obj_q_not_psd","err_objective_range","err_older_dll","err_open_dl","err_opf_format","err_opf_new_variable","err_opf_premature_eof","err_optimizer_license","err_ord_invalid","err_ord_invalid_branch_dir","err_overflow","err_param_index","err_param_is_too_large","err_param_is_too_small","err_param_name","err_param_name_dou","err_param_name_int","err_param_name_str","err_param_type","err_param_value_str","err_platform_not_licensed","err_postsolve","err_pro_item","err_prob_license","err_qcon_subi_too_large","err_qcon_subi_too_small","err_qcon_upper_triangle","err_qobj_upper_triangle","err_read_format","err_read_lp_missing_end_tag","err_read_lp_nonexisting_name","err_remove_cone_variable","err_sen_bound_invalid_lo","err_sen_bound_invalid_up","err_sen_format","err_sen_index_invalid","err_sen_index_range","err_sen_invalid_regexp","err_sen_numerical","err_sen_solution_status","err_sen_undef_name","err_size_license","err_size_license_con","err_size_license_intvar","err_size_license_numcores","err_size_license_var","err_sol_file_invalid_number","err_solitem","err_solver_probtype","err_space","err_space_leaking","err_space_no_info","err_thread_cond_init","err_thread_create","err_thread_mutex_init","err_thread_mutex_lock","err_thread_mutex_unlock","err_too_small_maxnumanz","err_unb_step_size","err_undef_solution","err_undefined_objective_sense","err_unknown","err_user_func_ret","err_user_func_ret_data","err_user_nlo_eval","err_user_nlo_eval_hessubi","err_user_nlo_eval_hessubj","err_user_nlo_func","err_whichitem_not_allowed","err_whichsol","err_write_lp_format","err_write_lp_non_unique_name","err_write_mps_invalid_name","err_write_opf_invalid_var_name","err_writing_file","err_xml_invalid_problem_type","err_y_is_undefined","ok","trm_internal","trm_internal_stop","trm_max_iterations","trm_max_num_setbacks","trm_max_time","trm_mio_near_abs_gap","trm_mio_near_rel_gap","trm_mio_num_branches","trm_mio_num_relaxs","trm_num_max_num_int_solutions","trm_numerical_problem","trm_objective_range","trm_stall","trm_user_break","trm_user_callback","wrn_ana_almost_int_bounds","wrn_ana_c_zero","wrn_ana_close_bounds","wrn_ana_empty_cols","wrn_ana_large_bounds","wrn_construct_invalid_sol_itg","wrn_construct_no_sol_itg","wrn_construct_solution_infeas","wrn_dropped_nz_qobj","wrn_eliminator_space","wrn_empty_name","wrn_ignore_integer","wrn_incomplete_linear_dependency_check","wrn_large_aij","wrn_large_bound","wrn_large_cj","wrn_large_con_fx","wrn_large_lo_bound","wrn_large_up_bound","wrn_license_expire","wrn_license_feature_expire","wrn_license_server","wrn_lp_drop_variable","wrn_lp_old_quad_format","wrn_mio_infeasible_final","wrn_mps_split_bou_vector","wrn_mps_split_ran_vector","wrn_mps_split_rhs_vector","wrn_name_max_len","wrn_no_global_optimizer","wrn_nz_in_upr_tri","wrn_open_param_file","wrn_presolve_bad_precision","wrn_presolve_outofspace","wrn_sol_file_ignored_con","wrn_sol_file_ignored_var","wrn_sol_filter","wrn_spar_max_len","wrn_too_few_basis_vars","wrn_too_many_basis_vars","wrn_undef_sol_file_name","wrn_using_generic_names","wrn_write_discarded_cfix","wrn_zero_aij","wrn_zeros_in_sparse_col","wrn_zeros_in_sparse_row"], [3102,3104,3103,3105,3106,3001,3002,3005,3999,1201,1197,1299,1198,1266,1610,1615,1070,2505,2506,1294,1293,3059,1300,1302,1303,1301,1305,1306,1055,1071,1059,1650,1700,1702,1701,1007,1052,1053,1054,1261,1285,1287,1425,1014,1380,1375,3101,1200,1235,1222,1221,1204,1203,1219,1230,1220,1231,1225,1234,1232,3910,1400,3800,3000,3500,1253,1255,1256,1257,1272,1271,2501,2502,1280,2503,2504,1550,1500,1405,1406,1404,1407,1401,1402,1403,1270,1269,1267,1274,1268,1258,2520,3700,3200,3201,1800,1056,1283,1801,1058,1170,1075,1445,1057,1062,1275,1064,2900,2901,1262,1286,1288,1000,1020,1021,1001,1018,1025,1016,1017,1027,1015,1026,1002,1040,1066,1152,1151,1157,1160,1155,1150,1171,1154,1163,1164,2800,1240,1304,1243,1241,2550,1551,1553,1008,1501,1118,1119,1117,1100,1108,1107,1101,1102,1109,1115,1128,1122,1112,1116,1114,1113,1110,1103,1104,1111,1125,1126,1127,1105,1106,1254,1760,1750,1473,1461,1471,1462,1472,1470,1450,1264,1263,1036,1600,2950,2001,1063,1552,2000,2500,1291,1290,1292,1199,1060,1065,1061,1250,1251,1296,1295,1260,1035,1030,1168,1169,1172,1013,1131,1130,1590,1210,1215,1216,1205,1206,1207,1208,1218,1217,1019,1580,1281,1006,1409,1408,1417,1415,1090,1159,1162,1310,3054,3053,3050,3055,3052,3056,3058,3057,3051,1005,1010,1012,3900,1011,1350,1237,1259,1051,1080,1081,1049,1048,1045,1046,1047,1252,3100,1265,1446,1050,1430,1431,1433,1440,1441,1432,1238,1236,1158,1161,1153,1156,1166,3600,1449,0,4030,4031,4000,4020,4001,4004,4003,4009,4008,4015,4025,4002,4006,4005,4007,904,901,903,902,900,807,810,805,201,801,502,250,800,62,51,57,54,52,53,500,505,501,85,80,270,72,71,70,65,251,200,50,803,802,351,352,300,66,400,405,350,503,804,63,710,705])
mionodeseltype = Enum("mionodeseltype", ["best","first","free","hybrid","pseudo","worst"], [2,1,0,4,5,3])
onoffkey = Enum("onoffkey", ["off","on"], [0,1])
simdegen = Enum("simdegen", ["aggressive","free","minimum","moderate","none"], [2,1,4,3,0])
dataformat = Enum("dataformat", ["extension","free_mps","lp","mbt","mps","op","xml"], [0,6,2,3,1,4,5])
orderingtype = Enum("orderingtype", ["appminloc1","appminloc2","free","graphpar1","graphpar2","none"], [1,2,0,3,4,5])
problemtype = Enum("problemtype", ["conic","geco","lo","mixed","qcqo","qo"], [4,3,0,5,2,1])
inftype = Enum("inftype", ["dou_type","int_type","lint_type"], [0,1,2])
presolvemode = Enum("presolvemode", ["free","off","on"], [2,0,1])
dparam = Enum("dparam", ["ana_sol_infeas_tol","basis_rel_tol_s","basis_tol_s","basis_tol_x","callback_freq","check_convexity_rel_tol","data_tol_aij","data_tol_aij_huge","data_tol_aij_large","data_tol_bound_inf","data_tol_bound_wrn","data_tol_c_huge","data_tol_cj_large","data_tol_qij","data_tol_x","feasrepair_tol","intpnt_co_tol_dfeas","intpnt_co_tol_infeas","intpnt_co_tol_mu_red","intpnt_co_tol_near_rel","intpnt_co_tol_pfeas","intpnt_co_tol_rel_gap","intpnt_nl_merit_bal","intpnt_nl_tol_dfeas","intpnt_nl_tol_mu_red","intpnt_nl_tol_near_rel","intpnt_nl_tol_pfeas","intpnt_nl_tol_rel_gap","intpnt_nl_tol_rel_step","intpnt_tol_dfeas","intpnt_tol_dsafe","intpnt_tol_infeas","intpnt_tol_mu_red","intpnt_tol_path","intpnt_tol_pfeas","intpnt_tol_psafe","intpnt_tol_rel_gap","intpnt_tol_rel_step","intpnt_tol_step_size","lower_obj_cut","lower_obj_cut_finite_trh","mio_disable_term_time","mio_heuristic_time","mio_max_time","mio_max_time_aprx_opt","mio_near_tol_abs_gap","mio_near_tol_rel_gap","mio_rel_add_cut_limited","mio_rel_gap_const","mio_tol_abs_gap","mio_tol_abs_relax_int","mio_tol_feas","mio_tol_rel_gap","mio_tol_rel_relax_int","mio_tol_x","nonconvex_tol_feas","nonconvex_tol_opt","optimizer_max_time","presolve_tol_aij","presolve_tol_lin_dep","presolve_tol_s","presolve_tol_x","qcqo_reformulate_rel_drop_tol","sim_lu_tol_rel_piv","simplex_abs_tol_piv","upper_obj_cut","upper_obj_cut_finite_trh"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66])
simdupvec = Enum("simdupvec", ["free","off","on"], [2,0,1])
networkdetect = Enum("networkdetect", ["advanced","free","simple"], [2,0,1])
compresstype = Enum("compresstype", ["free","gzip","none"], [1,2,0])
mpsformat = Enum("mpsformat", ["free","relaxed","strict"], [2,1,0])
variabletype = Enum("variabletype", ["type_cont","type_int"], [0,1])
checkconvexitytype = Enum("checkconvexitytype", ["full","none","simple"], [2,0,1])
language = Enum("language", ["dan","eng"], [1,0])
startpointtype = Enum("startpointtype", ["constant","free","guess","satisfy_bounds"], [2,0,1,3])
soltype = Enum("soltype", ["bas","itg","itr"], [1,2,0])
scalingmethod = Enum("scalingmethod", ["free","pow2"], [1,0])
value = Enum("value", ["license_buffer_length","max_str_len"], [20,1024])
stakey = Enum("stakey", ["bas","fix","inf","low","supbas","unk","upr"], [1,5,6,3,2,0,4])
simreform = Enum("simreform", ["aggressive","free","off","on"], [3,2,0,1])
iinfitem = Enum("iinfitem", ["ana_pro_num_con","ana_pro_num_con_eq","ana_pro_num_con_fr","ana_pro_num_con_lo","ana_pro_num_con_ra","ana_pro_num_con_up","ana_pro_num_var","ana_pro_num_var_bin","ana_pro_num_var_cont","ana_pro_num_var_eq","ana_pro_num_var_fr","ana_pro_num_var_int","ana_pro_num_var_lo","ana_pro_num_var_ra","ana_pro_num_var_up","cache_size_l1","cache_size_l2","concurrent_fastest_optimizer","cpu_type","intpnt_factor_num_offcol","intpnt_iter","intpnt_num_threads","intpnt_solve_dual","mio_construct_solution","mio_initial_solution","mio_num_active_nodes","mio_num_branch","mio_num_cuts","mio_num_int_solutions","mio_num_relax","mio_numcon","mio_numint","mio_numvar","mio_total_num_basis_cuts","mio_total_num_branch","mio_total_num_cardgub_cuts","mio_total_num_clique_cuts","mio_total_num_coef_redc_cuts","mio_total_num_contra_cuts","mio_total_num_cuts","mio_total_num_disagg_cuts","mio_total_num_flow_cover_cuts","mio_total_num_gcd_cuts","mio_total_num_gomory_cuts","mio_total_num_gub_cover_cuts","mio_total_num_knapsur_cover_cuts","mio_total_num_lattice_cuts","mio_total_num_lift_cuts","mio_total_num_obj_cuts","mio_total_num_plan_loc_cuts","mio_total_num_relax","mio_user_obj_cut","opt_numcon","opt_numvar","optimize_response","rd_numcon","rd_numcone","rd_numintvar","rd_numq","rd_numvar","rd_protype","sim_dual_deg_iter","sim_dual_hotstart","sim_dual_hotstart_lu","sim_dual_inf_iter","sim_dual_iter","sim_network_dual_deg_iter","sim_network_dual_hotstart","sim_network_dual_hotstart_lu","sim_network_dual_inf_iter","sim_network_dual_iter","sim_network_primal_deg_iter","sim_network_primal_hotstart","sim_network_primal_hotstart_lu","sim_network_primal_inf_iter","sim_network_primal_iter","sim_numcon","sim_numvar","sim_primal_deg_iter","sim_primal_dual_deg_iter","sim_primal_dual_hotstart","sim_primal_dual_hotstart_lu","sim_primal_dual_inf_iter","sim_primal_dual_iter","sim_primal_hotstart","sim_primal_hotstart_lu","sim_primal_inf_iter","sim_primal_iter","sim_solve_dual","sol_bas_prosta","sol_bas_solsta","sol_int_prosta","sol_int_solsta","sol_itr_prosta","sol_itr_solsta","sto_num_a_cache_flushes","sto_num_a_realloc","sto_num_a_transposes"], [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97])
xmlwriteroutputtype = Enum("xmlwriteroutputtype", ["col","row"], [1,0])
optimizertype = Enum("optimizertype", ["concurrent","conic","dual_simplex","free","free_simplex","intpnt","mixed_int","nonconvex","primal_dual_simplex","primal_simplex","qcone"], [10,2,5,0,7,1,8,9,6,4,3])
cputype = Enum("cputype", ["amd_athlon","amd_opteron","generic","hp_parisc20","intel_core2","intel_itanium2","intel_p3","intel_p4","intel_pm","powerpc_g5","unknown"], [4,7,1,5,10,6,2,3,9,8,0])
miocontsoltype = Enum("miocontsoltype", ["itg","itg_rel","none","root"], [2,3,0,1])

@accepts()
def getversion():
  """
  Obtains MOSEK version information.

  getversion()
  returns: major,minor,build,revision
    major: int. Major version number.
    minor: int. Minor version number.
    build: int. Build number.
    revision: int. Revision number.
  """
  major_ = ctypes.c_int32()
  major_ = ctypes.c_int32()
  minor_ = ctypes.c_int32()
  minor_ = ctypes.c_int32()
  build_ = ctypes.c_int32()
  build_ = ctypes.c_int32()
  revision_ = ctypes.c_int32()
  revision_ = ctypes.c_int32()
  res = __library__.MSK_XX_getversion(ctypes.byref(major_),ctypes.byref(minor_),ctypes.byref(build_),ctypes.byref(revision_))
  if res != 0:
    raise Error(rescode(res),"")
  _major_return_value = major_.value
  _minor_return_value = minor_.value
  _build_return_value = build_.value
  _revision_return_value = revision_.value
  return (_major_return_value,_minor_return_value,_build_return_value,_revision_return_value)

class Env:
  """
  The MOSEK environment. 
  """
  def __init__(self,licensefile=None,debugfile=None):
      self.__nativep = ctypes.c_void_p()
      self.__library = __library__
      res = self.__library.MSK_XX_makeenv(ctypes.byref(self.__nativep),None,None,None,debugfile)
      if res != 0:
          raise Error(rescode(res),"Error %d" % res)
      try:
          if licensefile is not None:
              res = self.__library.MSK_XX_putlicensedefaults(self.__nativep,licensefile,None,0,0)
              if res != 0:
                  raise Error(rescode(res),"Error %d" % res)
          res = self.__library.MSK_XX_initenv(self.__nativep)
          if res != 0:
              raise Error(rescode(res),"Error %d" % res)        
          
          # user stream functions: 
          self.__stream_func   = 4 * [ None ]
          # strema proxy functions and wrappers:
          self.__stream_cb   = 4 * [ None ]
          for whichstream in range(4): 
              # Note: Apparently closures doesn't work when the function is wrapped in a C function... So we use default parameter value instead.
              def stream_proxy(handle, msg, whichstream=whichstream):
                  func = self.__stream_func[whichstream]
                  try:
                      if func:
                          func(msg)
                  except:
                      pass
              self.__stream_cb[whichstream] = __stream_cb_type__(stream_proxy)
          self.__enablegarcolenv()
      except:
          self.__library.MSK_XX_deleteenv(ctypes.byref(self.__nativep))
          raise
      
  def set_Stream(self,whichstream,func):
      if isinstance(whichstream, streamtype):
          self.__stream_func[whichstream] = func
          if func is None:
              res = self.__library.MSK_XX_linkfunctoenvstream(self.__nativep,whichstream,None,None)
          else:
              res = self.__library.MSK_XX_linkfunctoenvstream(self.__nativep,whichstream,None,self.__stream_cb[whichstream])
      else:
          raise TypeError("Invalid stream %s" % whichstream)
  def __enablegarcolenv(self):
        self.__library.MSK_XX_enablegarcolenv(self.__nativep)

  def _getNativeP(self):
      return self.__nativep
  def __del__(self):
      for f in feature.members():
        self.checkinfeature(f)
      self.__library.MSK_XX_deleteenv(ctypes.byref(self.__nativep))
  def Task(self,maxnumcon=0,maxnumvar=0):
    return Task(self,maxnumcon,maxnumvar)
  @accepts(_accept_any,_accept_anyenum(feature))
  def checkoutlicense(self,feature_):
    """
    Check out a license feature from the license server ahead of time.
  
    checkoutlicense(self,feature_)
      feature: mosek.feature. Feature to check out from the license system.
    """
    res = __library__.MSK_XX_checkoutlicense(self.__nativep,feature_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_accept_anyenum(feature))
  def checkinlicense(self,feature_):
    """
    Check in a license feature from the license server ahead of time.
  
    checkinlicense(self,feature_)
      feature: mosek.feature. Feature to check in to the license system.
    """
    res = __library__.MSK_XX_checkinlicense(self.__nativep,feature_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_make_int)
  def echointro(self,longver_):
    """
    Prints an intro to message stream.
  
    echointro(self,longver_)
      longver: int. If non-zero, then the intro is slightly longer.
    """
    res = __library__.MSK_XX_echointro(self.__nativep,longver_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_accept_anyenum(streamtype),_accept_str,_make_int)
  def linkfiletostream(self,whichstream_,filename_,append_):
    """
    Directs all output from a stream to a file.
  
    linkfiletostream(self,whichstream_,filename_,append_)
      whichstream: mosek.streamtype. Index of the stream.
      filename: str. Name of the file to write stream data to.
      append: int. If this argument is non-zero, the output is appended to the file.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_linkfiletoenvstream(self.__nativep,whichstream_,filename_,append_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any)
  def init(self):
    """
    Initialize a MOSEK environment.
  
    init(self)
    """
    res = __library__.MSK_XX_initenv(self.__nativep)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_accept_str)
  def putdllpath(self,dllpath_):
    """
    Sets the path to the DLL/shared libraries that MOSEK is loading.
  
    putdllpath(self,dllpath_)
      dllpath: str. A path to the dynamic MOSEK libraries.
    """
    dllpath_ = dllpath_.encode("utf-8")
    res = __library__.MSK_XX_putdllpath(self.__nativep,dllpath_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_accept_str,_make_intvector,_make_int,_make_int)
  def putlicensedefaults(self,licensefile_,licensebuf_,licwait_,licdebug_):
    """
    Set defaults used by the license manager.
  
    putlicensedefaults(self,licensefile_,licensebuf_,licwait_,licdebug_)
      licensefile: str. Path to a valid MOSEK license file (optional).
      licensebuf: array of int. A license key string (optional).
      licwait: int. Enable waiting for a license.
      licdebug: int. Enable output of license check-out debug information.
    """
    licensefile_ = licensefile_.encode("utf-8")
    if licensebuf_ is not None and len(licensebuf_) < value.license_buffer_length:
      raise ValueError("Array argument licensebuf is not long enough")
    if isinstance(licensebuf_, numpy.ndarray) and licensebuf_.dtype is numpy.int32 and licensebuf_.flags.contiguous:
      _licensebuf_copyarray = False
      _licensebuf_tmp = ctypes.cast(licensebuf_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(licensebuf_,array.ndarray) and licensebuf_.dtype is array.int32 and  licensebuf_.getsteplength() == 1:
      _licensebuf_copyarray = False
      _licensebuf_tmp = licensebuf_.getdatacptr()
    else:
      _licensebuf_copyarray = True
      _licensebuf_tmp = (ctypes.c_int32 * len(licensebuf_))(*licensebuf_)
    res = __library__.MSK_XX_putlicensedefaults(self.__nativep,licensefile_,_licensebuf_tmp,licwait_,licdebug_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_make_int)
  def putkeepdlls(self,keepdlls_):
    """
    Controls whether explicitly loaded DLLs should be kept.
  
    putkeepdlls(self,keepdlls_)
      keepdlls: int. Controls whether explicitly loaded DLLs should be kept.
    """
    res = __library__.MSK_XX_putkeepdlls(self.__nativep,keepdlls_)
    if res != 0:
      raise Error(rescode(res),"")
  @accepts(_accept_any,_accept_anyenum(cputype),_make_int,_make_int)
  def putcpudefaults(self,cputype_,sizel1_,sizel2_):
    """
    Set defaults default CPU type and cache sizes.
  
    putcpudefaults(self,cputype_,sizel1_,sizel2_)
      cputype: mosek.cputype. The CPU ID.
      sizel1: int. Size of the L1 cache.
      sizel2: int. Size of the L2 cache.
    """
    res = __library__.MSK_XX_putcpudefaults(self.__nativep,cputype_,sizel1_,sizel2_)
    if res != 0:
      raise Error(rescode(res),"")

class Task:
  """
  The MOSEK task class. This object contains information about one optimization problem.
  """
  
  def __init__(self,env=None,maxnumcon=0,maxnumvar=0,nativep=None,other=None):
      """
      Construct a new Task object.
      
      Task(env=None,maxnumcon=0,maxnumvar=0,nativep=None,other=None)
        env: mosek.Env. 
        maxnumcon: int. Reserve space for this number of constraints. Default is 0. 
        maxnumcvar: int. Reserve space for this number of variables. Default is 0. 
        nativep: native pointer. For internal use only.
        other: mosek.Task. Another task.
      
      Valid usage:
        Specifying "env", and optionally "maxnumcon" and "maxnumvar" will create a new Task.
        Specifying "nativep" will create a new Task from the native mosek task defined by the pointer.
        Specifying "other" will create a new Task as a copy of the other task. 
      """
      self.__library = __library__
      self__nativep = None

      if isinstance(env,Task):
          other = env
          env = None
      
      try: 
          if nativep is not None:
              self.__nativep = nativep
              res = 0
          elif other is not None:
              self.__nativep = ctypes.c_void_p()
              res = self.__library.MSK_XX_clonetask(other.__nativep, ctypes.byref(self.__nativep))
          else:
              if not isinstance(env,Env):
                  raise TypeError('Expected an Env for argument')
              self.__nativep = ctypes.c_void_p()
              res = self.__library.MSK_XX_maketask(env._getNativeP(),maxnumcon,maxnumvar,ctypes.byref(self.__nativep))
          if res != 0:
              raise Error(rescode(res),"Error %d" % res)

          # user progress function:
          self.__progress_func = None
          # callback proxy function definition:
          def progress_proxy(nativep, handle, caller):
              r = 0
              try:
                  if self.__progress_func:
                      caller = callbackcode(caller)
                      r = self.__progress_func(caller)
                      if not isinstance(r,int):
                          r = 0
              except:
                  import traceback
                  traceback.print_exc()
                  return -1
              return r
          # callback proxy C wrapper:
          self.__progress_cb = __progress_cb_type__(progress_proxy)
        
          # user stream functions: 
          self.__stream_func   = 4 * [ None ]
          # strema proxy functions and wrappers:
          self.__stream_cb   = 4 * [ None ]
          for whichstream in range(4): 
              # Note: Apparently closures doesn't work when the function is wrapped in a C function... So we use default parameter value instead.
              def stream_proxy(handle, msg, whichstream=whichstream):
                  func = self.__stream_func[whichstream]
                  try:
                      if func:
                          func(msg)
                  except:
                      pass
              self.__stream_cb[whichstream] = __stream_cb_type__(stream_proxy)
          assert self.__nativep
          self.__schandle = None
      except:
          #import traceback
          #traceback.print_exc()
          if hasattr(self,'_Task__nativep') and self.__nativep is not None:
              #print "DELETE TASK 2",id(self)
              self.__library.MSK_XX_deletetask(ctypes.byref(self.__nativep))
              self.__nativep = None
          raise
      
  def __del__(self):
      #print "DELETE TASK 1",id(self)
      self.removeSCeval()
      self.__library.MSK_XX_deletetask(ctypes.byref(self.__nativep))
      self.__nativep = None

  def __getlasterror(self,res):
      msglen = ctypes.c_int64(1024)
      lasterr = ctypes.c_int()
      r = self.__library.MSK_XX_getlasterror64(self.__nativep, ctypes.byref(lasterr), 0, ctypes.byref(msglen),None)
      if r == 0:
          #msg = (ctypes.c_char * (msglen.value+1))()
          len = (msglen.value+1)
          msg = ctypes.create_string_buffer(len)
          r = self.__library.MSK_XX_getlasterror64(self.__nativep, ctypes.byref(lasterr), len, None,msg)
          if r == 0:
              result,msg = lasterr.value,msg.value.decode('utf-8')
          else:
              result,msg = lasterr.value,''
      else:
          result,msg = res,''
      return result,msg


  def set_Progress(self,func):
      """
      Set the progress callback function. If func is None, progress callbacks are detached and disabled.
      """
      self.__progress_func = func
      if func is None:
          res = self.__library.MSK_XX_putcallbackfunc(self.__nativep,None,None)
      else:
          res = self.__library.MSK_XX_putcallbackfunc(self.__nativep,self.__progress_cb,None)

  def set_Stream(self,whichstream,func):
      if isinstance(whichstream, streamtype):
          self.__stream_func[whichstream] = func
          if func is None:
              res = self.__library.MSK_XX_linkfunctotaskstream(self.__nativep,whichstream,None,None)
          else:
              res = self.__library.MSK_XX_linkfunctotaskstream(self.__nativep,whichstream,None,self.__stream_cb[whichstream])
      else:
          raise TypeError("Invalid stream %s" % whichstream)  

  def removeSCeval(self):
    if self.__schandle is not None:
        __load_scopt__()
        __scopt__.MSK_scend(self.__nativep, self.__schandle)
        self.__schandle = None
    
  def putSCeval(self,
                opro  = None, 
                oprjo = None,
                oprfo = None,
                oprgo = None,
                oprho = None,
                oprc  = None,
                opric = None,
                oprjc = None,
                oprfc = None,
                oprgc = None,
                oprhc = None):
    """
    Input data for SCopt. If other SCopt data was inputted before, the new data replaces the old.
    
    Defining a non-liner objective requires that all of the arguments opro,
    oprjo, oprfo, oprgo and oprho are defined. If present, all these arrays
    must have the same length.
    Defining non-linear constraints requires that all of the arguments oprc,
    opric, oprjc, oprfc, oprgc and oprhc are defined. If present, all these
    arrays must have the same length.

    Parameters:
      [opro]  Array of mosek.scopr values. Defines the functions used for the objective.
      [oprjo] Array of indexes. Defines the variable indexes used in non-linear objective function.
      [oprfo] Array of coefficients. Defines constants used in the objective.
      [oprgo] Array of coefficients. Defines constants used in the objective.
      [oprho] Array of coefficients. Defines constants used in the objective.
      [oprc]  Array of mosek.scopr values. Defines the functions used for the constraints.
      [opric] Array of indexes. Defines the variable indexes used in the non-linear constraint functions.
      [oprjc] Array of indexes. Defines the constraint indexes where non-linear functions appear.
      [oprfc] Array of coefficients. Defines constants used in the non-linear constraints.
      [oprgc] Array of coefficients. Defines constants used in the non-linear constraints.
      [oprhc] Array of coefficients. Defines constants used in the non-linear constraints.
    """
    
    __load_scopt__()
    if self.__schandle is not None:
        __scopt__.MSK_scend(self.__nativep, self.__schandle)
        self.__schandle = None

    if (    opro  is not None 
        and oprjo is not None 
        and oprfo is not None 
        and oprgo is not None
        and oprho is not None):
        # we have objective.
        try:
            numnlov = len(opro)
            if (   numnlov != len(oprjo)
                or numnlov != len(oprfo)
                or numnlov != len(oprgo)
                or numnlov != len(oprho)):
                raise ValueError("Arguments opro, oprjo, oprfo, oprgo and oprho have different lengths") 
            for i in opro:
                if not isinstance(i,scopr):
                    raise ValieError("Argument opro must be an array of mosek.scopr")
            _opro  = array.array(opro, array.int32)
            _oprjo = array.array(oprjo,array.int32)
            _oprfo = array.array(oprfo,float)
            _oprgo = array.array(oprgo,float)
            _oprho = array.array(oprho,float)
        except TypeError:
            # not 'len' operation
            raise ValueError("Arguments opro, oprjo, oprfo, oprgo and oprho must be arrays") 
    else:
        numnlov = 0

    if (    oprc  is not None 
        and opric is not None 
        and oprjc is not None 
        and oprfc is not None 
        and oprgc is not None
        and oprhc is not None):
        # we have objective.
        try:
            numnlcv = len(oprc)
            if (   numnlcv != len(opric)
                or numnlcv != len(oprjc)
                or numnlcv != len(oprfc)
                or numnlcv != len(oprgc)
                or numnlcv != len(oprhc)):
                raise ValueError("Arguments oprc, opric, oprjc, oprfc, oprgc and oprhc have different lengths") 
            for i in oprc:
                if not isinstance(i,scopr):
                    raise ValieError("Argument oprc must be an array of mosek.scopr")
            _oprc  = array.array(oprc, array.int32)
            _opric = array.array(opric,array.int32)
            _oprjc = array.array(oprjc,array.int32)
            _oprfc = array.array(oprfc,float)
            _oprgc = array.array(oprgc,float)
            _oprhc = array.array(oprhc,float)
        except TypeError:
            # not 'len' operation
            raise ValueError("Arguments oprc, opric, oprjc, oprfc, oprgc and oprhc must be arrays") 
    else:
        numnlcv = 0
    
    def _convint32arr(arg):
        if isinstance(arg,numpy.ndarray) and arg.dtype is numpy.int32 and arg.flags.contiguous:
            res = ctypes.cast(arg.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
        elif isinstance(arg,array.ndarray) and arg.dtype == array.int32 and arg.getsteplength() == 1:
            res = arg.getdatacptr()
        else:
            res = (ctypes.c_int32 * len(arg))(*arg)
        return res
    def _convdoublearr(arg):
        if isinstance(arg,numpy.ndarray) and arg.dtype is numpy.float64 and arg.flags.contiguous:
            res = ctypes.cast(arg.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
        elif isinstance(arg,array.ndarray) and arg.dtype == array.float64 and arg.getsteplength() == 1:
            res = arg.getdatacptr()
        else:
            res = (ctypes.c_float64 * len(arg))(*arg)
        return res
    
    if numnlov > 0 or numlncv > 0:
        args = [ self.__nativep ] 
        args.append(numnlov)
        if numnlov > 0:
            args.append(_convint32arr(_opro))
            args.append(_convint32arr(_oprjo))
            args.append(_convdoublearr(_oprfo))
            args.append(_convdoublearr(_oprgo))
            args.append(_convdoublearr(_oprho))
        else:
            args.extend([ None, None, None, None, None ])
            
        args.append(numnlcv)
        if numnlov > 0:
            args.append(_convint32arr(_oprc))
            args.append(_convint32arr(_opric))
            args.append(_convint32arr(_oprjc))
            args.append(_convdoublearr(_oprfc))
            args.append(_convdoublearr(_oprgc))
            args.append(_convdoublearr(_oprhc))
        else:
            args.extend([ None, None, None, None, None ])

        self.__schandle = ctypes.c_void_p()
        args.append(ctypes.byref(self.__schandle))
        
        res = __scopt__.MSK_scbegin(*args)
        if res != 0:
            result,msg = self.__getlasterror(res)
            raise Error(rescode(result),msg)


  @accepts(_accept_any,_accept_anyenum(streamtype))
  def analyzeproblem(self,whichstream_):
    """
    Analyze the data of a task.
  
    analyzeproblem(self,whichstream_)
      whichstream: mosek.streamtype. Index of the stream.
    """
    res = __library__.MSK_XX_analyzeproblem(self.__nativep,whichstream_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(streamtype),_accept_anyenum(soltype))
  def analyzesolution(self,whichstream_,whichsol_):
    """
    Print information related to the quality of the solution.
  
    analyzesolution(self,whichstream_,whichsol_)
      whichstream: mosek.streamtype. Index of the stream.
      whichsol: mosek.soltype. Selects a solution.
    """
    res = __library__.MSK_XX_analyzesolution(self.__nativep,whichstream_,whichsol_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_intvector)
  def initbasissolve(self,basis_):
    """
    Prepare a task for basis solver.
  
    initbasissolve(self,basis_)
      basis: array of int. The array of basis indexes to use.
    """
    if basis_ is not None and len(basis_) < self.getnumcon():
      raise ValueError("Array argument basis is not long enough")
    if isinstance(basis_,numpy.ndarray) and not basis_.flags.writeable:
      raise ValueError("Argument basis must be writable")
    if isinstance(basis_, numpy.ndarray) and basis_.dtype is numpy.int32 and basis_.flags.contiguous:
      _basis_copyarray = False
      _basis_tmp = ctypes.cast(basis_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(basis_,array.ndarray) and basis_.dtype is array.int32 and  basis_.getsteplength() == 1:
      _basis_copyarray = False
      _basis_tmp = basis_.getdatacptr()
    else:
      _basis_copyarray = True
      _basis_tmp = (ctypes.c_int32 * len(basis_))(*basis_)
    res = __library__.MSK_XX_initbasissolve(self.__nativep,_basis_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _basis_copyarray:
      basis_[:] = _basis_tmp
  @accepts(_accept_any,_make_int,_make_int,_accept_intvector,_accept_doublevector)
  def solvewithbasis(self,transp_,numnz_,sub_,val_):
    """
    Solve a linear equation system involving a basis matrix.
  
    solvewithbasis(self,transp_,numnz_,sub_,val_)
      transp: int. Controls which problem formulation is solved.
      numnz: int. Input (number of non-zeros in right-hand side) and output (number of non-zeros in solution vector).
      sub: array of int. Input (indexes of non-zeros in right-hand side) and output (indexes of non-zeros in solution vector).
      val: array of double. Input (right-hand side values) and output (solution vector values).
    returns: numnz
      numnz: int. Input (number of non-zeros in right-hand side) and output (number of non-zeros in solution vector).
    """
    _numnz_tmp = ctypes.c_int32(numnz_)
    if sub_ is not None and len(sub_) < self.getnumcon():
      raise ValueError("Array argument sub is not long enough")
    if isinstance(sub_,numpy.ndarray) and not sub_.flags.writeable:
      raise ValueError("Argument sub must be writable")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    if val_ is not None and len(val_) < self.getnumcon():
      raise ValueError("Array argument val is not long enough")
    if isinstance(val_,numpy.ndarray) and not val_.flags.writeable:
      raise ValueError("Argument val must be writable")
    if isinstance(val_, numpy.ndarray) and val_.dtype is numpy.float64 and val_.flags.contiguous:
      _val_copyarray = False
      _val_tmp = ctypes.cast(val_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(val_,array.ndarray) and val_.dtype is array.float64 and  val_.getsteplength() == 1:
      _val_copyarray = False
      _val_tmp = val_.getdatacptr()
    else:
      _val_copyarray = True
      _val_tmp = (ctypes.c_double * len(val_))(*val_)
    res = __library__.MSK_XX_solvewithbasis(self.__nativep,transp_,ctypes.byref(_numnz_tmp),_sub_tmp,_val_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numnz_return_value = numnz.value
    if _sub_copyarray:
      sub_[:] = _sub_tmp
    if _val_copyarray:
      val_[:] = _val_tmp
    return (_numnz_return_value)
  @accepts(_accept_any)
  def basiscond(self):
    """
    Computes conditioning information for the basis matrix.
  
    basiscond(self)
    returns: nrmbasis,nrminvbasis
      nrmbasis: double. An estimate for the 1 norm of the basis.
      nrminvbasis: double. An estimate for the 1 norm of the inverse of the basis.
    """
    nrmbasis_ = ctypes.c_double()
    nrmbasis_ = ctypes.c_double()
    nrminvbasis_ = ctypes.c_double()
    nrminvbasis_ = ctypes.c_double()
    res = __library__.MSK_XX_basiscond(self.__nativep,ctypes.byref(nrmbasis_),ctypes.byref(nrminvbasis_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _nrmbasis_return_value = nrmbasis_.value
    _nrminvbasis_return_value = nrminvbasis_.value
    return (_nrmbasis_return_value,_nrminvbasis_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int)
  def append(self,accmode_,num_):
    """
    Appends a number of variables or constraints to the optimization task.
  
    append(self,accmode_,num_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      num: int. Number of constraints or variables which should be appended.
    """
    res = __library__.MSK_XX_append(self.__nativep,accmode_,num_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_intvector)
  def remove(self,accmode_,sub_):
    """
    The function removes a number of constraints or variables.
  
    remove(self,accmode_,sub_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      sub: array of int. Indexes of constraints or variables which should be removed.
    """
    num_ = None
    if num_ is None:
      num_ = len(sub_)
    else:
      num_ = min(num_,len(sub_))
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    res = __library__.MSK_XX_remove(self.__nativep,accmode_,num_,_sub_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(conetype),_make_double,_make_intvector)
  def appendcone(self,conetype_,conepar_,submem_):
    """
    Appends a new cone constraint to the problem.
  
    appendcone(self,conetype_,conepar_,submem_)
      conetype: mosek.conetype. Specifies the type of the cone.
      conepar: double. This argument is currently not used. Can be set to 0.0.
      submem: array of int. Variable subscripts of the members in the cone.
    """
    nummem_ = None
    if nummem_ is None:
      nummem_ = len(submem_)
    else:
      nummem_ = min(nummem_,len(submem_))
    if submem_ is None:
      raise ValueError("Argument submem cannot be None")
    if submem_ is None:
      raise ValueError("Argument submem may not be None")
    if isinstance(submem_, numpy.ndarray) and submem_.dtype is numpy.int32 and submem_.flags.contiguous:
      _submem_copyarray = False
      _submem_tmp = ctypes.cast(submem_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(submem_,array.ndarray) and submem_.dtype is array.int32 and  submem_.getsteplength() == 1:
      _submem_copyarray = False
      _submem_tmp = submem_.getdatacptr()
    else:
      _submem_copyarray = True
      _submem_tmp = (ctypes.c_int32 * len(submem_))(*submem_)
    res = __library__.MSK_XX_appendcone(self.__nativep,conetype_,conepar_,nummem_,_submem_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int)
  def removecone(self,k_):
    """
    Removes a conic constraint from the problem.
  
    removecone(self,k_)
      k: int. Index of the conic constraint that should be removed.
    """
    res = __library__.MSK_XX_removecone(self.__nativep,k_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int,_make_int,_make_double)
  def chgbound(self,accmode_,i_,lower_,finite_,value_):
    """
    Changes the bounds for one constraint or variable.
  
    chgbound(self,accmode_,i_,lower_,finite_,value_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      i: int. Index of the constraint or variable for which the bounds should be changed.
      lower: int. If non-zero, then the lower bound is changed, otherwise                             the upper bound is changed.
      finite: int. If non-zero, then the given value is assumed to be finite.
      value: double. New value for the bound.
    """
    res = __library__.MSK_XX_chgbound(self.__nativep,accmode_,i_,lower_,finite_,value_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_int)
  def getaij(self,i_,j_):
    """
    Obtains a single coefficient in linear constraint matrix.
  
    getaij(self,i_,j_)
      i: int. Row index of the coefficient to be returned.
      j: int. Column index of the coefficient to be returned.
    returns: aij
      aij: double. Returns the requested coefficient.
    """
    aij_ = ctypes.c_double()
    aij_ = ctypes.c_double()
    res = __library__.MSK_XX_getaij(self.__nativep,i_,j_,ctypes.byref(aij_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _aij_return_value = aij_.value
    return (_aij_return_value)
  @accepts(_accept_any,_make_int,_make_int,_make_int,_make_int)
  def getapiecenumnz(self,firsti_,lasti_,firstj_,lastj_):
    """
    Obtains the number non-zeros in a rectangular piece of the linear constraint matrix.
  
    getapiecenumnz(self,firsti_,lasti_,firstj_,lastj_)
      firsti: int. Index of the first row in the rectangular piece.
      lasti: int. Index of the last row plus one in the rectangular piece.
      firstj: int. Index of the first column in the rectangular piece.
      lastj: int. Index of the last column plus one in the rectangular piece.
    returns: numnz
      numnz: int. Number of non-zero elements in the rectangular piece of the linear constraint matrix.
    """
    numnz_ = ctypes.c_int32()
    numnz_ = ctypes.c_int32()
    res = __library__.MSK_XX_getapiecenumnz(self.__nativep,firsti_,lasti_,firstj_,lastj_,ctypes.byref(numnz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numnz_return_value = numnz_.value
    return (_numnz_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int)
  def getavecnumnz(self,accmode_,i_):
    """
    Obtains the number of non-zero elements in one row or column of the linear constraint matrix
  
    getavecnumnz(self,accmode_,i_)
      accmode: mosek.accmode. Defines whether non-zeros are counted by columns or by rows.
      i: int. Index of the row or column.
    returns: nzj
      nzj: int. Number of non-zeros in the i'th row or column of (A).
    """
    nzj_ = ctypes.c_int32()
    nzj_ = ctypes.c_int32()
    res = __library__.MSK_XX_getavecnumnz(self.__nativep,accmode_,i_,ctypes.byref(nzj_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _nzj_return_value = nzj_.value
    return (_nzj_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_accept_intvector,_accept_doublevector)
  def getavec(self,accmode_,i_,subi_,vali_):
    """
    Obtains one row or column of the linear constraint matrix.
  
    getavec(self,accmode_,i_,subi_,vali_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      i: int. Index of the row or column.
      subi: array of int. Index of the non-zeros in the vector obtained.
      vali: array of double. Numerical values of the vector to be obtained.
    returns: nzi
      nzi: int. Number of non-zeros in the vector obtained.
    """
    nzi_ = ctypes.c_int32()
    nzi_ = ctypes.c_int32()
    if subi_ is not None and len(subi_) < self.getavecnumnz(accmode_,i_):
      raise ValueError("Array argument subi is not long enough")
    if isinstance(subi_,numpy.ndarray) and not subi_.flags.writeable:
      raise ValueError("Argument subi must be writable")
    if subi_ is None:
      raise ValueError("Argument subi may not be None")
    if isinstance(subi_, numpy.ndarray) and subi_.dtype is numpy.int32 and subi_.flags.contiguous:
      _subi_copyarray = False
      _subi_tmp = ctypes.cast(subi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subi_,array.ndarray) and subi_.dtype is array.int32 and  subi_.getsteplength() == 1:
      _subi_copyarray = False
      _subi_tmp = subi_.getdatacptr()
    else:
      _subi_copyarray = True
      _subi_tmp = (ctypes.c_int32 * len(subi_))(*subi_)
    if vali_ is not None and len(vali_) < self.getavecnumnz(accmode_,i_):
      raise ValueError("Array argument vali is not long enough")
    if isinstance(vali_,numpy.ndarray) and not vali_.flags.writeable:
      raise ValueError("Argument vali must be writable")
    if vali_ is None:
      raise ValueError("Argument vali may not be None")
    if isinstance(vali_, numpy.ndarray) and vali_.dtype is numpy.float64 and vali_.flags.contiguous:
      _vali_copyarray = False
      _vali_tmp = ctypes.cast(vali_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(vali_,array.ndarray) and vali_.dtype is array.float64 and  vali_.getsteplength() == 1:
      _vali_copyarray = False
      _vali_tmp = vali_.getdatacptr()
    else:
      _vali_copyarray = True
      _vali_tmp = (ctypes.c_double * len(vali_))(*vali_)
    res = __library__.MSK_XX_getavec(self.__nativep,accmode_,i_,ctypes.byref(nzi_),_subi_tmp,_vali_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _nzi_return_value = nzi_.value
    if _subi_copyarray:
      subi_[:] = _subi_tmp
    if _vali_copyarray:
      vali_[:] = _vali_tmp
    return (_nzi_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int)
  def getaslicenumnz(self,accmode_,first_,last_):
    """
    Obtains the number of non-zeros in a slice of rows or columns of the coefficient matrix.
  
    getaslicenumnz(self,accmode_,first_,last_)
      accmode: mosek.accmode. Defines whether non-zeros are counted in a column slice or a row slice.
      first: int. Index of the first row or column in the sequence.
      last: int. Index of the last row or column plus one in the sequence.
    returns: numnz
      numnz: long. Number of non-zeros in the slice.
    """
    numnz_ = ctypes.c_int64()
    numnz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getaslicenumnz64(self.__nativep,accmode_,first_,last_,ctypes.byref(numnz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numnz_return_value = numnz_.value
    return (_numnz_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int,_accept_longvector,_accept_longvector,_accept_intvector,_accept_doublevector)
  def getaslice(self,accmode_,first_,last_,ptrb_,ptre_,sub_,val_):
    """
    Obtains a sequence of rows or columns from the coefficient matrix.
  
    getaslice(self,accmode_,first_,last_,ptrb_,ptre_,sub_,val_)
      accmode: mosek.accmode. Defines whether a column slice or a row slice is requested.
      first: int. Index of the first row or column in the sequence.
      last: int. Index of the last row or column in the sequence plus one.
      ptrb: array of long. Row or column start pointers.
      ptre: array of long. Row or column end pointers.
      sub: array of int. Contains the row or column subscripts.
      val: array of double. Contains the coefficient values.
    """
    maxnumnz_ = None
    if maxnumnz_ is None:
      maxnumnz_ = len(sub_)
    else:
      maxnumnz_ = min(maxnumnz_,len(sub_))
    if maxnumnz_ is None:
      maxnumnz_ = len(val_)
    else:
      maxnumnz_ = min(maxnumnz_,len(val_))
    surp_ = ctypes.c_int64(len(sub_))
    if ptrb_ is not None and len(ptrb_) < (last_ - first_):
      raise ValueError("Array argument ptrb is not long enough")
    if isinstance(ptrb_,numpy.ndarray) and not ptrb_.flags.writeable:
      raise ValueError("Argument ptrb must be writable")
    if isinstance(ptrb_, numpy.ndarray) and ptrb_.dtype is numpy.int64 and ptrb_.flags.contiguous:
      _ptrb_copyarray = False
      _ptrb_tmp = ctypes.cast(ptrb_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(ptrb_,array.ndarray) and ptrb_.dtype is array.int64 and  ptrb_.getsteplength() == 1:
      _ptrb_copyarray = False
      _ptrb_tmp = ptrb_.getdatacptr()
    else:
      _ptrb_copyarray = True
      _ptrb_tmp = (ctypes.c_int64 * len(ptrb_))(*ptrb_)
    if ptre_ is not None and len(ptre_) < (last_ - first_):
      raise ValueError("Array argument ptre is not long enough")
    if isinstance(ptre_,numpy.ndarray) and not ptre_.flags.writeable:
      raise ValueError("Argument ptre must be writable")
    if isinstance(ptre_, numpy.ndarray) and ptre_.dtype is numpy.int64 and ptre_.flags.contiguous:
      _ptre_copyarray = False
      _ptre_tmp = ctypes.cast(ptre_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(ptre_,array.ndarray) and ptre_.dtype is array.int64 and  ptre_.getsteplength() == 1:
      _ptre_copyarray = False
      _ptre_tmp = ptre_.getdatacptr()
    else:
      _ptre_copyarray = True
      _ptre_tmp = (ctypes.c_int64 * len(ptre_))(*ptre_)
    if sub_ is not None and len(sub_) < maxnumnz_:
      raise ValueError("Array argument sub is not long enough")
    if isinstance(sub_,numpy.ndarray) and not sub_.flags.writeable:
      raise ValueError("Argument sub must be writable")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    if val_ is not None and len(val_) < maxnumnz_:
      raise ValueError("Array argument val is not long enough")
    if isinstance(val_,numpy.ndarray) and not val_.flags.writeable:
      raise ValueError("Argument val must be writable")
    if isinstance(val_, numpy.ndarray) and val_.dtype is numpy.float64 and val_.flags.contiguous:
      _val_copyarray = False
      _val_tmp = ctypes.cast(val_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(val_,array.ndarray) and val_.dtype is array.float64 and  val_.getsteplength() == 1:
      _val_copyarray = False
      _val_tmp = val_.getdatacptr()
    else:
      _val_copyarray = True
      _val_tmp = (ctypes.c_double * len(val_))(*val_)
    res = __library__.MSK_XX_getaslice64(self.__nativep,accmode_,first_,last_,maxnumnz_,ctypes.byref(surp_),_ptrb_tmp,_ptre_tmp,_sub_tmp,_val_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _ptrb_copyarray:
      ptrb_[:] = _ptrb_tmp
    if _ptre_copyarray:
      ptre_[:] = _ptre_tmp
    if _sub_copyarray:
      sub_[:] = _sub_tmp
    if _val_copyarray:
      val_[:] = _val_tmp
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int,_accept_intvector,_accept_intvector,_accept_doublevector)
  def getaslicetrip(self,accmode_,first_,last_,subi_,subj_,val_):
    """
    Obtains a sequence of rows or columns from the coefficient matrix in triplet format.
  
    getaslicetrip(self,accmode_,first_,last_,subi_,subj_,val_)
      accmode: mosek.accmode. Defines whether a column-slice or a row-slice is requested.
      first: int. Index of the first row or column in the sequence.
      last: int. Index of the last row or column in the sequence plus one.
      subi: array of int. Constraint subscripts.
      subj: array of int. Variable subscripts.
      val: array of double. Values.
    """
    maxnumnz_ = None
    if maxnumnz_ is None:
      maxnumnz_ = len(subi_)
    else:
      maxnumnz_ = min(maxnumnz_,len(subi_))
    if maxnumnz_ is None:
      maxnumnz_ = len(subj_)
    else:
      maxnumnz_ = min(maxnumnz_,len(subj_))
    if maxnumnz_ is None:
      maxnumnz_ = len(val_)
    else:
      maxnumnz_ = min(maxnumnz_,len(val_))
    surp_ = ctypes.c_int32(len(subi_))
    if subi_ is not None and len(subi_) < maxnumanz_:
      raise ValueError("Array argument subi is not long enough")
    if isinstance(subi_,numpy.ndarray) and not subi_.flags.writeable:
      raise ValueError("Argument subi must be writable")
    if isinstance(subi_, numpy.ndarray) and subi_.dtype is numpy.int32 and subi_.flags.contiguous:
      _subi_copyarray = False
      _subi_tmp = ctypes.cast(subi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subi_,array.ndarray) and subi_.dtype is array.int32 and  subi_.getsteplength() == 1:
      _subi_copyarray = False
      _subi_tmp = subi_.getdatacptr()
    else:
      _subi_copyarray = True
      _subi_tmp = (ctypes.c_int32 * len(subi_))(*subi_)
    if subj_ is not None and len(subj_) < maxnumanz_:
      raise ValueError("Array argument subj is not long enough")
    if isinstance(subj_,numpy.ndarray) and not subj_.flags.writeable:
      raise ValueError("Argument subj must be writable")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if val_ is not None and len(val_) < maxnumanz_:
      raise ValueError("Array argument val is not long enough")
    if isinstance(val_,numpy.ndarray) and not val_.flags.writeable:
      raise ValueError("Argument val must be writable")
    if isinstance(val_, numpy.ndarray) and val_.dtype is numpy.float64 and val_.flags.contiguous:
      _val_copyarray = False
      _val_tmp = ctypes.cast(val_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(val_,array.ndarray) and val_.dtype is array.float64 and  val_.getsteplength() == 1:
      _val_copyarray = False
      _val_tmp = val_.getdatacptr()
    else:
      _val_copyarray = True
      _val_tmp = (ctypes.c_double * len(val_))(*val_)
    res = __library__.MSK_XX_getaslicetrip(self.__nativep,accmode_,first_,last_,maxnumnz_,ctypes.byref(surp_),_subi_tmp,_subj_tmp,_val_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _subi_copyarray:
      subi_[:] = _subi_tmp
    if _subj_copyarray:
      subj_[:] = _subj_tmp
    if _val_copyarray:
      val_[:] = _val_tmp
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int)
  def getbound(self,accmode_,i_):
    """
    Obtains bound information for one constraint or variable.
  
    getbound(self,accmode_,i_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      i: int. Index of the constraint or variable for which the bound information should be obtained.
    returns: bk,bl,bu
      bk: mosek.boundkey. Bound keys.
      bl: double. Values for lower bounds.
      bu: double. Values for upper bounds.
    """
    bk_ = ctypes.c_int32()
    bl_ = ctypes.c_double()
    bl_ = ctypes.c_double()
    bu_ = ctypes.c_double()
    bu_ = ctypes.c_double()
    res = __library__.MSK_XX_getbound(self.__nativep,accmode_,i_,ctypes.byref(bk_),ctypes.byref(bl_),ctypes.byref(bu_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _bk_return_value = boundkey(bk_.value)
    _bl_return_value = bl_.value
    _bu_return_value = bu_.value
    return (_bk_return_value,_bl_return_value,_bu_return_value)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int,_accept_any,_accept_doublevector,_accept_doublevector)
  def getboundslice(self,accmode_,first_,last_,bk_,bl_,bu_):
    """
    Obtains bounds information for a sequence of variables or constraints.
  
    getboundslice(self,accmode_,first_,last_,bk_,bl_,bu_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      first: int. First index in the sequence.
      last: int. Last index plus 1 in the sequence.
      bk: array of mosek.boundkey. Bound keys.
      bl: array of double. Values for lower bounds.
      bu: array of double. Values for upper bounds.
    """
    if bk_ is not None and len(bk_) < (last_ - first_):
      raise ValueError("Array argument bk is not long enough")
    if isinstance(bk_,numpy.ndarray) and not bk_.flags.writeable:
      raise ValueError("Argument bk must be writable")
    if bk_ is not None:
        _bk_tmp_arr = array.zeros(len(bk_),array.int32)
        _bk_tmp = _bk_tmp_arr.getdatacptr()
    else:
        _bk_tmp_arr = None
        _bk_tmp = None
    if bl_ is not None and len(bl_) < (last_ - first_):
      raise ValueError("Array argument bl is not long enough")
    if isinstance(bl_,numpy.ndarray) and not bl_.flags.writeable:
      raise ValueError("Argument bl must be writable")
    if isinstance(bl_, numpy.ndarray) and bl_.dtype is numpy.float64 and bl_.flags.contiguous:
      _bl_copyarray = False
      _bl_tmp = ctypes.cast(bl_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bl_,array.ndarray) and bl_.dtype is array.float64 and  bl_.getsteplength() == 1:
      _bl_copyarray = False
      _bl_tmp = bl_.getdatacptr()
    else:
      _bl_copyarray = True
      _bl_tmp = (ctypes.c_double * len(bl_))(*bl_)
    if bu_ is not None and len(bu_) < (last_ - first_):
      raise ValueError("Array argument bu is not long enough")
    if isinstance(bu_,numpy.ndarray) and not bu_.flags.writeable:
      raise ValueError("Argument bu must be writable")
    if isinstance(bu_, numpy.ndarray) and bu_.dtype is numpy.float64 and bu_.flags.contiguous:
      _bu_copyarray = False
      _bu_tmp = ctypes.cast(bu_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bu_,array.ndarray) and bu_.dtype is array.float64 and  bu_.getsteplength() == 1:
      _bu_copyarray = False
      _bu_tmp = bu_.getdatacptr()
    else:
      _bu_copyarray = True
      _bu_tmp = (ctypes.c_double * len(bu_))(*bu_)
    res = __library__.MSK_XX_getboundslice(self.__nativep,accmode_,first_,last_,_bk_tmp,_bl_tmp,_bu_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if bk_ is not None: bk_[:] = [ boundkey(v) for v in _bk_tmp[0:len(bk_)] ]
    if _bl_copyarray:
      bl_[:] = _bl_tmp
    if _bu_copyarray:
      bu_[:] = _bu_tmp
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_int,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector)
  def putboundslice(self,con_,first_,last_,bk_,bl_,bu_):
    """
    Modifies bounds.
  
    putboundslice(self,con_,first_,last_,bk_,bl_,bu_)
      con: mosek.accmode. Determines whether variables or constraints are modified.
      first: int. First index in the sequence.
      last: int. Last index plus 1 in the sequence.
      bk: array of mosek.boundkey. Bound keys.
      bl: array of double. Values for lower bounds.
      bu: array of double. Values for upper bounds.
    """
    if bk_ is not None and len(bk_) < (last_ - first_):
      raise ValueError("Array argument bk is not long enough")
    if bk_ is None:
      raise ValueError("Argument bk cannot be None")
    if bk_ is None:
      raise ValueError("Argument bk may not be None")
    _bk_tmp_arr = array.array(bk_,array.int32)
    _bk_tmp = _bk_tmp_arr.getdatacptr()
    if bl_ is not None and len(bl_) < (last_ - first_):
      raise ValueError("Array argument bl is not long enough")
    if bl_ is None:
      raise ValueError("Argument bl cannot be None")
    if bl_ is None:
      raise ValueError("Argument bl may not be None")
    if isinstance(bl_, numpy.ndarray) and bl_.dtype is numpy.float64 and bl_.flags.contiguous:
      _bl_copyarray = False
      _bl_tmp = ctypes.cast(bl_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bl_,array.ndarray) and bl_.dtype is array.float64 and  bl_.getsteplength() == 1:
      _bl_copyarray = False
      _bl_tmp = bl_.getdatacptr()
    else:
      _bl_copyarray = True
      _bl_tmp = (ctypes.c_double * len(bl_))(*bl_)
    if bu_ is not None and len(bu_) < (last_ - first_):
      raise ValueError("Array argument bu is not long enough")
    if bu_ is None:
      raise ValueError("Argument bu cannot be None")
    if bu_ is None:
      raise ValueError("Argument bu may not be None")
    if isinstance(bu_, numpy.ndarray) and bu_.dtype is numpy.float64 and bu_.flags.contiguous:
      _bu_copyarray = False
      _bu_tmp = ctypes.cast(bu_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bu_,array.ndarray) and bu_.dtype is array.float64 and  bu_.getsteplength() == 1:
      _bu_copyarray = False
      _bu_tmp = bu_.getdatacptr()
    else:
      _bu_copyarray = True
      _bu_tmp = (ctypes.c_double * len(bu_))(*bu_)
    res = __library__.MSK_XX_putboundslice(self.__nativep,con_,first_,last_,_bk_tmp,_bl_tmp,_bu_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_doublevector)
  def getc(self,c_):
    """
    Obtains all objective coefficients.
  
    getc(self,c_)
      c: array of double. Linear terms of the objective as a dense vector. The lengths is the number of variables.
    """
    if c_ is not None and len(c_) < self.getnumvar():
      raise ValueError("Array argument c is not long enough")
    if isinstance(c_,numpy.ndarray) and not c_.flags.writeable:
      raise ValueError("Argument c must be writable")
    if isinstance(c_, numpy.ndarray) and c_.dtype is numpy.float64 and c_.flags.contiguous:
      _c_copyarray = False
      _c_tmp = ctypes.cast(c_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(c_,array.ndarray) and c_.dtype is array.float64 and  c_.getsteplength() == 1:
      _c_copyarray = False
      _c_tmp = c_.getdatacptr()
    else:
      _c_copyarray = True
      _c_tmp = (ctypes.c_double * len(c_))(*c_)
    res = __library__.MSK_XX_getc(self.__nativep,_c_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _c_copyarray:
      c_[:] = _c_tmp
  @accepts(_accept_any)
  def getcfix(self):
    """
    Obtains the fixed term in the objective.
  
    getcfix(self)
    returns: cfix
      cfix: double. Fixed term in the objective.
    """
    cfix_ = ctypes.c_double()
    cfix_ = ctypes.c_double()
    res = __library__.MSK_XX_getcfix(self.__nativep,ctypes.byref(cfix_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _cfix_return_value = cfix_.value
    return (_cfix_return_value)
  @accepts(_accept_any,_make_int,_accept_intvector)
  def getcone(self,k_,submem_):
    """
    Obtains a conic constraint.
  
    getcone(self,k_,submem_)
      k: int. Index of the cone constraint.
      submem: array of int. Variable subscripts of the members in the cone.
    returns: conetype,conepar,nummem
      conetype: mosek.conetype. Specifies the type of the cone.
      conepar: double. This argument is currently not used. Can be set to 0.0.
      nummem: int. Number of member variables in the cone.
    """
    conetype_ = ctypes.c_int32()
    conepar_ = ctypes.c_double()
    conepar_ = ctypes.c_double()
    nummem_ = ctypes.c_int32()
    nummem_ = ctypes.c_int32()
    if submem_ is not None and len(submem_) < self.getnumcone():
      raise ValueError("Array argument submem is not long enough")
    if isinstance(submem_,numpy.ndarray) and not submem_.flags.writeable:
      raise ValueError("Argument submem must be writable")
    if isinstance(submem_, numpy.ndarray) and submem_.dtype is numpy.int32 and submem_.flags.contiguous:
      _submem_copyarray = False
      _submem_tmp = ctypes.cast(submem_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(submem_,array.ndarray) and submem_.dtype is array.int32 and  submem_.getsteplength() == 1:
      _submem_copyarray = False
      _submem_tmp = submem_.getdatacptr()
    else:
      _submem_copyarray = True
      _submem_tmp = (ctypes.c_int32 * len(submem_))(*submem_)
    res = __library__.MSK_XX_getcone(self.__nativep,k_,ctypes.byref(conetype_),ctypes.byref(conepar_),ctypes.byref(nummem_),_submem_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _conetype_return_value = conetype(conetype_.value)
    _conepar_return_value = conepar_.value
    _nummem_return_value = nummem_.value
    if _submem_copyarray:
      submem_[:] = _submem_tmp
    return (_conetype_return_value,_conepar_return_value,_nummem_return_value)
  @accepts(_accept_any,_make_int)
  def getconeinfo(self,k_):
    """
    Obtains information about a conic constraint.
  
    getconeinfo(self,k_)
      k: int. Index of the conic constraint.
    returns: conetype,conepar,nummem
      conetype: mosek.conetype. Specifies the type of the cone.
      conepar: double. This argument is currently not used. Can be set to 0.0.
      nummem: int. Number of member variables in the cone.
    """
    conetype_ = ctypes.c_int32()
    conepar_ = ctypes.c_double()
    conepar_ = ctypes.c_double()
    nummem_ = ctypes.c_int32()
    nummem_ = ctypes.c_int32()
    res = __library__.MSK_XX_getconeinfo(self.__nativep,k_,ctypes.byref(conetype_),ctypes.byref(conepar_),ctypes.byref(nummem_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _conetype_return_value = conetype(conetype_.value)
    _conepar_return_value = conepar_.value
    _nummem_return_value = nummem_.value
    return (_conetype_return_value,_conepar_return_value,_nummem_return_value)
  @accepts(_accept_any,_make_int,_make_int,_accept_doublevector)
  def getcslice(self,first_,last_,c_):
    """
    Obtains a sequence of coefficients from the objective.
  
    getcslice(self,first_,last_,c_)
      first: int. First index in the sequence.
      last: int. Last index plus 1 in the sequence.
      c: array of double. Linear terms of the objective as a dense vector. The lengths is the number of variables.
    """
    if c_ is not None and len(c_) < (last_ - first_):
      raise ValueError("Array argument c is not long enough")
    if isinstance(c_,numpy.ndarray) and not c_.flags.writeable:
      raise ValueError("Argument c must be writable")
    if isinstance(c_, numpy.ndarray) and c_.dtype is numpy.float64 and c_.flags.contiguous:
      _c_copyarray = False
      _c_tmp = ctypes.cast(c_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(c_,array.ndarray) and c_.dtype is array.float64 and  c_.getsteplength() == 1:
      _c_copyarray = False
      _c_tmp = c_.getdatacptr()
    else:
      _c_copyarray = True
      _c_tmp = (ctypes.c_double * len(c_))(*c_)
    res = __library__.MSK_XX_getcslice(self.__nativep,first_,last_,_c_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _c_copyarray:
      c_[:] = _c_tmp
  @accepts(_accept_any,_accept_anyenum(dinfitem))
  def getdouinf(self,whichdinf_):
    """
    Obtains a double information item.
  
    getdouinf(self,whichdinf_)
      whichdinf: mosek.dinfitem. A double float information item.
    returns: dvalue
      dvalue: double. The value of the required double information item.
    """
    dvalue_ = ctypes.c_double()
    dvalue_ = ctypes.c_double()
    res = __library__.MSK_XX_getdouinf(self.__nativep,whichdinf_,ctypes.byref(dvalue_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _dvalue_return_value = dvalue_.value
    return (_dvalue_return_value)
  @accepts(_accept_any,_accept_anyenum(dparam))
  def getdouparam(self,param_):
    """
    Obtains a double parameter.
  
    getdouparam(self,param_)
      param: mosek.dparam. Which parameter.
    returns: parvalue
      parvalue: double. Parameter value.
    """
    parvalue_ = ctypes.c_double()
    parvalue_ = ctypes.c_double()
    res = __library__.MSK_XX_getdouparam(self.__nativep,param_,ctypes.byref(parvalue_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _parvalue_return_value = parvalue_.value
    return (_parvalue_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def getdualobj(self,whichsol_):
    """
    Obtains the dual objective value.
  
    getdualobj(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    returns: dualobj
      dualobj: double. Objective value corresponding to the dual solution.
    """
    dualobj_ = ctypes.c_double()
    dualobj_ = ctypes.c_double()
    res = __library__.MSK_XX_getdualobj(self.__nativep,whichsol_,ctypes.byref(dualobj_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _dualobj_return_value = dualobj_.value
    return (_dualobj_return_value)
  @accepts(_accept_any,_accept_anyenum(iinfitem))
  def getintinf(self,whichiinf_):
    """
    Obtains an integer information item.
  
    getintinf(self,whichiinf_)
      whichiinf: mosek.iinfitem. Specifies an information item.
    returns: ivalue
      ivalue: int. The value of the required integer information item.
    """
    ivalue_ = ctypes.c_int32()
    ivalue_ = ctypes.c_int32()
    res = __library__.MSK_XX_getintinf(self.__nativep,whichiinf_,ctypes.byref(ivalue_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _ivalue_return_value = ivalue_.value
    return (_ivalue_return_value)
  @accepts(_accept_any,_accept_anyenum(liinfitem))
  def getlintinf(self,whichliinf_):
    """
    Obtains an integer information item.
  
    getlintinf(self,whichliinf_)
      whichliinf: mosek.liinfitem. Specifies an information item.
    returns: ivalue
      ivalue: long. The value of the required integer information item.
    """
    ivalue_ = ctypes.c_int64()
    ivalue_ = ctypes.c_int64()
    res = __library__.MSK_XX_getlintinf(self.__nativep,whichliinf_,ctypes.byref(ivalue_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _ivalue_return_value = ivalue_.value
    return (_ivalue_return_value)
  @accepts(_accept_any,_accept_anyenum(iparam))
  def getintparam(self,param_):
    """
    Obtains an integer parameter.
  
    getintparam(self,param_)
      param: mosek.iparam. Which parameter.
    returns: parvalue
      parvalue: int. Parameter value.
    """
    parvalue_ = ctypes.c_int32()
    parvalue_ = ctypes.c_int32()
    res = __library__.MSK_XX_getintparam(self.__nativep,param_,ctypes.byref(parvalue_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _parvalue_return_value = parvalue_.value
    return (_parvalue_return_value)
  @accepts(_accept_any)
  def getmaxnumanz(self):
    """
    Obtains number of preallocated non-zeros in the linear constraint matrix.
  
    getmaxnumanz(self)
    returns: maxnumanz
      maxnumanz: long. Number of preallocated non-zero linear matrix elements.
    """
    maxnumanz_ = ctypes.c_int64()
    maxnumanz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getmaxnumanz64(self.__nativep,ctypes.byref(maxnumanz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _maxnumanz_return_value = maxnumanz_.value
    return (_maxnumanz_return_value)
  @accepts(_accept_any)
  def getmaxnumcon(self):
    """
    Obtains the number of preallocated constraints in the optimization task.
  
    getmaxnumcon(self)
    returns: maxnumcon
      maxnumcon: int. Number of preallocated constraints in the optimization task.
    """
    maxnumcon_ = ctypes.c_int32()
    maxnumcon_ = ctypes.c_int32()
    res = __library__.MSK_XX_getmaxnumcon(self.__nativep,ctypes.byref(maxnumcon_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _maxnumcon_return_value = maxnumcon_.value
    return (_maxnumcon_return_value)
  @accepts(_accept_any)
  def getmaxnumvar(self):
    """
    Obtains the maximum number variables allowed.
  
    getmaxnumvar(self)
    returns: maxnumvar
      maxnumvar: int. Number of preallocated variables in the optimization task.
    """
    maxnumvar_ = ctypes.c_int32()
    maxnumvar_ = ctypes.c_int32()
    res = __library__.MSK_XX_getmaxnumvar(self.__nativep,ctypes.byref(maxnumvar_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _maxnumvar_return_value = maxnumvar_.value
    return (_maxnumvar_return_value)
  @accepts(_accept_any,_accept_anyenum(problemitem),_make_int)
  def getnamelen(self,whichitem_,i_):
    """
    Obtains the length of a problem item name.
  
    getnamelen(self,whichitem_,i_)
      whichitem: mosek.problemitem. Problem item, i.e. a cone, a variable or a constraint name..
      i: int. Index.
    returns: len
      len: long. Is assigned the length of the required name.
    """
    len_ = ctypes.c_int64()
    len_ = ctypes.c_int64()
    res = __library__.MSK_XX_getnamelen64(self.__nativep,whichitem_,i_,ctypes.byref(len_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _len_return_value = len_.value
    return (_len_return_value)
  @accepts(_accept_any,_accept_anyenum(problemitem),_make_int)
  def getname(self,whichitem_,i_):
    """
    Obtains the name of a cone, a variable or a constraint.
  
    getname(self,whichitem_,i_)
      whichitem: mosek.problemitem. Problem item, i.e. a cone, a variable or a constraint name..
      i: int. Index.
    returns: len,name
      len: long. Is assigned the length of the required name.
      name: str. Is assigned the required name.
    """
    maxlen_ = (1  + self.getnamelen(whichitem_,i_))
    len_ = ctypes.c_int64()
    len_ = ctypes.c_int64()
    name_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_getname64(self.__nativep,whichitem_,i_,maxlen_,ctypes.byref(len_),name_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _len_return_value = len_.value
    _name_retval = name_.value.decode("utf-8")
    return (_len_return_value,_name_retval)
  @accepts(_accept_any,_accept_anyenum(problemitem),_make_int)
  def getname(self,whichitem_,i_):
    """
    Obtains the name of a cone, a variable or a constraint.
  
    getname(self,whichitem_,i_)
      whichitem: mosek.problemitem. Problem item, i.e. a cone, a variable or a constraint name..
      i: int. Index.
    returns: name
      name: str. Is assigned the required name.
    """
    maxlen_ = self.getnamelen(whichitem_,i_)
    name_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_getnameapi64(self.__nativep,whichitem_,i_,maxlen_,name_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _name_retval = name_.value.decode("utf-8")
    return (_name_retval)
  @accepts(_accept_any,_make_int)
  def getvarname(self,i_):
    """
    Obtains a name of a variable.
  
    getvarname(self,i_)
      i: int. Index.
    returns: name
      name: str. Is assigned the required name.
    """
    maxlen_ = (1  + self.getnamelen(problemitem.var,i_))
    name_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_getvarname64(self.__nativep,i_,maxlen_,name_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _name_retval = name_.value.decode("utf-8")
    return (_name_retval)
  @accepts(_accept_any,_make_int)
  def getconname(self,i_):
    """
    Obtains a name of a constraint.
  
    getconname(self,i_)
      i: int. Index.
    returns: name
      name: str. Is assigned the required name.
    """
    maxlen_ = (1  + self.getnamelen(problemitem.con,i_))
    name_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_getconname64(self.__nativep,i_,maxlen_,name_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _name_retval = name_.value.decode("utf-8")
    return (_name_retval)
  @accepts(_accept_any,_accept_anyenum(problemitem),_accept_str)
  def getnameindex(self,whichitem_,name_):
    """
    Checks whether a name has been assigned and returns the index corresponding to the name.
  
    getnameindex(self,whichitem_,name_)
      whichitem: mosek.problemitem. Problem item, i.e. a cone, a variable or a constraint name..
      name: str. The name which should be checked.
    returns: asgn,index
      asgn: int. Is non-zero if name existed.
      index: int. Returns the index of the name requested.
    """
    name_ = name_.encode("utf-8")
    asgn_ = ctypes.c_int32()
    asgn_ = ctypes.c_int32()
    index_ = ctypes.c_int32()
    index_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnameindex(self.__nativep,whichitem_,name_,ctypes.byref(asgn_),ctypes.byref(index_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _asgn_return_value = asgn_.value
    _index_return_value = index_.value
    return (_asgn_return_value,_index_return_value)
  @accepts(_accept_any)
  def getnumanz(self):
    """
    Obtains the number of non-zeros in the coefficient matrix.
  
    getnumanz(self)
    returns: numanz
      numanz: int. Number of non-zero elements in the linear constraint matrix.
    """
    numanz_ = ctypes.c_int32()
    numanz_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumanz(self.__nativep,ctypes.byref(numanz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numanz_return_value = numanz_.value
    return (_numanz_return_value)
  @accepts(_accept_any)
  def getnumanz64(self):
    """
    Obtains the number of non-zeros in the coefficient matrix.
  
    getnumanz64(self)
    returns: numanz
      numanz: long. Number of non-zero elements in the linear constraint matrix.
    """
    numanz_ = ctypes.c_int64()
    numanz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getnumanz64(self.__nativep,ctypes.byref(numanz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numanz_return_value = numanz_.value
    return (_numanz_return_value)
  @accepts(_accept_any)
  def getnumcon(self):
    """
    Obtains the number of constraints.
  
    getnumcon(self)
    returns: numcon
      numcon: int. Number of constraints.
    """
    numcon_ = ctypes.c_int32()
    numcon_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumcon(self.__nativep,ctypes.byref(numcon_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numcon_return_value = numcon_.value
    return (_numcon_return_value)
  @accepts(_accept_any)
  def getnumcone(self):
    """
    Obtains the number of cones.
  
    getnumcone(self)
    returns: numcone
      numcone: int. Number conic constraints.
    """
    numcone_ = ctypes.c_int32()
    numcone_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumcone(self.__nativep,ctypes.byref(numcone_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numcone_return_value = numcone_.value
    return (_numcone_return_value)
  @accepts(_accept_any,_make_int)
  def getnumconemem(self,k_):
    """
    Obtains the number of members in a cone.
  
    getnumconemem(self,k_)
      k: int. Index of the cone.
    returns: nummem
      nummem: int. Number of member variables in the cone.
    """
    nummem_ = ctypes.c_int32()
    nummem_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumconemem(self.__nativep,k_,ctypes.byref(nummem_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _nummem_return_value = nummem_.value
    return (_nummem_return_value)
  @accepts(_accept_any)
  def getnumintvar(self):
    """
    Obtains the number of integer-constrained variables.
  
    getnumintvar(self)
    returns: numintvar
      numintvar: int. Number of integer variables.
    """
    numintvar_ = ctypes.c_int32()
    numintvar_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumintvar(self.__nativep,ctypes.byref(numintvar_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numintvar_return_value = numintvar_.value
    return (_numintvar_return_value)
  @accepts(_accept_any,_accept_anyenum(parametertype))
  def getnumparam(self,partype_):
    """
    Obtains the number of parameters of a given type.
  
    getnumparam(self,partype_)
      partype: mosek.parametertype. Parameter type.
    returns: numparam
      numparam: int. Returns the number of parameters of the requested type.
    """
    numparam_ = ctypes.c_int32()
    numparam_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumparam(self.__nativep,partype_,ctypes.byref(numparam_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numparam_return_value = numparam_.value
    return (_numparam_return_value)
  @accepts(_accept_any,_make_int)
  def getnumqconknz(self,k_):
    """
    Obtains the number of non-zero quadratic terms in a constraint.
  
    getnumqconknz(self,k_)
      k: int. Index of the constraint for which the number of non-zero quadratic terms should be obtained.
    returns: numqcnz
      numqcnz: int. Number of quadratic terms.
    """
    numqcnz_ = ctypes.c_int32()
    numqcnz_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumqconknz(self.__nativep,k_,ctypes.byref(numqcnz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqcnz_return_value = numqcnz_.value
    return (_numqcnz_return_value)
  @accepts(_accept_any,_make_int)
  def getnumqconknz64(self,k_):
    """
    Obtains the number of non-zero quadratic terms in a constraint.
  
    getnumqconknz64(self,k_)
      k: int. Index of the constraint for which the number quadratic terms should be obtained.
    returns: numqcnz
      numqcnz: long. Number of quadratic terms.
    """
    numqcnz_ = ctypes.c_int64()
    numqcnz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getnumqconknz64(self.__nativep,k_,ctypes.byref(numqcnz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqcnz_return_value = numqcnz_.value
    return (_numqcnz_return_value)
  @accepts(_accept_any)
  def getnumqobjnz(self):
    """
    Obtains the number of non-zero quadratic terms in the objective.
  
    getnumqobjnz(self)
    returns: numqonz
      numqonz: int. Number of non-zero elements in the quadratic objective terms.
    """
    numqonz_ = ctypes.c_int32()
    numqonz_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumqobjnz(self.__nativep,ctypes.byref(numqonz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqonz_return_value = numqonz_.value
    return (_numqonz_return_value)
  @accepts(_accept_any)
  def getnumqobjnz64(self):
    """
    Obtains the number of non-zero quadratic terms in the objective.
  
    getnumqobjnz64(self)
    returns: numqonz
      numqonz: long. Number of non-zero elements in the quadratic objective terms.
    """
    numqonz_ = ctypes.c_int64()
    numqonz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getnumqobjnz64(self.__nativep,ctypes.byref(numqonz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqonz_return_value = numqonz_.value
    return (_numqonz_return_value)
  @accepts(_accept_any)
  def getnumvar(self):
    """
    Obtains the number of variables.
  
    getnumvar(self)
    returns: numvar
      numvar: int. Number of variables.
    """
    numvar_ = ctypes.c_int32()
    numvar_ = ctypes.c_int32()
    res = __library__.MSK_XX_getnumvar(self.__nativep,ctypes.byref(numvar_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numvar_return_value = numvar_.value
    return (_numvar_return_value)
  @accepts(_accept_any,_make_long)
  def getobjname(self,maxlen_):
    """
    Obtains the name assigned to the objective function.
  
    getobjname(self,maxlen_)
      maxlen: long. Length of the objname buffer.
    returns: len,objname
      len: long. Assigned the length of the objective name.
      objname: str. Assigned the objective name.
    """
    len_ = ctypes.c_int64()
    len_ = ctypes.c_int64()
    objname_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_getobjname64(self.__nativep,maxlen_,ctypes.byref(len_),objname_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _len_return_value = len_.value
    _objname_retval = objname_.value.decode("utf-8")
    return (_len_return_value,_objname_retval)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def getprimalobj(self,whichsol_):
    """
    Obtains the primal objective value.
  
    getprimalobj(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    returns: primalobj
      primalobj: double. Objective value corresponding to the primal solution.
    """
    primalobj_ = ctypes.c_double()
    primalobj_ = ctypes.c_double()
    res = __library__.MSK_XX_getprimalobj(self.__nativep,whichsol_,ctypes.byref(primalobj_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _primalobj_return_value = primalobj_.value
    return (_primalobj_return_value)
  @accepts(_accept_any)
  def getprobtype(self):
    """
    Obtains the problem type.
  
    getprobtype(self)
    returns: probtype
      probtype: mosek.problemtype. The problem type.
    """
    probtype_ = ctypes.c_int32()
    res = __library__.MSK_XX_getprobtype(self.__nativep,ctypes.byref(probtype_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _probtype_return_value = problemtype(probtype_.value)
    return (_probtype_return_value)
  @accepts(_accept_any,_make_int,_accept_intvector,_accept_intvector,_accept_doublevector)
  def getqconk64(self,k_,qcsubi_,qcsubj_,qcval_):
    """
    Obtains all the quadratic terms in a constraint.
  
    getqconk64(self,k_,qcsubi_,qcsubj_,qcval_)
      k: int. Which constraint.
      qcsubi: array of int. Row subscripts for quadratic constraint matrix.
      qcsubj: array of int. Column subscripts for quadratic constraint matrix.
      qcval: array of double. Quadratic constraint coefficient values.
    returns: numqcnz
      numqcnz: long. Number of quadratic terms.
    """
    maxnumqcnz_ = self.getnumqconnz(k_)
    qcsurp_ = ctypes.c_int64(len(qcsubi_))
    numqcnz_ = ctypes.c_int64()
    numqcnz_ = ctypes.c_int64()
    if qcsubi_ is not None and len(qcsubi_) < maxnumqcnz_:
      raise ValueError("Array argument qcsubi is not long enough")
    if isinstance(qcsubi_,numpy.ndarray) and not qcsubi_.flags.writeable:
      raise ValueError("Argument qcsubi must be writable")
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi may not be None")
    if isinstance(qcsubi_, numpy.ndarray) and qcsubi_.dtype is numpy.int32 and qcsubi_.flags.contiguous:
      _qcsubi_copyarray = False
      _qcsubi_tmp = ctypes.cast(qcsubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubi_,array.ndarray) and qcsubi_.dtype is array.int32 and  qcsubi_.getsteplength() == 1:
      _qcsubi_copyarray = False
      _qcsubi_tmp = qcsubi_.getdatacptr()
    else:
      _qcsubi_copyarray = True
      _qcsubi_tmp = (ctypes.c_int32 * len(qcsubi_))(*qcsubi_)
    if qcsubj_ is not None and len(qcsubj_) < maxnumqcnz_:
      raise ValueError("Array argument qcsubj is not long enough")
    if isinstance(qcsubj_,numpy.ndarray) and not qcsubj_.flags.writeable:
      raise ValueError("Argument qcsubj must be writable")
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj may not be None")
    if isinstance(qcsubj_, numpy.ndarray) and qcsubj_.dtype is numpy.int32 and qcsubj_.flags.contiguous:
      _qcsubj_copyarray = False
      _qcsubj_tmp = ctypes.cast(qcsubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubj_,array.ndarray) and qcsubj_.dtype is array.int32 and  qcsubj_.getsteplength() == 1:
      _qcsubj_copyarray = False
      _qcsubj_tmp = qcsubj_.getdatacptr()
    else:
      _qcsubj_copyarray = True
      _qcsubj_tmp = (ctypes.c_int32 * len(qcsubj_))(*qcsubj_)
    if qcval_ is not None and len(qcval_) < maxnumqcnz_:
      raise ValueError("Array argument qcval is not long enough")
    if isinstance(qcval_,numpy.ndarray) and not qcval_.flags.writeable:
      raise ValueError("Argument qcval must be writable")
    if qcval_ is None:
      raise ValueError("Argument qcval may not be None")
    if isinstance(qcval_, numpy.ndarray) and qcval_.dtype is numpy.float64 and qcval_.flags.contiguous:
      _qcval_copyarray = False
      _qcval_tmp = ctypes.cast(qcval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qcval_,array.ndarray) and qcval_.dtype is array.float64 and  qcval_.getsteplength() == 1:
      _qcval_copyarray = False
      _qcval_tmp = qcval_.getdatacptr()
    else:
      _qcval_copyarray = True
      _qcval_tmp = (ctypes.c_double * len(qcval_))(*qcval_)
    res = __library__.MSK_XX_getqconk64(self.__nativep,k_,maxnumqcnz_,ctypes.byref(qcsurp_),ctypes.byref(numqcnz_),_qcsubi_tmp,_qcsubj_tmp,_qcval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqcnz_return_value = numqcnz_.value
    if _qcsubi_copyarray:
      qcsubi_[:] = _qcsubi_tmp
    if _qcsubj_copyarray:
      qcsubj_[:] = _qcsubj_tmp
    if _qcval_copyarray:
      qcval_[:] = _qcval_tmp
    return (_numqcnz_return_value)
  @accepts(_accept_any,_make_int,_accept_intvector,_accept_intvector,_accept_doublevector)
  def getqconk(self,k_,qcsubi_,qcsubj_,qcval_):
    """
    Obtains all the quadratic terms in a constraint.
  
    getqconk(self,k_,qcsubi_,qcsubj_,qcval_)
      k: int. Which constraint.
      qcsubi: array of int. Row subscripts for quadratic constraint matrix.
      qcsubj: array of int. Column subscripts for quadratic constraint matrix.
      qcval: array of double. Quadratic constraint coefficient values.
    returns: numqcnz
      numqcnz: int. Number of quadratic terms.
    """
    maxnumqcnz_ = self.getnumqconnz(k_)
    qcsurp_ = ctypes.c_int32(len(qcsubi_))
    numqcnz_ = ctypes.c_int32()
    numqcnz_ = ctypes.c_int32()
    if qcsubi_ is not None and len(qcsubi_) < maxnumqcnz_:
      raise ValueError("Array argument qcsubi is not long enough")
    if isinstance(qcsubi_,numpy.ndarray) and not qcsubi_.flags.writeable:
      raise ValueError("Argument qcsubi must be writable")
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi may not be None")
    if isinstance(qcsubi_, numpy.ndarray) and qcsubi_.dtype is numpy.int32 and qcsubi_.flags.contiguous:
      _qcsubi_copyarray = False
      _qcsubi_tmp = ctypes.cast(qcsubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubi_,array.ndarray) and qcsubi_.dtype is array.int32 and  qcsubi_.getsteplength() == 1:
      _qcsubi_copyarray = False
      _qcsubi_tmp = qcsubi_.getdatacptr()
    else:
      _qcsubi_copyarray = True
      _qcsubi_tmp = (ctypes.c_int32 * len(qcsubi_))(*qcsubi_)
    if qcsubj_ is not None and len(qcsubj_) < maxnumqcnz_:
      raise ValueError("Array argument qcsubj is not long enough")
    if isinstance(qcsubj_,numpy.ndarray) and not qcsubj_.flags.writeable:
      raise ValueError("Argument qcsubj must be writable")
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj may not be None")
    if isinstance(qcsubj_, numpy.ndarray) and qcsubj_.dtype is numpy.int32 and qcsubj_.flags.contiguous:
      _qcsubj_copyarray = False
      _qcsubj_tmp = ctypes.cast(qcsubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubj_,array.ndarray) and qcsubj_.dtype is array.int32 and  qcsubj_.getsteplength() == 1:
      _qcsubj_copyarray = False
      _qcsubj_tmp = qcsubj_.getdatacptr()
    else:
      _qcsubj_copyarray = True
      _qcsubj_tmp = (ctypes.c_int32 * len(qcsubj_))(*qcsubj_)
    if qcval_ is not None and len(qcval_) < maxnumqcnz_:
      raise ValueError("Array argument qcval is not long enough")
    if isinstance(qcval_,numpy.ndarray) and not qcval_.flags.writeable:
      raise ValueError("Argument qcval must be writable")
    if qcval_ is None:
      raise ValueError("Argument qcval may not be None")
    if isinstance(qcval_, numpy.ndarray) and qcval_.dtype is numpy.float64 and qcval_.flags.contiguous:
      _qcval_copyarray = False
      _qcval_tmp = ctypes.cast(qcval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qcval_,array.ndarray) and qcval_.dtype is array.float64 and  qcval_.getsteplength() == 1:
      _qcval_copyarray = False
      _qcval_tmp = qcval_.getdatacptr()
    else:
      _qcval_copyarray = True
      _qcval_tmp = (ctypes.c_double * len(qcval_))(*qcval_)
    res = __library__.MSK_XX_getqconk(self.__nativep,k_,maxnumqcnz_,ctypes.byref(qcsurp_),ctypes.byref(numqcnz_),_qcsubi_tmp,_qcsubj_tmp,_qcval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqcnz_return_value = numqcnz_.value
    if _qcsubi_copyarray:
      qcsubi_[:] = _qcsubi_tmp
    if _qcsubj_copyarray:
      qcsubj_[:] = _qcsubj_tmp
    if _qcval_copyarray:
      qcval_[:] = _qcval_tmp
    return (_numqcnz_return_value)
  @accepts(_accept_any,_accept_intvector,_accept_intvector,_accept_doublevector)
  def getqobj(self,qosubi_,qosubj_,qoval_):
    """
    Obtains all the quadratic terms in the objective.
  
    getqobj(self,qosubi_,qosubj_,qoval_)
      qosubi: array of int. Row subscripts for quadratic objective coefficients.
      qosubj: array of int. Column subscripts for quadratic objective coefficients.
      qoval: array of double. Quadratic objective coefficient values.
    returns: numqonz
      numqonz: int. Number of non-zero elements in the quadratic objective terms.
    """
    maxnumqonz_ = self.getnumobjnz()
    qosurp_ = ctypes.c_int32(len(qosubi_))
    numqonz_ = ctypes.c_int32()
    numqonz_ = ctypes.c_int32()
    if qosubi_ is not None and len(qosubi_) < maxnumqonz_:
      raise ValueError("Array argument qosubi is not long enough")
    if isinstance(qosubi_,numpy.ndarray) and not qosubi_.flags.writeable:
      raise ValueError("Argument qosubi must be writable")
    if qosubi_ is None:
      raise ValueError("Argument qosubi may not be None")
    if isinstance(qosubi_, numpy.ndarray) and qosubi_.dtype is numpy.int32 and qosubi_.flags.contiguous:
      _qosubi_copyarray = False
      _qosubi_tmp = ctypes.cast(qosubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubi_,array.ndarray) and qosubi_.dtype is array.int32 and  qosubi_.getsteplength() == 1:
      _qosubi_copyarray = False
      _qosubi_tmp = qosubi_.getdatacptr()
    else:
      _qosubi_copyarray = True
      _qosubi_tmp = (ctypes.c_int32 * len(qosubi_))(*qosubi_)
    if qosubj_ is not None and len(qosubj_) < maxnumqonz_:
      raise ValueError("Array argument qosubj is not long enough")
    if isinstance(qosubj_,numpy.ndarray) and not qosubj_.flags.writeable:
      raise ValueError("Argument qosubj must be writable")
    if qosubj_ is None:
      raise ValueError("Argument qosubj may not be None")
    if isinstance(qosubj_, numpy.ndarray) and qosubj_.dtype is numpy.int32 and qosubj_.flags.contiguous:
      _qosubj_copyarray = False
      _qosubj_tmp = ctypes.cast(qosubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubj_,array.ndarray) and qosubj_.dtype is array.int32 and  qosubj_.getsteplength() == 1:
      _qosubj_copyarray = False
      _qosubj_tmp = qosubj_.getdatacptr()
    else:
      _qosubj_copyarray = True
      _qosubj_tmp = (ctypes.c_int32 * len(qosubj_))(*qosubj_)
    if qoval_ is not None and len(qoval_) < maxnumqonz_:
      raise ValueError("Array argument qoval is not long enough")
    if isinstance(qoval_,numpy.ndarray) and not qoval_.flags.writeable:
      raise ValueError("Argument qoval must be writable")
    if qoval_ is None:
      raise ValueError("Argument qoval may not be None")
    if isinstance(qoval_, numpy.ndarray) and qoval_.dtype is numpy.float64 and qoval_.flags.contiguous:
      _qoval_copyarray = False
      _qoval_tmp = ctypes.cast(qoval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qoval_,array.ndarray) and qoval_.dtype is array.float64 and  qoval_.getsteplength() == 1:
      _qoval_copyarray = False
      _qoval_tmp = qoval_.getdatacptr()
    else:
      _qoval_copyarray = True
      _qoval_tmp = (ctypes.c_double * len(qoval_))(*qoval_)
    res = __library__.MSK_XX_getqobj(self.__nativep,maxnumqonz_,ctypes.byref(qosurp_),ctypes.byref(numqonz_),_qosubi_tmp,_qosubj_tmp,_qoval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqonz_return_value = numqonz_.value
    if _qosubi_copyarray:
      qosubi_[:] = _qosubi_tmp
    if _qosubj_copyarray:
      qosubj_[:] = _qosubj_tmp
    if _qoval_copyarray:
      qoval_[:] = _qoval_tmp
    return (_numqonz_return_value)
  @accepts(_accept_any,_make_long,_accept_intvector,_accept_intvector,_accept_doublevector)
  def getqobj64(self,maxnumqonz_,qosubi_,qosubj_,qoval_):
    """
    Obtains all the quadratic terms in the objective.
  
    getqobj64(self,maxnumqonz_,qosubi_,qosubj_,qoval_)
      maxnumqonz: long. Length of the subscript and coefficient arrays.
      qosubi: array of int. Row subscripts for quadratic objective coefficients.
      qosubj: array of int. Column subscripts for quadratic objective coefficients.
      qoval: array of double. Quadratic objective coefficient values.
    returns: numqonz
      numqonz: long. Number of non-zero elements in the quadratic objective terms.
    """
    qosurp_ = ctypes.c_int64(len(qosubi_))
    numqonz_ = ctypes.c_int64()
    numqonz_ = ctypes.c_int64()
    if qosubi_ is not None and len(qosubi_) < maxnumqonz_:
      raise ValueError("Array argument qosubi is not long enough")
    if isinstance(qosubi_,numpy.ndarray) and not qosubi_.flags.writeable:
      raise ValueError("Argument qosubi must be writable")
    if qosubi_ is None:
      raise ValueError("Argument qosubi may not be None")
    if isinstance(qosubi_, numpy.ndarray) and qosubi_.dtype is numpy.int32 and qosubi_.flags.contiguous:
      _qosubi_copyarray = False
      _qosubi_tmp = ctypes.cast(qosubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubi_,array.ndarray) and qosubi_.dtype is array.int32 and  qosubi_.getsteplength() == 1:
      _qosubi_copyarray = False
      _qosubi_tmp = qosubi_.getdatacptr()
    else:
      _qosubi_copyarray = True
      _qosubi_tmp = (ctypes.c_int32 * len(qosubi_))(*qosubi_)
    if qosubj_ is not None and len(qosubj_) < maxnumqonz_:
      raise ValueError("Array argument qosubj is not long enough")
    if isinstance(qosubj_,numpy.ndarray) and not qosubj_.flags.writeable:
      raise ValueError("Argument qosubj must be writable")
    if qosubj_ is None:
      raise ValueError("Argument qosubj may not be None")
    if isinstance(qosubj_, numpy.ndarray) and qosubj_.dtype is numpy.int32 and qosubj_.flags.contiguous:
      _qosubj_copyarray = False
      _qosubj_tmp = ctypes.cast(qosubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubj_,array.ndarray) and qosubj_.dtype is array.int32 and  qosubj_.getsteplength() == 1:
      _qosubj_copyarray = False
      _qosubj_tmp = qosubj_.getdatacptr()
    else:
      _qosubj_copyarray = True
      _qosubj_tmp = (ctypes.c_int32 * len(qosubj_))(*qosubj_)
    if qoval_ is not None and len(qoval_) < maxnumqonz_:
      raise ValueError("Array argument qoval is not long enough")
    if isinstance(qoval_,numpy.ndarray) and not qoval_.flags.writeable:
      raise ValueError("Argument qoval must be writable")
    if qoval_ is None:
      raise ValueError("Argument qoval may not be None")
    if isinstance(qoval_, numpy.ndarray) and qoval_.dtype is numpy.float64 and qoval_.flags.contiguous:
      _qoval_copyarray = False
      _qoval_tmp = ctypes.cast(qoval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qoval_,array.ndarray) and qoval_.dtype is array.float64 and  qoval_.getsteplength() == 1:
      _qoval_copyarray = False
      _qoval_tmp = qoval_.getdatacptr()
    else:
      _qoval_copyarray = True
      _qoval_tmp = (ctypes.c_double * len(qoval_))(*qoval_)
    res = __library__.MSK_XX_getqobj64(self.__nativep,maxnumqonz_,ctypes.byref(qosurp_),ctypes.byref(numqonz_),_qosubi_tmp,_qosubj_tmp,_qoval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numqonz_return_value = numqonz_.value
    if _qosubi_copyarray:
      qosubi_[:] = _qosubi_tmp
    if _qosubj_copyarray:
      qosubj_[:] = _qosubj_tmp
    if _qoval_copyarray:
      qoval_[:] = _qoval_tmp
    return (_numqonz_return_value)
  @accepts(_accept_any,_make_int,_make_int)
  def getqobjij(self,i_,j_):
    """
    Obtains one coefficient from the quadratic term of the objective
  
    getqobjij(self,i_,j_)
      i: int. Row index of the coefficient.
      j: int. Column index of coefficient.
    returns: qoij
      qoij: double. The required coefficient.
    """
    qoij_ = ctypes.c_double()
    qoij_ = ctypes.c_double()
    res = __library__.MSK_XX_getqobjij(self.__nativep,i_,j_,ctypes.byref(qoij_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _qoij_return_value = qoij_.value
    return (_qoij_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_any,_accept_any,_accept_any,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector)
  def getsolution(self,whichsol_,skc_,skx_,skn_,xc_,xx_,y_,slc_,suc_,slx_,sux_,snx_):
    """
    Obtains the complete solution.
  
    getsolution(self,whichsol_,skc_,skx_,skn_,xc_,xx_,y_,slc_,suc_,slx_,sux_,snx_)
      whichsol: mosek.soltype. Selects a solution.
      skc: array of mosek.stakey. Status keys for the constraints.
      skx: array of mosek.stakey. Status keys for the variables.
      skn: array of mosek.stakey. Status keys for the conic constraints.
      xc: array of double. Primal constraint solution.
      xx: array of double. Primal variable solution.
      y: array of double. Vector of dual variables corresponding to the constraints.
      slc: array of double. Dual variables corresponding to the lower bounds on the constraints.
      suc: array of double. Dual variables corresponding to the upper bounds on the constraints.
      slx: array of double. Dual variables corresponding to the lower bounds on the variables.
      sux: array of double. Dual variables corresponding to the upper bounds on the variables.
      snx: array of double. Dual variables corresponding to the conic constraints on the variables.
    returns: prosta,solsta
      prosta: mosek.prosta. Problem status.
      solsta: mosek.solsta. Solution status.
    """
    prosta_ = ctypes.c_int32()
    solsta_ = ctypes.c_int32()
    if skc_ is not None and len(skc_) < self.getnumcon():
      raise ValueError("Array argument skc is not long enough")
    if isinstance(skc_,numpy.ndarray) and not skc_.flags.writeable:
      raise ValueError("Argument skc must be writable")
    if skc_ is not None:
        _skc_tmp_arr = array.zeros(len(skc_),array.int32)
        _skc_tmp = _skc_tmp_arr.getdatacptr()
    else:
        _skc_tmp_arr = None
        _skc_tmp = None
    if skx_ is not None and len(skx_) < self.getnumvar():
      raise ValueError("Array argument skx is not long enough")
    if isinstance(skx_,numpy.ndarray) and not skx_.flags.writeable:
      raise ValueError("Argument skx must be writable")
    if skx_ is not None:
        _skx_tmp_arr = array.zeros(len(skx_),array.int32)
        _skx_tmp = _skx_tmp_arr.getdatacptr()
    else:
        _skx_tmp_arr = None
        _skx_tmp = None
    if skn_ is not None and len(skn_) < self.getnumcone():
      raise ValueError("Array argument skn is not long enough")
    if isinstance(skn_,numpy.ndarray) and not skn_.flags.writeable:
      raise ValueError("Argument skn must be writable")
    if skn_ is not None:
        _skn_tmp_arr = array.zeros(len(skn_),array.int32)
        _skn_tmp = _skn_tmp_arr.getdatacptr()
    else:
        _skn_tmp_arr = None
        _skn_tmp = None
    if xc_ is not None and len(xc_) < self.getnumcon():
      raise ValueError("Array argument xc is not long enough")
    if isinstance(xc_,numpy.ndarray) and not xc_.flags.writeable:
      raise ValueError("Argument xc must be writable")
    if isinstance(xc_, numpy.ndarray) and xc_.dtype is numpy.float64 and xc_.flags.contiguous:
      _xc_copyarray = False
      _xc_tmp = ctypes.cast(xc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xc_,array.ndarray) and xc_.dtype is array.float64 and  xc_.getsteplength() == 1:
      _xc_copyarray = False
      _xc_tmp = xc_.getdatacptr()
    else:
      _xc_copyarray = True
      _xc_tmp = (ctypes.c_double * len(xc_))(*xc_)
    if xx_ is not None and len(xx_) < self.getnumvar():
      raise ValueError("Array argument xx is not long enough")
    if isinstance(xx_,numpy.ndarray) and not xx_.flags.writeable:
      raise ValueError("Argument xx must be writable")
    if isinstance(xx_, numpy.ndarray) and xx_.dtype is numpy.float64 and xx_.flags.contiguous:
      _xx_copyarray = False
      _xx_tmp = ctypes.cast(xx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xx_,array.ndarray) and xx_.dtype is array.float64 and  xx_.getsteplength() == 1:
      _xx_copyarray = False
      _xx_tmp = xx_.getdatacptr()
    else:
      _xx_copyarray = True
      _xx_tmp = (ctypes.c_double * len(xx_))(*xx_)
    if y_ is not None and len(y_) < self.getnumcon():
      raise ValueError("Array argument y is not long enough")
    if isinstance(y_,numpy.ndarray) and not y_.flags.writeable:
      raise ValueError("Argument y must be writable")
    if isinstance(y_, numpy.ndarray) and y_.dtype is numpy.float64 and y_.flags.contiguous:
      _y_copyarray = False
      _y_tmp = ctypes.cast(y_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(y_,array.ndarray) and y_.dtype is array.float64 and  y_.getsteplength() == 1:
      _y_copyarray = False
      _y_tmp = y_.getdatacptr()
    else:
      _y_copyarray = True
      _y_tmp = (ctypes.c_double * len(y_))(*y_)
    if slc_ is not None and len(slc_) < self.getnumcon():
      raise ValueError("Array argument slc is not long enough")
    if isinstance(slc_,numpy.ndarray) and not slc_.flags.writeable:
      raise ValueError("Argument slc must be writable")
    if isinstance(slc_, numpy.ndarray) and slc_.dtype is numpy.float64 and slc_.flags.contiguous:
      _slc_copyarray = False
      _slc_tmp = ctypes.cast(slc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slc_,array.ndarray) and slc_.dtype is array.float64 and  slc_.getsteplength() == 1:
      _slc_copyarray = False
      _slc_tmp = slc_.getdatacptr()
    else:
      _slc_copyarray = True
      _slc_tmp = (ctypes.c_double * len(slc_))(*slc_)
    if suc_ is not None and len(suc_) < self.getnumcon():
      raise ValueError("Array argument suc is not long enough")
    if isinstance(suc_,numpy.ndarray) and not suc_.flags.writeable:
      raise ValueError("Argument suc must be writable")
    if isinstance(suc_, numpy.ndarray) and suc_.dtype is numpy.float64 and suc_.flags.contiguous:
      _suc_copyarray = False
      _suc_tmp = ctypes.cast(suc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(suc_,array.ndarray) and suc_.dtype is array.float64 and  suc_.getsteplength() == 1:
      _suc_copyarray = False
      _suc_tmp = suc_.getdatacptr()
    else:
      _suc_copyarray = True
      _suc_tmp = (ctypes.c_double * len(suc_))(*suc_)
    if slx_ is not None and len(slx_) < self.getnumvar():
      raise ValueError("Array argument slx is not long enough")
    if isinstance(slx_,numpy.ndarray) and not slx_.flags.writeable:
      raise ValueError("Argument slx must be writable")
    if isinstance(slx_, numpy.ndarray) and slx_.dtype is numpy.float64 and slx_.flags.contiguous:
      _slx_copyarray = False
      _slx_tmp = ctypes.cast(slx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slx_,array.ndarray) and slx_.dtype is array.float64 and  slx_.getsteplength() == 1:
      _slx_copyarray = False
      _slx_tmp = slx_.getdatacptr()
    else:
      _slx_copyarray = True
      _slx_tmp = (ctypes.c_double * len(slx_))(*slx_)
    if sux_ is not None and len(sux_) < self.getnumvar():
      raise ValueError("Array argument sux is not long enough")
    if isinstance(sux_,numpy.ndarray) and not sux_.flags.writeable:
      raise ValueError("Argument sux must be writable")
    if isinstance(sux_, numpy.ndarray) and sux_.dtype is numpy.float64 and sux_.flags.contiguous:
      _sux_copyarray = False
      _sux_tmp = ctypes.cast(sux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(sux_,array.ndarray) and sux_.dtype is array.float64 and  sux_.getsteplength() == 1:
      _sux_copyarray = False
      _sux_tmp = sux_.getdatacptr()
    else:
      _sux_copyarray = True
      _sux_tmp = (ctypes.c_double * len(sux_))(*sux_)
    if snx_ is not None and len(snx_) < self.getnumcone():
      raise ValueError("Array argument snx is not long enough")
    if isinstance(snx_,numpy.ndarray) and not snx_.flags.writeable:
      raise ValueError("Argument snx must be writable")
    if isinstance(snx_, numpy.ndarray) and snx_.dtype is numpy.float64 and snx_.flags.contiguous:
      _snx_copyarray = False
      _snx_tmp = ctypes.cast(snx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(snx_,array.ndarray) and snx_.dtype is array.float64 and  snx_.getsteplength() == 1:
      _snx_copyarray = False
      _snx_tmp = snx_.getdatacptr()
    else:
      _snx_copyarray = True
      _snx_tmp = (ctypes.c_double * len(snx_))(*snx_)
    res = __library__.MSK_XX_getsolution(self.__nativep,whichsol_,ctypes.byref(prosta_),ctypes.byref(solsta_),_skc_tmp,_skx_tmp,_skn_tmp,_xc_tmp,_xx_tmp,_y_tmp,_slc_tmp,_suc_tmp,_slx_tmp,_sux_tmp,_snx_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _prosta_return_value = prosta(prosta_.value)
    _solsta_return_value = solsta(solsta_.value)
    if skc_ is not None: skc_[:] = [ stakey(v) for v in _skc_tmp[0:len(skc_)] ]
    if skx_ is not None: skx_[:] = [ stakey(v) for v in _skx_tmp[0:len(skx_)] ]
    if skn_ is not None: skn_[:] = [ stakey(v) for v in _skn_tmp[0:len(skn_)] ]
    if _xc_copyarray:
      xc_[:] = _xc_tmp
    if _xx_copyarray:
      xx_[:] = _xx_tmp
    if _y_copyarray:
      y_[:] = _y_tmp
    if _slc_copyarray:
      slc_[:] = _slc_tmp
    if _suc_copyarray:
      suc_[:] = _suc_tmp
    if _slx_copyarray:
      slx_[:] = _slx_tmp
    if _sux_copyarray:
      sux_[:] = _sux_tmp
    if _snx_copyarray:
      snx_[:] = _snx_tmp
    return (_prosta_return_value,_solsta_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_anyenum(accmode),_make_intvector,_accept_doublevector,_make_int)
  def getpbi(self,whichsol_,accmode_,sub_,pbi_,normalize_):
    """
    Obtains the primal bound infeasibility.
  
    getpbi(self,whichsol_,accmode_,sub_,pbi_,normalize_)
      whichsol: mosek.soltype. Selects a solution.
      accmode: mosek.accmode. Defines whether bound infeasibilities related to constraints or variable are retrieved.
      sub: array of int. An array of constraint or variable indexes.
      pbi: array of double. Bound infeasibility.
      normalize: int. If non-zero, normalize with largest absolute value of input data.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if pbi_ is not None and len(pbi_) < len_:
      raise ValueError("Array argument pbi is not long enough")
    if isinstance(pbi_,numpy.ndarray) and not pbi_.flags.writeable:
      raise ValueError("Argument pbi must be writable")
    if isinstance(pbi_, numpy.ndarray) and pbi_.dtype is numpy.float64 and pbi_.flags.contiguous:
      _pbi_copyarray = False
      _pbi_tmp = ctypes.cast(pbi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(pbi_,array.ndarray) and pbi_.dtype is array.float64 and  pbi_.getsteplength() == 1:
      _pbi_copyarray = False
      _pbi_tmp = pbi_.getdatacptr()
    else:
      _pbi_copyarray = True
      _pbi_tmp = (ctypes.c_double * len(pbi_))(*pbi_)
    res = __library__.MSK_XX_getpbi(self.__nativep,whichsol_,accmode_,_sub_tmp,len_,_pbi_tmp,normalize_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _pbi_copyarray:
      pbi_[:] = _pbi_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_anyenum(accmode),_make_intvector,_accept_doublevector)
  def getdbi(self,whichsol_,accmode_,sub_,dbi_):
    """
    Obtains the dual bound infeasibility.
  
    getdbi(self,whichsol_,accmode_,sub_,dbi_)
      whichsol: mosek.soltype. Selects a solution.
      accmode: mosek.accmode. Defines whether sub contains constraint or variable indexes.
      sub: array of int. Indexes of constraints or variables.
      dbi: array of double. Dual bound infeasibility.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if dbi_ is not None and len(dbi_) < len_:
      raise ValueError("Array argument dbi is not long enough")
    if isinstance(dbi_,numpy.ndarray) and not dbi_.flags.writeable:
      raise ValueError("Argument dbi must be writable")
    if isinstance(dbi_, numpy.ndarray) and dbi_.dtype is numpy.float64 and dbi_.flags.contiguous:
      _dbi_copyarray = False
      _dbi_tmp = ctypes.cast(dbi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(dbi_,array.ndarray) and dbi_.dtype is array.float64 and  dbi_.getsteplength() == 1:
      _dbi_copyarray = False
      _dbi_tmp = dbi_.getdatacptr()
    else:
      _dbi_copyarray = True
      _dbi_tmp = (ctypes.c_double * len(dbi_))(*dbi_)
    res = __library__.MSK_XX_getdbi(self.__nativep,whichsol_,accmode_,_sub_tmp,len_,_dbi_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _dbi_copyarray:
      dbi_[:] = _dbi_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_anyenum(accmode),_make_intvector,_accept_doublevector,_make_int)
  def getdeqi(self,whichsol_,accmode_,sub_,deqi_,normalize_):
    """
    Optains the dual equation infeasibility.
  
    getdeqi(self,whichsol_,accmode_,sub_,deqi_,normalize_)
      whichsol: mosek.soltype. Selects a solution.
      accmode: mosek.accmode. Defines whether equation infeasibilities for constraints or for variables are retrieved.
      sub: array of int. Indexes of constraints or variables.
      deqi: array of double. Dual equation infeasibilitys corresponding to constraints or variables.
      normalize: int. If non-zero, normalize with largest absolute value of input data.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if deqi_ is not None and len(deqi_) < len_:
      raise ValueError("Array argument deqi is not long enough")
    if isinstance(deqi_,numpy.ndarray) and not deqi_.flags.writeable:
      raise ValueError("Argument deqi must be writable")
    if isinstance(deqi_, numpy.ndarray) and deqi_.dtype is numpy.float64 and deqi_.flags.contiguous:
      _deqi_copyarray = False
      _deqi_tmp = ctypes.cast(deqi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(deqi_,array.ndarray) and deqi_.dtype is array.float64 and  deqi_.getsteplength() == 1:
      _deqi_copyarray = False
      _deqi_tmp = deqi_.getdatacptr()
    else:
      _deqi_copyarray = True
      _deqi_tmp = (ctypes.c_double * len(deqi_))(*deqi_)
    res = __library__.MSK_XX_getdeqi(self.__nativep,whichsol_,accmode_,_sub_tmp,len_,_deqi_tmp,normalize_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _deqi_copyarray:
      deqi_[:] = _deqi_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_make_intvector,_accept_doublevector,_make_int)
  def getpeqi(self,whichsol_,sub_,peqi_,normalize_):
    """
    Obtains the primal equation infeasibility.
  
    getpeqi(self,whichsol_,sub_,peqi_,normalize_)
      whichsol: mosek.soltype. Selects a solution.
      sub: array of int. Constraint indexes for which to calculate the equation infeasibility.
      peqi: array of double. Equation infeasibility.
      normalize: int. If non-zero, normalize with largest absolute value of input data.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if peqi_ is not None and len(peqi_) < len_:
      raise ValueError("Array argument peqi is not long enough")
    if isinstance(peqi_,numpy.ndarray) and not peqi_.flags.writeable:
      raise ValueError("Argument peqi must be writable")
    if isinstance(peqi_, numpy.ndarray) and peqi_.dtype is numpy.float64 and peqi_.flags.contiguous:
      _peqi_copyarray = False
      _peqi_tmp = ctypes.cast(peqi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(peqi_,array.ndarray) and peqi_.dtype is array.float64 and  peqi_.getsteplength() == 1:
      _peqi_copyarray = False
      _peqi_tmp = peqi_.getdatacptr()
    else:
      _peqi_copyarray = True
      _peqi_tmp = (ctypes.c_double * len(peqi_))(*peqi_)
    res = __library__.MSK_XX_getpeqi(self.__nativep,whichsol_,_sub_tmp,len_,_peqi_tmp,normalize_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _peqi_copyarray:
      peqi_[:] = _peqi_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_make_intvector,_accept_doublevector)
  def getinti(self,whichsol_,sub_,inti_):
    """
    Obtains the primal equation infeasibility.
  
    getinti(self,whichsol_,sub_,inti_)
      whichsol: mosek.soltype. Selects a solution.
      sub: array of int. Variable indexes for which to calculate the integer infeasibility.
      inti: array of double. Integer infeasibility.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if inti_ is not None and len(inti_) < len_:
      raise ValueError("Array argument inti is not long enough")
    if isinstance(inti_,numpy.ndarray) and not inti_.flags.writeable:
      raise ValueError("Argument inti must be writable")
    if isinstance(inti_, numpy.ndarray) and inti_.dtype is numpy.float64 and inti_.flags.contiguous:
      _inti_copyarray = False
      _inti_tmp = ctypes.cast(inti_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(inti_,array.ndarray) and inti_.dtype is array.float64 and  inti_.getsteplength() == 1:
      _inti_copyarray = False
      _inti_tmp = inti_.getdatacptr()
    else:
      _inti_copyarray = True
      _inti_tmp = (ctypes.c_double * len(inti_))(*inti_)
    res = __library__.MSK_XX_getinti(self.__nativep,whichsol_,_sub_tmp,len_,_inti_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _inti_copyarray:
      inti_[:] = _inti_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_make_intvector,_accept_doublevector)
  def getpcni(self,whichsol_,sub_,pcni_):
    """
    Obtains the primal cone infeasibility.
  
    getpcni(self,whichsol_,sub_,pcni_)
      whichsol: mosek.soltype. Selects a solution.
      sub: array of int. Constraint indexes for which to calculate the equation infeasibility.
      pcni: array of double. Primal cone infeasibility.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if pcni_ is not None and len(pcni_) < len_:
      raise ValueError("Array argument pcni is not long enough")
    if isinstance(pcni_,numpy.ndarray) and not pcni_.flags.writeable:
      raise ValueError("Argument pcni must be writable")
    if isinstance(pcni_, numpy.ndarray) and pcni_.dtype is numpy.float64 and pcni_.flags.contiguous:
      _pcni_copyarray = False
      _pcni_tmp = ctypes.cast(pcni_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(pcni_,array.ndarray) and pcni_.dtype is array.float64 and  pcni_.getsteplength() == 1:
      _pcni_copyarray = False
      _pcni_tmp = pcni_.getdatacptr()
    else:
      _pcni_copyarray = True
      _pcni_tmp = (ctypes.c_double * len(pcni_))(*pcni_)
    res = __library__.MSK_XX_getpcni(self.__nativep,whichsol_,_sub_tmp,len_,_pcni_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _pcni_copyarray:
      pcni_[:] = _pcni_tmp
  @accepts(_accept_any,_accept_anyenum(soltype),_make_intvector,_accept_doublevector)
  def getdcni(self,whichsol_,sub_,dcni_):
    """
    Obtains the dual cone infeasibility.
  
    getdcni(self,whichsol_,sub_,dcni_)
      whichsol: mosek.soltype. Selects a solution.
      sub: array of int. Constraint indexes to calculate equation infeasibility for.
      dcni: array of double. Dual cone infeasibility.
    """
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    len_ = None
    if len_ is None:
      len_ = len(sub_)
    else:
      len_ = min(len_,len(sub_))
    if dcni_ is not None and len(dcni_) < len_:
      raise ValueError("Array argument dcni is not long enough")
    if isinstance(dcni_,numpy.ndarray) and not dcni_.flags.writeable:
      raise ValueError("Argument dcni must be writable")
    if isinstance(dcni_, numpy.ndarray) and dcni_.dtype is numpy.float64 and dcni_.flags.contiguous:
      _dcni_copyarray = False
      _dcni_tmp = ctypes.cast(dcni_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(dcni_,array.ndarray) and dcni_.dtype is array.float64 and  dcni_.getsteplength() == 1:
      _dcni_copyarray = False
      _dcni_tmp = dcni_.getdatacptr()
    else:
      _dcni_copyarray = True
      _dcni_tmp = (ctypes.c_double * len(dcni_))(*dcni_)
    res = __library__.MSK_XX_getdcni(self.__nativep,whichsol_,_sub_tmp,len_,_dcni_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _dcni_copyarray:
      dcni_[:] = _dcni_tmp
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_accept_anyenum(soltype))
  def getsolutioni(self,accmode_,i_,whichsol_):
    """
    Obtains the solution for a single constraint or variable.
  
    getsolutioni(self,accmode_,i_,whichsol_)
      accmode: mosek.accmode. Defines whether solution information for a constraint or for a variable is retrieved.
      i: int. Index of the constraint or variable.
      whichsol: mosek.soltype. Selects a solution.
    returns: sk,x,sl,su,sn
      sk: mosek.stakey. Status key of the constraint of variable.
      x: double. Solution value of the primal variable.
      sl: double. Solution value of the dual variable associated with the lower bound.
      su: double. Solution value of the dual variable associated with the upper bound.
      sn: double. Solution value of the dual variable associated with the cone constraint.
    """
    sk_ = ctypes.c_int32()
    x_ = ctypes.c_double()
    x_ = ctypes.c_double()
    sl_ = ctypes.c_double()
    sl_ = ctypes.c_double()
    su_ = ctypes.c_double()
    su_ = ctypes.c_double()
    sn_ = ctypes.c_double()
    sn_ = ctypes.c_double()
    res = __library__.MSK_XX_getsolutioni(self.__nativep,accmode_,i_,whichsol_,ctypes.byref(sk_),ctypes.byref(x_),ctypes.byref(sl_),ctypes.byref(su_),ctypes.byref(sn_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _sk_return_value = stakey(sk_.value)
    _x_return_value = x_.value
    _sl_return_value = sl_.value
    _su_return_value = su_.value
    _sn_return_value = sn_.value
    return (_sk_return_value,_x_return_value,_sl_return_value,_su_return_value,_sn_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def getsolutioninf(self,whichsol_):
    """
    Obtains information about a solution.
  
    getsolutioninf(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    returns: prosta,solsta,primalobj,maxpbi,maxpcni,maxpeqi,maxinti,dualobj,maxdbi,maxdcni,maxdeqi
      prosta: mosek.prosta. Problem status.
      solsta: mosek.solsta. Solution status.
      primalobj: double. Value of the primal objective.
      maxpbi: double. Maximum infeasibility in primal bounds on variables.
      maxpcni: double. Maximum infeasibility in the primal conic constraints.
      maxpeqi: double. Maximum infeasibility in primal equality constraints.
      maxinti: double. Maximum infeasibility in primal equality constraints.
      dualobj: double. Value of the dual objective.
      maxdbi: double. Maximum infeasibility in bounds on dual variables.
      maxdcni: double. Maximum infeasibility in the dual conic constraints.
      maxdeqi: double. Maximum infeasibility in the dual equality constraints.
    """
    prosta_ = ctypes.c_int32()
    solsta_ = ctypes.c_int32()
    primalobj_ = ctypes.c_double()
    primalobj_ = ctypes.c_double()
    maxpbi_ = ctypes.c_double()
    maxpbi_ = ctypes.c_double()
    maxpcni_ = ctypes.c_double()
    maxpcni_ = ctypes.c_double()
    maxpeqi_ = ctypes.c_double()
    maxpeqi_ = ctypes.c_double()
    maxinti_ = ctypes.c_double()
    maxinti_ = ctypes.c_double()
    dualobj_ = ctypes.c_double()
    dualobj_ = ctypes.c_double()
    maxdbi_ = ctypes.c_double()
    maxdbi_ = ctypes.c_double()
    maxdcni_ = ctypes.c_double()
    maxdcni_ = ctypes.c_double()
    maxdeqi_ = ctypes.c_double()
    maxdeqi_ = ctypes.c_double()
    res = __library__.MSK_XX_getsolutioninf(self.__nativep,whichsol_,ctypes.byref(prosta_),ctypes.byref(solsta_),ctypes.byref(primalobj_),ctypes.byref(maxpbi_),ctypes.byref(maxpcni_),ctypes.byref(maxpeqi_),ctypes.byref(maxinti_),ctypes.byref(dualobj_),ctypes.byref(maxdbi_),ctypes.byref(maxdcni_),ctypes.byref(maxdeqi_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _prosta_return_value = prosta(prosta_.value)
    _solsta_return_value = solsta(solsta_.value)
    _primalobj_return_value = primalobj_.value
    _maxpbi_return_value = maxpbi_.value
    _maxpcni_return_value = maxpcni_.value
    _maxpeqi_return_value = maxpeqi_.value
    _maxinti_return_value = maxinti_.value
    _dualobj_return_value = dualobj_.value
    _maxdbi_return_value = maxdbi_.value
    _maxdcni_return_value = maxdcni_.value
    _maxdeqi_return_value = maxdeqi_.value
    return (_prosta_return_value,_solsta_return_value,_primalobj_return_value,_maxpbi_return_value,_maxpcni_return_value,_maxpeqi_return_value,_maxinti_return_value,_dualobj_return_value,_maxdbi_return_value,_maxdcni_return_value,_maxdeqi_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def getsolutionstatus(self,whichsol_):
    """
    Obtains information about the problem and solution statuses.
  
    getsolutionstatus(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    returns: prosta,solsta
      prosta: mosek.prosta. Problem status.
      solsta: mosek.solsta. Solution status.
    """
    prosta_ = ctypes.c_int32()
    solsta_ = ctypes.c_int32()
    res = __library__.MSK_XX_getsolutionstatus(self.__nativep,whichsol_,ctypes.byref(prosta_),ctypes.byref(solsta_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _prosta_return_value = prosta(prosta_.value)
    _solsta_return_value = solsta(solsta_.value)
    return (_prosta_return_value,_solsta_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_anyenum(solitem),_make_int,_make_int,_accept_doublevector)
  def getsolutionslice(self,whichsol_,solitem_,first_,last_,values_):
    """
    Obtains a slice of the solution.
  
    getsolutionslice(self,whichsol_,solitem_,first_,last_,values_)
      whichsol: mosek.soltype. Selects a solution.
      solitem: mosek.solitem. Which part of the solution is required.
      first: int. Index of the first value in the slice.
      last: int. Value of the last index+1 in the slice.
      values: array of double. The values of the requested solution elements.
    """
    if values_ is not None and len(values_) < (last_ - first_):
      raise ValueError("Array argument values is not long enough")
    if isinstance(values_,numpy.ndarray) and not values_.flags.writeable:
      raise ValueError("Argument values must be writable")
    if isinstance(values_, numpy.ndarray) and values_.dtype is numpy.float64 and values_.flags.contiguous:
      _values_copyarray = False
      _values_tmp = ctypes.cast(values_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(values_,array.ndarray) and values_.dtype is array.float64 and  values_.getsteplength() == 1:
      _values_copyarray = False
      _values_tmp = values_.getdatacptr()
    else:
      _values_copyarray = True
      _values_tmp = (ctypes.c_double * len(values_))(*values_)
    res = __library__.MSK_XX_getsolutionslice(self.__nativep,whichsol_,solitem_,first_,last_,_values_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _values_copyarray:
      values_[:] = _values_tmp
  @accepts(_accept_any,_accept_anyenum(accmode),_accept_anyenum(soltype),_make_int,_make_int,_accept_any)
  def getsolutionstatuskeyslice(self,accmode_,whichsol_,first_,last_,sk_):
    """
    Obtains a slice of the solution status keys.
  
    getsolutionstatuskeyslice(self,accmode_,whichsol_,first_,last_,sk_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      whichsol: mosek.soltype. Selects a solution.
      first: int. Index of the first value in the slice.
      last: int. Value of the last index+1 in the slice.
      sk: array of mosek.stakey. The status keys of the requested solution elements.
    """
    if sk_ is not None and len(sk_) < (last_ - first_):
      raise ValueError("Array argument sk is not long enough")
    if isinstance(sk_,numpy.ndarray) and not sk_.flags.writeable:
      raise ValueError("Argument sk must be writable")
    if sk_ is None:
      raise ValueError("Argument sk may not be None")
    if sk_ is not None:
        _sk_tmp_arr = array.zeros(len(sk_),array.int32)
        _sk_tmp = _sk_tmp_arr.getdatacptr()
    else:
        _sk_tmp_arr = None
        _sk_tmp = None
    res = __library__.MSK_XX_getsolutionstatuskeyslice(self.__nativep,accmode_,whichsol_,first_,last_,_sk_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if sk_ is not None: sk_[:] = [ stakey(v) for v in _sk_tmp[0:len(sk_)] ]
  @accepts(_accept_any,_accept_anyenum(soltype),_make_int,_make_int,_accept_doublevector)
  def getreducedcosts(self,whichsol_,first_,last_,redcosts_):
    """
    Obtains the difference of (slx-sux) for a sequence of variables.
  
    getreducedcosts(self,whichsol_,first_,last_,redcosts_)
      whichsol: mosek.soltype. Selects a solution.
      first: int. See the documentation for a full description.
      last: int. See the documentation for a full description.
      redcosts: array of double. Returns the requested reduced costs. See documentation for a full description.
    """
    if redcosts_ is not None and len(redcosts_) < (last_ - first_):
      raise ValueError("Array argument redcosts is not long enough")
    if isinstance(redcosts_,numpy.ndarray) and not redcosts_.flags.writeable:
      raise ValueError("Argument redcosts must be writable")
    if isinstance(redcosts_, numpy.ndarray) and redcosts_.dtype is numpy.float64 and redcosts_.flags.contiguous:
      _redcosts_copyarray = False
      _redcosts_tmp = ctypes.cast(redcosts_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(redcosts_,array.ndarray) and redcosts_.dtype is array.float64 and  redcosts_.getsteplength() == 1:
      _redcosts_copyarray = False
      _redcosts_tmp = redcosts_.getdatacptr()
    else:
      _redcosts_copyarray = True
      _redcosts_tmp = (ctypes.c_double * len(redcosts_))(*redcosts_)
    res = __library__.MSK_XX_getreducedcosts(self.__nativep,whichsol_,first_,last_,_redcosts_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _redcosts_copyarray:
      redcosts_[:] = _redcosts_tmp
  @accepts(_accept_any)
  def gettaskname64(self):
    """
    Obtains the task name.
  
    gettaskname64(self)
    returns: len,taskname
      len: long. Is assigned the length of the task name.
      taskname: str. Is assigned the task name.
    """
    __tmp_var_0 = ctypes.c_int64()
    res = __library__.MSK_XX_gettaskname64(self.__nativep,0,ctypes.byref(__tmp_var_0),None)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    maxlen_ = __tmp_var_0.value
    len_ = ctypes.c_int64()
    len_ = ctypes.c_int64()
    taskname_ = (ctypes.c_char * maxlen_)()
    res = __library__.MSK_XX_gettaskname64(self.__nativep,maxlen_,ctypes.byref(len_),taskname_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _len_return_value = len_.value
    _taskname_retval = taskname_.value.decode("utf-8")
    return (_len_return_value,_taskname_retval)
  @accepts(_accept_any)
  def getintpntnumthreads(self):
    """
    Obtains the number of threads used by the interior-point optimizer.
  
    getintpntnumthreads(self)
    returns: numthreads
      numthreads: int. The number of threads.
    """
    numthreads_ = ctypes.c_int32()
    numthreads_ = ctypes.c_int32()
    res = __library__.MSK_XX_getintpntnumthreads(self.__nativep,ctypes.byref(numthreads_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numthreads_return_value = numthreads_.value
    return (_numthreads_return_value)
  @accepts(_accept_any,_make_int)
  def getvartype(self,j_):
    """
    Gets the variable type of one variable.
  
    getvartype(self,j_)
      j: int. Index of the variable.
    returns: vartype
      vartype: mosek.variabletype. Variable type of variable index j.
    """
    vartype_ = ctypes.c_int32()
    res = __library__.MSK_XX_getvartype(self.__nativep,j_,ctypes.byref(vartype_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _vartype_return_value = variabletype(vartype_.value)
    return (_vartype_return_value)
  @accepts(_accept_any,_make_intvector,_accept_any)
  def getvartypelist(self,subj_,vartype_):
    """
    Obtains the variable type for one or more variables.
  
    getvartypelist(self,subj_,vartype_)
      subj: array of int. A list of variable indexes.
      vartype: array of mosek.variabletype. Returns the variables types corresponding the variable indexes requested.
    """
    num_ = None
    if num_ is None:
      num_ = len(subj_)
    else:
      num_ = min(num_,len(subj_))
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if vartype_ is not None and len(vartype_) < num_:
      raise ValueError("Array argument vartype is not long enough")
    if isinstance(vartype_,numpy.ndarray) and not vartype_.flags.writeable:
      raise ValueError("Argument vartype must be writable")
    if vartype_ is not None:
        _vartype_tmp_arr = array.zeros(len(vartype_),array.int32)
        _vartype_tmp = _vartype_tmp_arr.getdatacptr()
    else:
        _vartype_tmp_arr = None
        _vartype_tmp = None
    res = __library__.MSK_XX_getvartypelist(self.__nativep,num_,_subj_tmp,_vartype_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if vartype_ is not None: vartype_[:] = [ variabletype(v) for v in _vartype_tmp[0:len(vartype_)] ]
  @accepts(_accept_any,_make_int,_make_int,_make_doublevector,_make_double,_make_longvector,_make_longvector,_make_intvector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector)
  def inputdata(self,maxnumcon_,maxnumvar_,c_,cfix_,aptrb_,aptre_,asub_,aval_,bkc_,blc_,buc_,bkx_,blx_,bux_):
    """
    Input the linear part of an optimization task in one function call.
  
    inputdata(self,maxnumcon_,maxnumvar_,c_,cfix_,aptrb_,aptre_,asub_,aval_,bkc_,blc_,buc_,bkx_,blx_,bux_)
      maxnumcon: int. Number of preallocated constraints in the optimization task.
      maxnumvar: int. Number of preallocated variables in the optimization task.
      c: array of double. Linear terms of the objective as a dense vector. The lengths is the number of variables.
      cfix: double. Fixed term in the objective.
      aptrb: array of long. Row or column end pointers.
      aptre: array of long. Row or column start pointers.
      asub: array of int. Coefficient subscripts.
      aval: array of double. Coefficient coefficient values.
      bkc: array of mosek.boundkey. Bound keys for the constraints.
      blc: array of double. Lower bounds for the constraints.
      buc: array of double. Upper bounds for the constraints.
      bkx: array of mosek.boundkey. Bound keys for the variables.
      blx: array of double. Lower bounds for the variables.
      bux: array of double. Upper bounds for the variables.
    """
    numcon_ = None
    if numcon_ is None:
      numcon_ = len(buc_)
    else:
      numcon_ = min(numcon_,len(buc_))
    if numcon_ is None:
      numcon_ = len(blc_)
    else:
      numcon_ = min(numcon_,len(blc_))
    if numcon_ is None:
      numcon_ = len(bkc_)
    else:
      numcon_ = min(numcon_,len(bkc_))
    numvar_ = None
    if numvar_ is None:
      numvar_ = len(c_)
    else:
      numvar_ = min(numvar_,len(c_))
    if numvar_ is None:
      numvar_ = len(bux_)
    else:
      numvar_ = min(numvar_,len(bux_))
    if numvar_ is None:
      numvar_ = len(blx_)
    else:
      numvar_ = min(numvar_,len(blx_))
    if numvar_ is None:
      numvar_ = len(bkx_)
    else:
      numvar_ = min(numvar_,len(bkx_))
    if numvar_ is None:
      numvar_ = len(aptrb_)
    else:
      numvar_ = min(numvar_,len(aptrb_))
    if numvar_ is None:
      numvar_ = len(aptre_)
    else:
      numvar_ = min(numvar_,len(aptre_))
    if isinstance(c_, numpy.ndarray) and c_.dtype is numpy.float64 and c_.flags.contiguous:
      _c_copyarray = False
      _c_tmp = ctypes.cast(c_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(c_,array.ndarray) and c_.dtype is array.float64 and  c_.getsteplength() == 1:
      _c_copyarray = False
      _c_tmp = c_.getdatacptr()
    else:
      _c_copyarray = True
      _c_tmp = (ctypes.c_double * len(c_))(*c_)
    if aptrb_ is None:
      raise ValueError("Argument aptrb cannot be None")
    if aptrb_ is None:
      raise ValueError("Argument aptrb may not be None")
    if isinstance(aptrb_, numpy.ndarray) and aptrb_.dtype is numpy.int64 and aptrb_.flags.contiguous:
      _aptrb_copyarray = False
      _aptrb_tmp = ctypes.cast(aptrb_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(aptrb_,array.ndarray) and aptrb_.dtype is array.int64 and  aptrb_.getsteplength() == 1:
      _aptrb_copyarray = False
      _aptrb_tmp = aptrb_.getdatacptr()
    else:
      _aptrb_copyarray = True
      _aptrb_tmp = (ctypes.c_int64 * len(aptrb_))(*aptrb_)
    if aptre_ is None:
      raise ValueError("Argument aptre cannot be None")
    if aptre_ is None:
      raise ValueError("Argument aptre may not be None")
    if isinstance(aptre_, numpy.ndarray) and aptre_.dtype is numpy.int64 and aptre_.flags.contiguous:
      _aptre_copyarray = False
      _aptre_tmp = ctypes.cast(aptre_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(aptre_,array.ndarray) and aptre_.dtype is array.int64 and  aptre_.getsteplength() == 1:
      _aptre_copyarray = False
      _aptre_tmp = aptre_.getdatacptr()
    else:
      _aptre_copyarray = True
      _aptre_tmp = (ctypes.c_int64 * len(aptre_))(*aptre_)
    if asub_ is None:
      raise ValueError("Argument asub cannot be None")
    if asub_ is None:
      raise ValueError("Argument asub may not be None")
    if isinstance(asub_, numpy.ndarray) and asub_.dtype is numpy.int32 and asub_.flags.contiguous:
      _asub_copyarray = False
      _asub_tmp = ctypes.cast(asub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(asub_,array.ndarray) and asub_.dtype is array.int32 and  asub_.getsteplength() == 1:
      _asub_copyarray = False
      _asub_tmp = asub_.getdatacptr()
    else:
      _asub_copyarray = True
      _asub_tmp = (ctypes.c_int32 * len(asub_))(*asub_)
    if aval_ is None:
      raise ValueError("Argument aval cannot be None")
    if aval_ is None:
      raise ValueError("Argument aval may not be None")
    if isinstance(aval_, numpy.ndarray) and aval_.dtype is numpy.float64 and aval_.flags.contiguous:
      _aval_copyarray = False
      _aval_tmp = ctypes.cast(aval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(aval_,array.ndarray) and aval_.dtype is array.float64 and  aval_.getsteplength() == 1:
      _aval_copyarray = False
      _aval_tmp = aval_.getdatacptr()
    else:
      _aval_copyarray = True
      _aval_tmp = (ctypes.c_double * len(aval_))(*aval_)
    if bkc_ is None:
      raise ValueError("Argument bkc cannot be None")
    if bkc_ is None:
      raise ValueError("Argument bkc may not be None")
    _bkc_tmp_arr = array.array(bkc_,array.int32)
    _bkc_tmp = _bkc_tmp_arr.getdatacptr()
    if blc_ is None:
      raise ValueError("Argument blc cannot be None")
    if blc_ is None:
      raise ValueError("Argument blc may not be None")
    if isinstance(blc_, numpy.ndarray) and blc_.dtype is numpy.float64 and blc_.flags.contiguous:
      _blc_copyarray = False
      _blc_tmp = ctypes.cast(blc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blc_,array.ndarray) and blc_.dtype is array.float64 and  blc_.getsteplength() == 1:
      _blc_copyarray = False
      _blc_tmp = blc_.getdatacptr()
    else:
      _blc_copyarray = True
      _blc_tmp = (ctypes.c_double * len(blc_))(*blc_)
    if buc_ is None:
      raise ValueError("Argument buc cannot be None")
    if buc_ is None:
      raise ValueError("Argument buc may not be None")
    if isinstance(buc_, numpy.ndarray) and buc_.dtype is numpy.float64 and buc_.flags.contiguous:
      _buc_copyarray = False
      _buc_tmp = ctypes.cast(buc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(buc_,array.ndarray) and buc_.dtype is array.float64 and  buc_.getsteplength() == 1:
      _buc_copyarray = False
      _buc_tmp = buc_.getdatacptr()
    else:
      _buc_copyarray = True
      _buc_tmp = (ctypes.c_double * len(buc_))(*buc_)
    if bkx_ is None:
      raise ValueError("Argument bkx cannot be None")
    if bkx_ is None:
      raise ValueError("Argument bkx may not be None")
    _bkx_tmp_arr = array.array(bkx_,array.int32)
    _bkx_tmp = _bkx_tmp_arr.getdatacptr()
    if blx_ is None:
      raise ValueError("Argument blx cannot be None")
    if blx_ is None:
      raise ValueError("Argument blx may not be None")
    if isinstance(blx_, numpy.ndarray) and blx_.dtype is numpy.float64 and blx_.flags.contiguous:
      _blx_copyarray = False
      _blx_tmp = ctypes.cast(blx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blx_,array.ndarray) and blx_.dtype is array.float64 and  blx_.getsteplength() == 1:
      _blx_copyarray = False
      _blx_tmp = blx_.getdatacptr()
    else:
      _blx_copyarray = True
      _blx_tmp = (ctypes.c_double * len(blx_))(*blx_)
    if bux_ is None:
      raise ValueError("Argument bux cannot be None")
    if bux_ is None:
      raise ValueError("Argument bux may not be None")
    if isinstance(bux_, numpy.ndarray) and bux_.dtype is numpy.float64 and bux_.flags.contiguous:
      _bux_copyarray = False
      _bux_tmp = ctypes.cast(bux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bux_,array.ndarray) and bux_.dtype is array.float64 and  bux_.getsteplength() == 1:
      _bux_copyarray = False
      _bux_tmp = bux_.getdatacptr()
    else:
      _bux_copyarray = True
      _bux_tmp = (ctypes.c_double * len(bux_))(*bux_)
    res = __library__.MSK_XX_inputdata64(self.__nativep,maxnumcon_,maxnumvar_,numcon_,numvar_,_c_tmp,cfix_,_aptrb_tmp,_aptre_tmp,_asub_tmp,_aval_tmp,_bkc_tmp,_blc_tmp,_buc_tmp,_bkx_tmp,_blx_tmp,_bux_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def isdouparname(self,parname_):
    """
    Checks a double parameter name.
  
    isdouparname(self,parname_)
      parname: str. Parameter name.
    returns: param
      param: mosek.dparam. Which parameter.
    """
    parname_ = parname_.encode("utf-8")
    param_ = ctypes.c_int32()
    res = __library__.MSK_XX_isdouparname(self.__nativep,parname_,ctypes.byref(param_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _param_return_value = dparam(param_.value)
    return (_param_return_value)
  @accepts(_accept_any,_accept_str)
  def isintparname(self,parname_):
    """
    Checks an integer parameter name.
  
    isintparname(self,parname_)
      parname: str. Parameter name.
    returns: param
      param: mosek.iparam. Which parameter.
    """
    parname_ = parname_.encode("utf-8")
    param_ = ctypes.c_int32()
    res = __library__.MSK_XX_isintparname(self.__nativep,parname_,ctypes.byref(param_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _param_return_value = iparam(param_.value)
    return (_param_return_value)
  @accepts(_accept_any,_accept_str)
  def isstrparname(self,parname_):
    """
    Checks a string parameter name.
  
    isstrparname(self,parname_)
      parname: str. Parameter name.
    returns: param
      param: mosek.sparam. Which parameter.
    """
    parname_ = parname_.encode("utf-8")
    param_ = ctypes.c_int32()
    res = __library__.MSK_XX_isstrparname(self.__nativep,parname_,ctypes.byref(param_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _param_return_value = sparam(param_.value)
    return (_param_return_value)
  @accepts(_accept_any,_accept_anyenum(streamtype),_accept_str,_make_int)
  def linkfiletostream(self,whichstream_,filename_,append_):
    """
    Directs all output from a task stream to a file.
  
    linkfiletostream(self,whichstream_,filename_,append_)
      whichstream: mosek.streamtype. Index of the stream.
      filename: str. The name of the file where the stream is written.
      append: int. If this argument is 0 the output file will be overwritten, otherwise text is append to the output file.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_linkfiletotaskstream(self.__nativep,whichstream_,filename_,append_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector)
  def relaxprimal(self,wlc_,wuc_,wlx_,wux_):
    """
    Creates a problem that finds the minimal change to the bounds that makes an infeasible problem feasible.
  
    relaxprimal(self,wlc_,wuc_,wlx_,wux_)
      wlc: array of double. Weights associated with lower bounds on the activity of constraints.
      wuc: array of double. Weights associated with upper bounds on                             the activity of constraints.
      wlx: array of double. Weights associated with lower bounds on                             the activity of variables.
      wux: array of double. Weights associated with upper bounds on                             the activity of variables.
    returns: 
    """
    relaxedtask_ = ctypes.c_void_p()
    relaxedtask_ = ctypes.c_void_p()
    if wlc_ is not None and len(wlc_) < self.getnumcon():
      raise ValueError("Array argument wlc is not long enough")
    if isinstance(wlc_,numpy.ndarray) and not wlc_.flags.writeable:
      raise ValueError("Argument wlc must be writable")
    if isinstance(wlc_, numpy.ndarray) and wlc_.dtype is numpy.float64 and wlc_.flags.contiguous:
      _wlc_copyarray = False
      _wlc_tmp = ctypes.cast(wlc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(wlc_,array.ndarray) and wlc_.dtype is array.float64 and  wlc_.getsteplength() == 1:
      _wlc_copyarray = False
      _wlc_tmp = wlc_.getdatacptr()
    else:
      _wlc_copyarray = True
      _wlc_tmp = (ctypes.c_double * len(wlc_))(*wlc_)
    if wuc_ is not None and len(wuc_) < self.getnumcon():
      raise ValueError("Array argument wuc is not long enough")
    if isinstance(wuc_,numpy.ndarray) and not wuc_.flags.writeable:
      raise ValueError("Argument wuc must be writable")
    if isinstance(wuc_, numpy.ndarray) and wuc_.dtype is numpy.float64 and wuc_.flags.contiguous:
      _wuc_copyarray = False
      _wuc_tmp = ctypes.cast(wuc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(wuc_,array.ndarray) and wuc_.dtype is array.float64 and  wuc_.getsteplength() == 1:
      _wuc_copyarray = False
      _wuc_tmp = wuc_.getdatacptr()
    else:
      _wuc_copyarray = True
      _wuc_tmp = (ctypes.c_double * len(wuc_))(*wuc_)
    if wlx_ is not None and len(wlx_) < self.getnumvar():
      raise ValueError("Array argument wlx is not long enough")
    if isinstance(wlx_,numpy.ndarray) and not wlx_.flags.writeable:
      raise ValueError("Argument wlx must be writable")
    if isinstance(wlx_, numpy.ndarray) and wlx_.dtype is numpy.float64 and wlx_.flags.contiguous:
      _wlx_copyarray = False
      _wlx_tmp = ctypes.cast(wlx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(wlx_,array.ndarray) and wlx_.dtype is array.float64 and  wlx_.getsteplength() == 1:
      _wlx_copyarray = False
      _wlx_tmp = wlx_.getdatacptr()
    else:
      _wlx_copyarray = True
      _wlx_tmp = (ctypes.c_double * len(wlx_))(*wlx_)
    if wux_ is not None and len(wux_) < self.getnumvar():
      raise ValueError("Array argument wux is not long enough")
    if isinstance(wux_,numpy.ndarray) and not wux_.flags.writeable:
      raise ValueError("Argument wux must be writable")
    if isinstance(wux_, numpy.ndarray) and wux_.dtype is numpy.float64 and wux_.flags.contiguous:
      _wux_copyarray = False
      _wux_tmp = ctypes.cast(wux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(wux_,array.ndarray) and wux_.dtype is array.float64 and  wux_.getsteplength() == 1:
      _wux_copyarray = False
      _wux_tmp = wux_.getdatacptr()
    else:
      _wux_copyarray = True
      _wux_tmp = (ctypes.c_double * len(wux_))(*wux_)
    res = __library__.MSK_XX_relaxprimal(self.__nativep,ctypes.byref(relaxedtask_),_wlc_tmp,_wuc_tmp,_wlx_tmp,_wux_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _relaxedtask_return_value = Task(nativep = relaxedtask_.value)
    if _wlc_copyarray:
      wlc_[:] = _wlc_tmp
    if _wuc_copyarray:
      wuc_[:] = _wuc_tmp
    if _wlx_copyarray:
      wlx_[:] = _wlx_tmp
    if _wux_copyarray:
      wux_[:] = _wux_tmp
    return (_relaxedtask_return_value)
  @accepts(_accept_any,_check_taskvector)
  def optimizeconcurrent(self,taskarray_):
    """
    Optimize a given task with several optimizers concurrently.
  
    optimizeconcurrent(self,taskarray_)
      taskarray: array of mosek.Task. An array of tasks.
    """
    if taskarray_ is None:
      raise ValueError("Argument taskarray cannot be None")
    if taskarray_ is None:
      raise ValueError("Argument taskarray may not be None")
    if taskarray_ is None:
      _taskarray_tmp = None
    else:
      _taskarray_tmp = (ctypes.c_void_p * len(taskarray_))(*[ ((i is not None and i.__nativep) or None) for i in taskarray_ ])
    num_ = None
    if num_ is None:
      num_ = len(taskarray_)
    else:
      num_ = min(num_,len(taskarray_))
    res = __library__.MSK_XX_optimizeconcurrent(self.__nativep,_taskarray_tmp,num_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def checkdata(self):
    """
    Checks data of the task.
  
    checkdata(self)
    """
    res = __library__.MSK_XX_checkdata(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_intvector,_accept_intvector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_any,_accept_doublevector,_accept_doublevector,_accept_any,_accept_doublevector,_accept_doublevector,_accept_intvector,_accept_intvector)
  def netextraction(self,netcon_,netvar_,scalcon_,scalvar_,cx_,bkc_,blc_,buc_,bkx_,blx_,bux_,from_,to_):
    """
    Finds embedded network structure.
  
    netextraction(self,netcon_,netvar_,scalcon_,scalvar_,cx_,bkc_,blc_,buc_,bkx_,blx_,bux_,from_,to_)
      netcon: array of int. Indexes of network constraints (nodes) in the embedded network.
      netvar: array of int. Indexes of network variables (arcs) in the embedded network.
      scalcon: array of double. Scaling values on constraints, used to convert the original part of the problem into network form.
      scalvar: array of double. Scaling values on variables, used to convert the original part of the problem into network form.
      cx: array of double. Linear terms of the objective for variables (arcs) in the embedded network as a dense vector.
      bkc: array of mosek.boundkey. Bound keys for the constraints (nodes) in the embedded network.
      blc: array of double. Lower bounds for the constraints (nodes) in the embedded network.
      buc: array of double. Upper bounds for the constraints (nodes) in the embedded network.
      bkx: array of mosek.boundkey. Bound keys for the variables (arcs) in the embedded network.
      blx: array of double. Lower bounds for the variables (arcs) in the embedded network.
      bux: array of double. Upper bounds for the variables (arcs) in the embedded network.
      from: array of int. Defines the origins of the arcs in the embedded network.
      to: array of int. Defines the destinations of the arcs in the embedded network.
    returns: numcon,numvar
      numcon: int. Number of network constraints (nodes) in the embedded network.
      numvar: int. Number of network variables (arcs) in the embedded network.
    """
    numcon_ = ctypes.c_int32()
    numcon_ = ctypes.c_int32()
    numvar_ = ctypes.c_int32()
    numvar_ = ctypes.c_int32()
    if netcon_ is not None and len(netcon_) < self.getnumcon():
      raise ValueError("Array argument netcon is not long enough")
    if isinstance(netcon_,numpy.ndarray) and not netcon_.flags.writeable:
      raise ValueError("Argument netcon must be writable")
    if netcon_ is None:
      raise ValueError("Argument netcon may not be None")
    if isinstance(netcon_, numpy.ndarray) and netcon_.dtype is numpy.int32 and netcon_.flags.contiguous:
      _netcon_copyarray = False
      _netcon_tmp = ctypes.cast(netcon_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(netcon_,array.ndarray) and netcon_.dtype is array.int32 and  netcon_.getsteplength() == 1:
      _netcon_copyarray = False
      _netcon_tmp = netcon_.getdatacptr()
    else:
      _netcon_copyarray = True
      _netcon_tmp = (ctypes.c_int32 * len(netcon_))(*netcon_)
    if netvar_ is not None and len(netvar_) < self.getnumvar():
      raise ValueError("Array argument netvar is not long enough")
    if isinstance(netvar_,numpy.ndarray) and not netvar_.flags.writeable:
      raise ValueError("Argument netvar must be writable")
    if netvar_ is None:
      raise ValueError("Argument netvar may not be None")
    if isinstance(netvar_, numpy.ndarray) and netvar_.dtype is numpy.int32 and netvar_.flags.contiguous:
      _netvar_copyarray = False
      _netvar_tmp = ctypes.cast(netvar_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(netvar_,array.ndarray) and netvar_.dtype is array.int32 and  netvar_.getsteplength() == 1:
      _netvar_copyarray = False
      _netvar_tmp = netvar_.getdatacptr()
    else:
      _netvar_copyarray = True
      _netvar_tmp = (ctypes.c_int32 * len(netvar_))(*netvar_)
    if scalcon_ is not None and len(scalcon_) < self.getnumcon():
      raise ValueError("Array argument scalcon is not long enough")
    if isinstance(scalcon_,numpy.ndarray) and not scalcon_.flags.writeable:
      raise ValueError("Argument scalcon must be writable")
    if scalcon_ is None:
      raise ValueError("Argument scalcon may not be None")
    if isinstance(scalcon_, numpy.ndarray) and scalcon_.dtype is numpy.float64 and scalcon_.flags.contiguous:
      _scalcon_copyarray = False
      _scalcon_tmp = ctypes.cast(scalcon_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(scalcon_,array.ndarray) and scalcon_.dtype is array.float64 and  scalcon_.getsteplength() == 1:
      _scalcon_copyarray = False
      _scalcon_tmp = scalcon_.getdatacptr()
    else:
      _scalcon_copyarray = True
      _scalcon_tmp = (ctypes.c_double * len(scalcon_))(*scalcon_)
    if scalvar_ is not None and len(scalvar_) < self.getnumvar():
      raise ValueError("Array argument scalvar is not long enough")
    if isinstance(scalvar_,numpy.ndarray) and not scalvar_.flags.writeable:
      raise ValueError("Argument scalvar must be writable")
    if scalvar_ is None:
      raise ValueError("Argument scalvar may not be None")
    if isinstance(scalvar_, numpy.ndarray) and scalvar_.dtype is numpy.float64 and scalvar_.flags.contiguous:
      _scalvar_copyarray = False
      _scalvar_tmp = ctypes.cast(scalvar_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(scalvar_,array.ndarray) and scalvar_.dtype is array.float64 and  scalvar_.getsteplength() == 1:
      _scalvar_copyarray = False
      _scalvar_tmp = scalvar_.getdatacptr()
    else:
      _scalvar_copyarray = True
      _scalvar_tmp = (ctypes.c_double * len(scalvar_))(*scalvar_)
    if cx_ is not None and len(cx_) < self.getnumvar():
      raise ValueError("Array argument cx is not long enough")
    if isinstance(cx_,numpy.ndarray) and not cx_.flags.writeable:
      raise ValueError("Argument cx must be writable")
    if cx_ is None:
      raise ValueError("Argument cx may not be None")
    if isinstance(cx_, numpy.ndarray) and cx_.dtype is numpy.float64 and cx_.flags.contiguous:
      _cx_copyarray = False
      _cx_tmp = ctypes.cast(cx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(cx_,array.ndarray) and cx_.dtype is array.float64 and  cx_.getsteplength() == 1:
      _cx_copyarray = False
      _cx_tmp = cx_.getdatacptr()
    else:
      _cx_copyarray = True
      _cx_tmp = (ctypes.c_double * len(cx_))(*cx_)
    if bkc_ is not None and len(bkc_) < self.getnumcon():
      raise ValueError("Array argument bkc is not long enough")
    if isinstance(bkc_,numpy.ndarray) and not bkc_.flags.writeable:
      raise ValueError("Argument bkc must be writable")
    if bkc_ is None:
      raise ValueError("Argument bkc may not be None")
    if bkc_ is not None:
        _bkc_tmp_arr = array.zeros(len(bkc_),array.int32)
        _bkc_tmp = _bkc_tmp_arr.getdatacptr()
    else:
        _bkc_tmp_arr = None
        _bkc_tmp = None
    if blc_ is not None and len(blc_) < self.getnumcon():
      raise ValueError("Array argument blc is not long enough")
    if isinstance(blc_,numpy.ndarray) and not blc_.flags.writeable:
      raise ValueError("Argument blc must be writable")
    if blc_ is None:
      raise ValueError("Argument blc may not be None")
    if isinstance(blc_, numpy.ndarray) and blc_.dtype is numpy.float64 and blc_.flags.contiguous:
      _blc_copyarray = False
      _blc_tmp = ctypes.cast(blc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blc_,array.ndarray) and blc_.dtype is array.float64 and  blc_.getsteplength() == 1:
      _blc_copyarray = False
      _blc_tmp = blc_.getdatacptr()
    else:
      _blc_copyarray = True
      _blc_tmp = (ctypes.c_double * len(blc_))(*blc_)
    if buc_ is not None and len(buc_) < self.getnumcon():
      raise ValueError("Array argument buc is not long enough")
    if isinstance(buc_,numpy.ndarray) and not buc_.flags.writeable:
      raise ValueError("Argument buc must be writable")
    if buc_ is None:
      raise ValueError("Argument buc may not be None")
    if isinstance(buc_, numpy.ndarray) and buc_.dtype is numpy.float64 and buc_.flags.contiguous:
      _buc_copyarray = False
      _buc_tmp = ctypes.cast(buc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(buc_,array.ndarray) and buc_.dtype is array.float64 and  buc_.getsteplength() == 1:
      _buc_copyarray = False
      _buc_tmp = buc_.getdatacptr()
    else:
      _buc_copyarray = True
      _buc_tmp = (ctypes.c_double * len(buc_))(*buc_)
    if bkx_ is not None and len(bkx_) < self.getnumvar():
      raise ValueError("Array argument bkx is not long enough")
    if isinstance(bkx_,numpy.ndarray) and not bkx_.flags.writeable:
      raise ValueError("Argument bkx must be writable")
    if bkx_ is None:
      raise ValueError("Argument bkx may not be None")
    if bkx_ is not None:
        _bkx_tmp_arr = array.zeros(len(bkx_),array.int32)
        _bkx_tmp = _bkx_tmp_arr.getdatacptr()
    else:
        _bkx_tmp_arr = None
        _bkx_tmp = None
    if blx_ is not None and len(blx_) < self.getnumvar():
      raise ValueError("Array argument blx is not long enough")
    if isinstance(blx_,numpy.ndarray) and not blx_.flags.writeable:
      raise ValueError("Argument blx must be writable")
    if blx_ is None:
      raise ValueError("Argument blx may not be None")
    if isinstance(blx_, numpy.ndarray) and blx_.dtype is numpy.float64 and blx_.flags.contiguous:
      _blx_copyarray = False
      _blx_tmp = ctypes.cast(blx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blx_,array.ndarray) and blx_.dtype is array.float64 and  blx_.getsteplength() == 1:
      _blx_copyarray = False
      _blx_tmp = blx_.getdatacptr()
    else:
      _blx_copyarray = True
      _blx_tmp = (ctypes.c_double * len(blx_))(*blx_)
    if bux_ is not None and len(bux_) < self.getnumvar():
      raise ValueError("Array argument bux is not long enough")
    if isinstance(bux_,numpy.ndarray) and not bux_.flags.writeable:
      raise ValueError("Argument bux must be writable")
    if bux_ is None:
      raise ValueError("Argument bux may not be None")
    if isinstance(bux_, numpy.ndarray) and bux_.dtype is numpy.float64 and bux_.flags.contiguous:
      _bux_copyarray = False
      _bux_tmp = ctypes.cast(bux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bux_,array.ndarray) and bux_.dtype is array.float64 and  bux_.getsteplength() == 1:
      _bux_copyarray = False
      _bux_tmp = bux_.getdatacptr()
    else:
      _bux_copyarray = True
      _bux_tmp = (ctypes.c_double * len(bux_))(*bux_)
    if from_ is not None and len(from_) < self.getnumvar():
      raise ValueError("Array argument from is not long enough")
    if isinstance(from_,numpy.ndarray) and not from_.flags.writeable:
      raise ValueError("Argument from must be writable")
    if from_ is None:
      raise ValueError("Argument from may not be None")
    if isinstance(from_, numpy.ndarray) and from_.dtype is numpy.int32 and from_.flags.contiguous:
      _from_copyarray = False
      _from_tmp = ctypes.cast(from_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(from_,array.ndarray) and from_.dtype is array.int32 and  from_.getsteplength() == 1:
      _from_copyarray = False
      _from_tmp = from_.getdatacptr()
    else:
      _from_copyarray = True
      _from_tmp = (ctypes.c_int32 * len(from_))(*from_)
    if to_ is not None and len(to_) < self.getnumvar():
      raise ValueError("Array argument to is not long enough")
    if isinstance(to_,numpy.ndarray) and not to_.flags.writeable:
      raise ValueError("Argument to must be writable")
    if to_ is None:
      raise ValueError("Argument to may not be None")
    if isinstance(to_, numpy.ndarray) and to_.dtype is numpy.int32 and to_.flags.contiguous:
      _to_copyarray = False
      _to_tmp = ctypes.cast(to_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(to_,array.ndarray) and to_.dtype is array.int32 and  to_.getsteplength() == 1:
      _to_copyarray = False
      _to_tmp = to_.getdatacptr()
    else:
      _to_copyarray = True
      _to_tmp = (ctypes.c_int32 * len(to_))(*to_)
    res = __library__.MSK_XX_netextraction(self.__nativep,ctypes.byref(numcon_),ctypes.byref(numvar_),_netcon_tmp,_netvar_tmp,_scalcon_tmp,_scalvar_tmp,_cx_tmp,_bkc_tmp,_blc_tmp,_buc_tmp,_bkx_tmp,_blx_tmp,_bux_tmp,_from_tmp,_to_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _numcon_return_value = numcon_.value
    _numvar_return_value = numvar_.value
    if _netcon_copyarray:
      netcon_[:] = _netcon_tmp
    if _netvar_copyarray:
      netvar_[:] = _netvar_tmp
    if _scalcon_copyarray:
      scalcon_[:] = _scalcon_tmp
    if _scalvar_copyarray:
      scalvar_[:] = _scalvar_tmp
    if _cx_copyarray:
      cx_[:] = _cx_tmp
    if bkc_ is not None: bkc_[:] = [ boundkey(v) for v in _bkc_tmp[0:len(bkc_)] ]
    if _blc_copyarray:
      blc_[:] = _blc_tmp
    if _buc_copyarray:
      buc_[:] = _buc_tmp
    if bkx_ is not None: bkx_[:] = [ boundkey(v) for v in _bkx_tmp[0:len(bkx_)] ]
    if _blx_copyarray:
      blx_[:] = _blx_tmp
    if _bux_copyarray:
      bux_[:] = _bux_tmp
    if _from_copyarray:
      from_[:] = _from_tmp
    if _to_copyarray:
      to_[:] = _to_tmp
    return (_numcon_return_value,_numvar_return_value)
  @accepts(_accept_any,_make_doublevector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector,_make_intvector,_make_intvector,_make_int,_accept_any,_accept_any,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector)
  def netoptimize(self,cc_,cx_,bkc_,blc_,buc_,bkx_,blx_,bux_,from_,to_,hotstart_,skc_,skx_,xc_,xx_,y_,slc_,suc_,slx_,sux_):
    """
    Optimizes a pure network flow problem.
  
    netoptimize(self,cc_,cx_,bkc_,blc_,buc_,bkx_,blx_,bux_,from_,to_,hotstart_,skc_,skx_,xc_,xx_,y_,slc_,suc_,slx_,sux_)
      cc: array of double. Linear terms of the objective for constraints (nodes) as a dense vector.
      cx: array of double. Linear terms of the objective for variables (arcs) as a dense vector.
      bkc: array of mosek.boundkey. Bound keys for the constraints (nodes).
      blc: array of double. Lower bounds for the constraints (nodes).
      buc: array of double. Upper bounds for the constraints (nodes).
      bkx: array of mosek.boundkey. Bound keys for the variables (arcs).
      blx: array of double. Lower bounds for the variables (arcs).
      bux: array of double. Upper bounds for the variables (arcs).
      from: array of int. Defines the origins of the arcs in the network.
      to: array of int. Defines the destinations of the arcs in the network.
      hotstart: int. If zero the network optimizer will not use hot-starts, if non-zero a solution must be defined in the solution  	                        variables below, which will be used to hot-start the network optimizer.
      skc: array of mosek.stakey. Status keys for the constraints (nodes).
      skx: array of mosek.stakey. Status keys for the variables (arcs).
      xc: array of double. Primal constraint solution (nodes).
      xx: array of double. Primal variable solution (arcs).
      y: array of double. Vector of dual variables corresponding to the constraints (nodes).
      slc: array of double. Dual variables corresponding to the lower bounds on the constraints (nodes).
      suc: array of double. Dual variables corresponding to the upper bounds on the constraints (nodes).
      slx: array of double. Dual variables corresponding to the lower bounds on the constraints (arcs).
      sux: array of double. Dual variables corresponding to the upper bounds on the constraints (arcs).
    returns: prosta,solsta
      prosta: mosek.prosta. Problem status.
      solsta: mosek.solsta. Solution status.
    """
    numcon_ = None
    if numcon_ is None:
      numcon_ = len(bkc_)
    else:
      numcon_ = min(numcon_,len(bkc_))
    if numcon_ is None:
      numcon_ = len(blc_)
    else:
      numcon_ = min(numcon_,len(blc_))
    if numcon_ is None:
      numcon_ = len(buc_)
    else:
      numcon_ = min(numcon_,len(buc_))
    if numcon_ is None:
      numcon_ = len(cc_)
    else:
      numcon_ = min(numcon_,len(cc_))
    if numcon_ is None:
      numcon_ = len(skc_)
    else:
      numcon_ = min(numcon_,len(skc_))
    if numcon_ is None:
      numcon_ = len(xc_)
    else:
      numcon_ = min(numcon_,len(xc_))
    if numcon_ is None:
      numcon_ = len(y_)
    else:
      numcon_ = min(numcon_,len(y_))
    if numcon_ is None:
      numcon_ = len(slc_)
    else:
      numcon_ = min(numcon_,len(slc_))
    if numcon_ is None:
      numcon_ = len(suc_)
    else:
      numcon_ = min(numcon_,len(suc_))
    numvar_ = None
    if numvar_ is None:
      numvar_ = len(bkx_)
    else:
      numvar_ = min(numvar_,len(bkx_))
    if numvar_ is None:
      numvar_ = len(blx_)
    else:
      numvar_ = min(numvar_,len(blx_))
    if numvar_ is None:
      numvar_ = len(bux_)
    else:
      numvar_ = min(numvar_,len(bux_))
    if numvar_ is None:
      numvar_ = len(cx_)
    else:
      numvar_ = min(numvar_,len(cx_))
    if numvar_ is None:
      numvar_ = len(from_)
    else:
      numvar_ = min(numvar_,len(from_))
    if numvar_ is None:
      numvar_ = len(to_)
    else:
      numvar_ = min(numvar_,len(to_))
    if numvar_ is None:
      numvar_ = len(skx_)
    else:
      numvar_ = min(numvar_,len(skx_))
    if numvar_ is None:
      numvar_ = len(xx_)
    else:
      numvar_ = min(numvar_,len(xx_))
    if numvar_ is None:
      numvar_ = len(slx_)
    else:
      numvar_ = min(numvar_,len(slx_))
    if numvar_ is None:
      numvar_ = len(sux_)
    else:
      numvar_ = min(numvar_,len(sux_))
    if cc_ is None:
      raise ValueError("Argument cc cannot be None")
    if cc_ is None:
      raise ValueError("Argument cc may not be None")
    if isinstance(cc_, numpy.ndarray) and cc_.dtype is numpy.float64 and cc_.flags.contiguous:
      _cc_copyarray = False
      _cc_tmp = ctypes.cast(cc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(cc_,array.ndarray) and cc_.dtype is array.float64 and  cc_.getsteplength() == 1:
      _cc_copyarray = False
      _cc_tmp = cc_.getdatacptr()
    else:
      _cc_copyarray = True
      _cc_tmp = (ctypes.c_double * len(cc_))(*cc_)
    if cx_ is None:
      raise ValueError("Argument cx cannot be None")
    if cx_ is None:
      raise ValueError("Argument cx may not be None")
    if isinstance(cx_, numpy.ndarray) and cx_.dtype is numpy.float64 and cx_.flags.contiguous:
      _cx_copyarray = False
      _cx_tmp = ctypes.cast(cx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(cx_,array.ndarray) and cx_.dtype is array.float64 and  cx_.getsteplength() == 1:
      _cx_copyarray = False
      _cx_tmp = cx_.getdatacptr()
    else:
      _cx_copyarray = True
      _cx_tmp = (ctypes.c_double * len(cx_))(*cx_)
    if bkc_ is None:
      raise ValueError("Argument bkc cannot be None")
    if bkc_ is None:
      raise ValueError("Argument bkc may not be None")
    _bkc_tmp_arr = array.array(bkc_,array.int32)
    _bkc_tmp = _bkc_tmp_arr.getdatacptr()
    if blc_ is None:
      raise ValueError("Argument blc cannot be None")
    if blc_ is None:
      raise ValueError("Argument blc may not be None")
    if isinstance(blc_, numpy.ndarray) and blc_.dtype is numpy.float64 and blc_.flags.contiguous:
      _blc_copyarray = False
      _blc_tmp = ctypes.cast(blc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blc_,array.ndarray) and blc_.dtype is array.float64 and  blc_.getsteplength() == 1:
      _blc_copyarray = False
      _blc_tmp = blc_.getdatacptr()
    else:
      _blc_copyarray = True
      _blc_tmp = (ctypes.c_double * len(blc_))(*blc_)
    if buc_ is None:
      raise ValueError("Argument buc cannot be None")
    if buc_ is None:
      raise ValueError("Argument buc may not be None")
    if isinstance(buc_, numpy.ndarray) and buc_.dtype is numpy.float64 and buc_.flags.contiguous:
      _buc_copyarray = False
      _buc_tmp = ctypes.cast(buc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(buc_,array.ndarray) and buc_.dtype is array.float64 and  buc_.getsteplength() == 1:
      _buc_copyarray = False
      _buc_tmp = buc_.getdatacptr()
    else:
      _buc_copyarray = True
      _buc_tmp = (ctypes.c_double * len(buc_))(*buc_)
    if bkx_ is None:
      raise ValueError("Argument bkx cannot be None")
    if bkx_ is None:
      raise ValueError("Argument bkx may not be None")
    _bkx_tmp_arr = array.array(bkx_,array.int32)
    _bkx_tmp = _bkx_tmp_arr.getdatacptr()
    if blx_ is None:
      raise ValueError("Argument blx cannot be None")
    if blx_ is None:
      raise ValueError("Argument blx may not be None")
    if isinstance(blx_, numpy.ndarray) and blx_.dtype is numpy.float64 and blx_.flags.contiguous:
      _blx_copyarray = False
      _blx_tmp = ctypes.cast(blx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blx_,array.ndarray) and blx_.dtype is array.float64 and  blx_.getsteplength() == 1:
      _blx_copyarray = False
      _blx_tmp = blx_.getdatacptr()
    else:
      _blx_copyarray = True
      _blx_tmp = (ctypes.c_double * len(blx_))(*blx_)
    if bux_ is None:
      raise ValueError("Argument bux cannot be None")
    if bux_ is None:
      raise ValueError("Argument bux may not be None")
    if isinstance(bux_, numpy.ndarray) and bux_.dtype is numpy.float64 and bux_.flags.contiguous:
      _bux_copyarray = False
      _bux_tmp = ctypes.cast(bux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bux_,array.ndarray) and bux_.dtype is array.float64 and  bux_.getsteplength() == 1:
      _bux_copyarray = False
      _bux_tmp = bux_.getdatacptr()
    else:
      _bux_copyarray = True
      _bux_tmp = (ctypes.c_double * len(bux_))(*bux_)
    if from_ is None:
      raise ValueError("Argument from cannot be None")
    if from_ is None:
      raise ValueError("Argument from may not be None")
    if isinstance(from_, numpy.ndarray) and from_.dtype is numpy.int32 and from_.flags.contiguous:
      _from_copyarray = False
      _from_tmp = ctypes.cast(from_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(from_,array.ndarray) and from_.dtype is array.int32 and  from_.getsteplength() == 1:
      _from_copyarray = False
      _from_tmp = from_.getdatacptr()
    else:
      _from_copyarray = True
      _from_tmp = (ctypes.c_int32 * len(from_))(*from_)
    if to_ is None:
      raise ValueError("Argument to cannot be None")
    if to_ is None:
      raise ValueError("Argument to may not be None")
    if isinstance(to_, numpy.ndarray) and to_.dtype is numpy.int32 and to_.flags.contiguous:
      _to_copyarray = False
      _to_tmp = ctypes.cast(to_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(to_,array.ndarray) and to_.dtype is array.int32 and  to_.getsteplength() == 1:
      _to_copyarray = False
      _to_tmp = to_.getdatacptr()
    else:
      _to_copyarray = True
      _to_tmp = (ctypes.c_int32 * len(to_))(*to_)
    prosta_ = ctypes.c_int32()
    solsta_ = ctypes.c_int32()
    if skc_ is not None and len(skc_) < numcon_:
      raise ValueError("Array argument skc is not long enough")
    if isinstance(skc_,numpy.ndarray) and not skc_.flags.writeable:
      raise ValueError("Argument skc must be writable")
    if skc_ is None:
      raise ValueError("Argument skc may not be None")
    _skc_tmp_arr = array.array(skc_,array.int32)
    _skc_tmp = _skc_tmp_arr.getdatacptr()
    if skx_ is not None and len(skx_) < numvar_:
      raise ValueError("Array argument skx is not long enough")
    if isinstance(skx_,numpy.ndarray) and not skx_.flags.writeable:
      raise ValueError("Argument skx must be writable")
    if skx_ is None:
      raise ValueError("Argument skx may not be None")
    _skx_tmp_arr = array.array(skx_,array.int32)
    _skx_tmp = _skx_tmp_arr.getdatacptr()
    if xc_ is not None and len(xc_) < numcon_:
      raise ValueError("Array argument xc is not long enough")
    if isinstance(xc_,numpy.ndarray) and not xc_.flags.writeable:
      raise ValueError("Argument xc must be writable")
    if xc_ is None:
      raise ValueError("Argument xc may not be None")
    if isinstance(xc_, numpy.ndarray) and xc_.dtype is numpy.float64 and xc_.flags.contiguous:
      _xc_copyarray = False
      _xc_tmp = ctypes.cast(xc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xc_,array.ndarray) and xc_.dtype is array.float64 and  xc_.getsteplength() == 1:
      _xc_copyarray = False
      _xc_tmp = xc_.getdatacptr()
    else:
      _xc_copyarray = True
      _xc_tmp = (ctypes.c_double * len(xc_))(*xc_)
    if xx_ is not None and len(xx_) < numvar_:
      raise ValueError("Array argument xx is not long enough")
    if isinstance(xx_,numpy.ndarray) and not xx_.flags.writeable:
      raise ValueError("Argument xx must be writable")
    if xx_ is None:
      raise ValueError("Argument xx may not be None")
    if isinstance(xx_, numpy.ndarray) and xx_.dtype is numpy.float64 and xx_.flags.contiguous:
      _xx_copyarray = False
      _xx_tmp = ctypes.cast(xx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xx_,array.ndarray) and xx_.dtype is array.float64 and  xx_.getsteplength() == 1:
      _xx_copyarray = False
      _xx_tmp = xx_.getdatacptr()
    else:
      _xx_copyarray = True
      _xx_tmp = (ctypes.c_double * len(xx_))(*xx_)
    if y_ is not None and len(y_) < numcon_:
      raise ValueError("Array argument y is not long enough")
    if isinstance(y_,numpy.ndarray) and not y_.flags.writeable:
      raise ValueError("Argument y must be writable")
    if y_ is None:
      raise ValueError("Argument y may not be None")
    if isinstance(y_, numpy.ndarray) and y_.dtype is numpy.float64 and y_.flags.contiguous:
      _y_copyarray = False
      _y_tmp = ctypes.cast(y_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(y_,array.ndarray) and y_.dtype is array.float64 and  y_.getsteplength() == 1:
      _y_copyarray = False
      _y_tmp = y_.getdatacptr()
    else:
      _y_copyarray = True
      _y_tmp = (ctypes.c_double * len(y_))(*y_)
    if slc_ is not None and len(slc_) < numcon_:
      raise ValueError("Array argument slc is not long enough")
    if isinstance(slc_,numpy.ndarray) and not slc_.flags.writeable:
      raise ValueError("Argument slc must be writable")
    if slc_ is None:
      raise ValueError("Argument slc may not be None")
    if isinstance(slc_, numpy.ndarray) and slc_.dtype is numpy.float64 and slc_.flags.contiguous:
      _slc_copyarray = False
      _slc_tmp = ctypes.cast(slc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slc_,array.ndarray) and slc_.dtype is array.float64 and  slc_.getsteplength() == 1:
      _slc_copyarray = False
      _slc_tmp = slc_.getdatacptr()
    else:
      _slc_copyarray = True
      _slc_tmp = (ctypes.c_double * len(slc_))(*slc_)
    if suc_ is not None and len(suc_) < numcon_:
      raise ValueError("Array argument suc is not long enough")
    if isinstance(suc_,numpy.ndarray) and not suc_.flags.writeable:
      raise ValueError("Argument suc must be writable")
    if suc_ is None:
      raise ValueError("Argument suc may not be None")
    if isinstance(suc_, numpy.ndarray) and suc_.dtype is numpy.float64 and suc_.flags.contiguous:
      _suc_copyarray = False
      _suc_tmp = ctypes.cast(suc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(suc_,array.ndarray) and suc_.dtype is array.float64 and  suc_.getsteplength() == 1:
      _suc_copyarray = False
      _suc_tmp = suc_.getdatacptr()
    else:
      _suc_copyarray = True
      _suc_tmp = (ctypes.c_double * len(suc_))(*suc_)
    if slx_ is not None and len(slx_) < numvar_:
      raise ValueError("Array argument slx is not long enough")
    if isinstance(slx_,numpy.ndarray) and not slx_.flags.writeable:
      raise ValueError("Argument slx must be writable")
    if slx_ is None:
      raise ValueError("Argument slx may not be None")
    if isinstance(slx_, numpy.ndarray) and slx_.dtype is numpy.float64 and slx_.flags.contiguous:
      _slx_copyarray = False
      _slx_tmp = ctypes.cast(slx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slx_,array.ndarray) and slx_.dtype is array.float64 and  slx_.getsteplength() == 1:
      _slx_copyarray = False
      _slx_tmp = slx_.getdatacptr()
    else:
      _slx_copyarray = True
      _slx_tmp = (ctypes.c_double * len(slx_))(*slx_)
    if sux_ is not None and len(sux_) < numvar_:
      raise ValueError("Array argument sux is not long enough")
    if isinstance(sux_,numpy.ndarray) and not sux_.flags.writeable:
      raise ValueError("Argument sux must be writable")
    if sux_ is None:
      raise ValueError("Argument sux may not be None")
    if isinstance(sux_, numpy.ndarray) and sux_.dtype is numpy.float64 and sux_.flags.contiguous:
      _sux_copyarray = False
      _sux_tmp = ctypes.cast(sux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(sux_,array.ndarray) and sux_.dtype is array.float64 and  sux_.getsteplength() == 1:
      _sux_copyarray = False
      _sux_tmp = sux_.getdatacptr()
    else:
      _sux_copyarray = True
      _sux_tmp = (ctypes.c_double * len(sux_))(*sux_)
    res = __library__.MSK_XX_netoptimize(self.__nativep,numcon_,numvar_,_cc_tmp,_cx_tmp,_bkc_tmp,_blc_tmp,_buc_tmp,_bkx_tmp,_blx_tmp,_bux_tmp,_from_tmp,_to_tmp,ctypes.byref(prosta_),ctypes.byref(solsta_),hotstart_,_skc_tmp,_skx_tmp,_xc_tmp,_xx_tmp,_y_tmp,_slc_tmp,_suc_tmp,_slx_tmp,_sux_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _prosta_return_value = prosta(prosta_.value)
    _solsta_return_value = solsta(solsta_.value)
    if skc_ is not None: skc_[:] = [ stakey(v) for v in _skc_tmp[0:len(skc_)] ]
    if skx_ is not None: skx_[:] = [ stakey(v) for v in _skx_tmp[0:len(skx_)] ]
    if _xc_copyarray:
      xc_[:] = _xc_tmp
    if _xx_copyarray:
      xx_[:] = _xx_tmp
    if _y_copyarray:
      y_[:] = _y_tmp
    if _slc_copyarray:
      slc_[:] = _slc_tmp
    if _suc_copyarray:
      suc_[:] = _suc_tmp
    if _slx_copyarray:
      slx_[:] = _slx_tmp
    if _sux_copyarray:
      sux_[:] = _sux_tmp
    return (_prosta_return_value,_solsta_return_value)
  @accepts(_accept_any)
  def optimize(self):
    """
    Optimizes the problem.
  
    optimize(self)
    returns: trmcode
      trmcode: mosek.rescode. Is either OK or a termination response code.
    """
    trmcode_ = ctypes.c_int32()
    res = __library__.MSK_XX_optimizetrm(self.__nativep,ctypes.byref(trmcode_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _trmcode_return_value = rescode(trmcode_.value)
    return (_trmcode_return_value)
  @accepts(_accept_any,_accept_anyenum(streamtype),_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int,_make_int)
  def printdata(self,whichstream_,firsti_,lasti_,firstj_,lastj_,firstk_,lastk_,c_,qo_,a_,qc_,bc_,bx_,vartype_,cones_):
    """
    Prints a part of the problem data to a stream.
  
    printdata(self,whichstream_,firsti_,lasti_,firstj_,lastj_,firstk_,lastk_,c_,qo_,a_,qc_,bc_,bx_,vartype_,cones_)
      whichstream: mosek.streamtype. Index of the stream.
      firsti: int. Index of first constraint for which data should be printed.
      lasti: int. Index of last constraint plus 1 for which data should be printed.
      firstj: int. Index of first variable for which data should be printed.
      lastj: int. Index of last variable plus 1 for which data should be printed.
      firstk: int. Index of first cone for which data should be printed.
      lastk: int. Index of last cone plus 1 for which data should be printed.
      c: int. If non-zero the linear objective terms are printed.
      qo: int. If non-zero the quadratic objective terms are printed.
      a: int. If non-zero the linear constraint matrix is printed.
      qc: int. If non-zero qthe quafratic constraint terms are printed for the relevant constraints.
      bc: int. If non-zero the constraints bounds are printed.
      bx: int. If non-zero the variable bounds are printed.
      vartype: int. If non-zero the variable types are printed.
      cones: int. If non-zero the  conic data is printed.
    """
    res = __library__.MSK_XX_printdata(self.__nativep,whichstream_,firsti_,lasti_,firstj_,lastj_,firstk_,lastk_,c_,qo_,a_,qc_,bc_,bx_,vartype_,cones_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def printparam(self):
    """
    Prints the current parameter settings.
  
    printparam(self)
    """
    res = __library__.MSK_XX_printparam(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def commitchanges(self):
    """
    Commits all cached problem changes.
  
    commitchanges(self)
    """
    res = __library__.MSK_XX_commitchanges(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_int,_make_double)
  def putaij(self,i_,j_,aij_):
    """
    Changes a single value in the linear coefficient matrix.
  
    putaij(self,i_,j_,aij_)
      i: int. Index of the constraint in which the change should occur.
      j: int. Index of the variable in which the change should occur.
      aij: double. New coefficient.
    """
    res = __library__.MSK_XX_putaij(self.__nativep,i_,j_,aij_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_intvector,_make_doublevector)
  def putaijlist(self,subi_,subj_,valij_):
    """
    Changes one or more coefficients in the linear constraint matrix.
  
    putaijlist(self,subi_,subj_,valij_)
      subi: array of int. Constraint indexes in which the change should occur.
      subj: array of int. Variable indexes in which the change should occur.
      valij: array of double. New coefficient values.
    """
    num_ = None
    if num_ is None:
      num_ = len(subi_)
    else:
      num_ = min(num_,len(subi_))
    if num_ is None:
      num_ = len(subj_)
    else:
      num_ = min(num_,len(subj_))
    if num_ is None:
      num_ = len(valij_)
    else:
      num_ = min(num_,len(valij_))
    if subi_ is None:
      raise ValueError("Argument subi cannot be None")
    if subi_ is None:
      raise ValueError("Argument subi may not be None")
    if isinstance(subi_, numpy.ndarray) and subi_.dtype is numpy.int32 and subi_.flags.contiguous:
      _subi_copyarray = False
      _subi_tmp = ctypes.cast(subi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subi_,array.ndarray) and subi_.dtype is array.int32 and  subi_.getsteplength() == 1:
      _subi_copyarray = False
      _subi_tmp = subi_.getdatacptr()
    else:
      _subi_copyarray = True
      _subi_tmp = (ctypes.c_int32 * len(subi_))(*subi_)
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if valij_ is None:
      raise ValueError("Argument valij cannot be None")
    if valij_ is None:
      raise ValueError("Argument valij may not be None")
    if isinstance(valij_, numpy.ndarray) and valij_.dtype is numpy.float64 and valij_.flags.contiguous:
      _valij_copyarray = False
      _valij_tmp = ctypes.cast(valij_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(valij_,array.ndarray) and valij_.dtype is array.float64 and  valij_.getsteplength() == 1:
      _valij_copyarray = False
      _valij_tmp = valij_.getdatacptr()
    else:
      _valij_copyarray = True
      _valij_tmp = (ctypes.c_double * len(valij_))(*valij_)
    res = __library__.MSK_XX_putaijlist(self.__nativep,num_,_subi_tmp,_subj_tmp,_valij_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_make_intvector,_make_doublevector)
  def putavec(self,accmode_,i_,asub_,aval_):
    """
    Replaces all elements in one row or column of the linear coefficient matrix.
  
    putavec(self,accmode_,i_,asub_,aval_)
      accmode: mosek.accmode. Defines whether to replace a column or a row.
      i: int. The index of the constrint or row to modify.
      asub: array of int. Subscripts of the new row or column elements.
      aval: array of double. Coefficients of the new row or column elements.
    """
    nzi_ = None
    if nzi_ is None:
      nzi_ = len(asub_)
    else:
      nzi_ = min(nzi_,len(asub_))
    if nzi_ is None:
      nzi_ = len(aval_)
    else:
      nzi_ = min(nzi_,len(aval_))
    if asub_ is None:
      raise ValueError("Argument asub cannot be None")
    if asub_ is None:
      raise ValueError("Argument asub may not be None")
    if isinstance(asub_, numpy.ndarray) and asub_.dtype is numpy.int32 and asub_.flags.contiguous:
      _asub_copyarray = False
      _asub_tmp = ctypes.cast(asub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(asub_,array.ndarray) and asub_.dtype is array.int32 and  asub_.getsteplength() == 1:
      _asub_copyarray = False
      _asub_tmp = asub_.getdatacptr()
    else:
      _asub_copyarray = True
      _asub_tmp = (ctypes.c_int32 * len(asub_))(*asub_)
    if aval_ is None:
      raise ValueError("Argument aval cannot be None")
    if aval_ is None:
      raise ValueError("Argument aval may not be None")
    if isinstance(aval_, numpy.ndarray) and aval_.dtype is numpy.float64 and aval_.flags.contiguous:
      _aval_copyarray = False
      _aval_tmp = ctypes.cast(aval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(aval_,array.ndarray) and aval_.dtype is array.float64 and  aval_.getsteplength() == 1:
      _aval_copyarray = False
      _aval_tmp = aval_.getdatacptr()
    else:
      _aval_copyarray = True
      _aval_tmp = (ctypes.c_double * len(aval_))(*aval_)
    res = __library__.MSK_XX_putavec(self.__nativep,accmode_,i_,nzi_,_asub_tmp,_aval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_intvector,_make_longvector,_make_longvector,_make_intvector,_make_doublevector)
  def putaveclist(self,accmode_,sub_,ptrb_,ptre_,asub_,aval_):
    """
    Replaces all elements in one or more rows or columns in the linear constraint matrix by new values.
  
    putaveclist(self,accmode_,sub_,ptrb_,ptre_,asub_,aval_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      sub: array of int. Indexes of rows or columns that should be replaced.
      ptrb: array of long. Array of pointers to the first element in the rows or columns.
      ptre: array of long. Array of pointers to the last element plus one in the rows or columns.
      asub: array of int. Variable or constraint indexes.
      aval: array of double. Coefficient coefficient values.
    """
    num_ = None
    if num_ is None:
      num_ = len(sub_)
    else:
      num_ = min(num_,len(sub_))
    if num_ is None:
      num_ = len(ptrb_)
    else:
      num_ = min(num_,len(ptrb_))
    if num_ is None:
      num_ = len(ptre_)
    else:
      num_ = min(num_,len(ptre_))
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    if ptrb_ is None:
      raise ValueError("Argument ptrb cannot be None")
    if ptrb_ is None:
      raise ValueError("Argument ptrb may not be None")
    if isinstance(ptrb_, numpy.ndarray) and ptrb_.dtype is numpy.int64 and ptrb_.flags.contiguous:
      _ptrb_copyarray = False
      _ptrb_tmp = ctypes.cast(ptrb_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(ptrb_,array.ndarray) and ptrb_.dtype is array.int64 and  ptrb_.getsteplength() == 1:
      _ptrb_copyarray = False
      _ptrb_tmp = ptrb_.getdatacptr()
    else:
      _ptrb_copyarray = True
      _ptrb_tmp = (ctypes.c_int64 * len(ptrb_))(*ptrb_)
    if ptre_ is None:
      raise ValueError("Argument ptre cannot be None")
    if ptre_ is None:
      raise ValueError("Argument ptre may not be None")
    if isinstance(ptre_, numpy.ndarray) and ptre_.dtype is numpy.int64 and ptre_.flags.contiguous:
      _ptre_copyarray = False
      _ptre_tmp = ctypes.cast(ptre_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int64))
    elif isinstance(ptre_,array.ndarray) and ptre_.dtype is array.int64 and  ptre_.getsteplength() == 1:
      _ptre_copyarray = False
      _ptre_tmp = ptre_.getdatacptr()
    else:
      _ptre_copyarray = True
      _ptre_tmp = (ctypes.c_int64 * len(ptre_))(*ptre_)
    if asub_ is None:
      raise ValueError("Argument asub cannot be None")
    if asub_ is None:
      raise ValueError("Argument asub may not be None")
    if isinstance(asub_, numpy.ndarray) and asub_.dtype is numpy.int32 and asub_.flags.contiguous:
      _asub_copyarray = False
      _asub_tmp = ctypes.cast(asub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(asub_,array.ndarray) and asub_.dtype is array.int32 and  asub_.getsteplength() == 1:
      _asub_copyarray = False
      _asub_tmp = asub_.getdatacptr()
    else:
      _asub_copyarray = True
      _asub_tmp = (ctypes.c_int32 * len(asub_))(*asub_)
    if aval_ is None:
      raise ValueError("Argument aval cannot be None")
    if aval_ is None:
      raise ValueError("Argument aval may not be None")
    if isinstance(aval_, numpy.ndarray) and aval_.dtype is numpy.float64 and aval_.flags.contiguous:
      _aval_copyarray = False
      _aval_tmp = ctypes.cast(aval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(aval_,array.ndarray) and aval_.dtype is array.float64 and  aval_.getsteplength() == 1:
      _aval_copyarray = False
      _aval_tmp = aval_.getdatacptr()
    else:
      _aval_copyarray = True
      _aval_tmp = (ctypes.c_double * len(aval_))(*aval_)
    res = __library__.MSK_XX_putaveclist64(self.__nativep,accmode_,num_,_sub_tmp,_ptrb_tmp,_ptre_tmp,_asub_tmp,_aval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_accept_anyenum(boundkey),_make_double,_make_double)
  def putbound(self,accmode_,i_,bk_,bl_,bu_):
    """
    Changes the bound for either one constraint or one variable.
  
    putbound(self,accmode_,i_,bk_,bl_,bu_)
      accmode: mosek.accmode. Defines whether the bound for a constraint or a variable is changed.
      i: int. Index of the constraint or variable.
      bk: mosek.boundkey. New bound key.
      bl: double. New lower bound.
      bu: double. New upper bound.
    """
    res = __library__.MSK_XX_putbound(self.__nativep,accmode_,i_,bk_,bl_,bu_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_intvector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector)
  def putboundlist(self,accmode_,sub_,bk_,bl_,bu_):
    """
    Changes the bounds of constraints or variables.
  
    putboundlist(self,accmode_,sub_,bk_,bl_,bu_)
      accmode: mosek.accmode. Defines whether to acces bounds on variables or constraints.
      sub: array of int. Subscripts of the bounds that should be changed.
      bk: array of mosek.boundkey. Bound keys for variables or constraints.
      bl: array of double. Bound keys for variables or constraints.
      bu: array of double. Constraint or variable upper bounds.
    """
    num_ = None
    if num_ is None:
      num_ = len(sub_)
    else:
      num_ = min(num_,len(sub_))
    if num_ is None:
      num_ = len(bk_)
    else:
      num_ = min(num_,len(bk_))
    if num_ is None:
      num_ = len(bl_)
    else:
      num_ = min(num_,len(bl_))
    if num_ is None:
      num_ = len(bu_)
    else:
      num_ = min(num_,len(bu_))
    if sub_ is None:
      raise ValueError("Argument sub cannot be None")
    if sub_ is None:
      raise ValueError("Argument sub may not be None")
    if isinstance(sub_, numpy.ndarray) and sub_.dtype is numpy.int32 and sub_.flags.contiguous:
      _sub_copyarray = False
      _sub_tmp = ctypes.cast(sub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(sub_,array.ndarray) and sub_.dtype is array.int32 and  sub_.getsteplength() == 1:
      _sub_copyarray = False
      _sub_tmp = sub_.getdatacptr()
    else:
      _sub_copyarray = True
      _sub_tmp = (ctypes.c_int32 * len(sub_))(*sub_)
    if bk_ is None:
      raise ValueError("Argument bk cannot be None")
    if bk_ is None:
      raise ValueError("Argument bk may not be None")
    _bk_tmp_arr = array.array(bk_,array.int32)
    _bk_tmp = _bk_tmp_arr.getdatacptr()
    if bl_ is None:
      raise ValueError("Argument bl cannot be None")
    if bl_ is None:
      raise ValueError("Argument bl may not be None")
    if isinstance(bl_, numpy.ndarray) and bl_.dtype is numpy.float64 and bl_.flags.contiguous:
      _bl_copyarray = False
      _bl_tmp = ctypes.cast(bl_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bl_,array.ndarray) and bl_.dtype is array.float64 and  bl_.getsteplength() == 1:
      _bl_copyarray = False
      _bl_tmp = bl_.getdatacptr()
    else:
      _bl_copyarray = True
      _bl_tmp = (ctypes.c_double * len(bl_))(*bl_)
    if bu_ is None:
      raise ValueError("Argument bu cannot be None")
    if bu_ is None:
      raise ValueError("Argument bu may not be None")
    if isinstance(bu_, numpy.ndarray) and bu_.dtype is numpy.float64 and bu_.flags.contiguous:
      _bu_copyarray = False
      _bu_tmp = ctypes.cast(bu_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bu_,array.ndarray) and bu_.dtype is array.float64 and  bu_.getsteplength() == 1:
      _bu_copyarray = False
      _bu_tmp = bu_.getdatacptr()
    else:
      _bu_copyarray = True
      _bu_tmp = (ctypes.c_double * len(bu_))(*bu_)
    res = __library__.MSK_XX_putboundlist(self.__nativep,accmode_,num_,_sub_tmp,_bk_tmp,_bl_tmp,_bu_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_double)
  def putcfix(self,cfix_):
    """
    Replaces the fixed term in the objective.
  
    putcfix(self,cfix_)
      cfix: double. Fixed term in the objective.
    """
    res = __library__.MSK_XX_putcfix(self.__nativep,cfix_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_double)
  def putcj(self,j_,cj_):
    """
    Modifies one linear coefficient in the objective.
  
    putcj(self,j_,cj_)
      j: int. Index of the variable whose objective coefficient should be changed.
      cj: double. New coefficient value.
    """
    res = __library__.MSK_XX_putcj(self.__nativep,j_,cj_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(objsense))
  def putobjsense(self,sense_):
    """
    Sets the objective sense.
  
    putobjsense(self,sense_)
      sense: mosek.objsense. The objective sense of the task
    """
    res = __library__.MSK_XX_putobjsense(self.__nativep,sense_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def getobjsense(self):
    """
    Gets the objective sense.
  
    getobjsense(self)
    returns: sense
      sense: mosek.objsense. The returned objective sense.
    """
    sense_ = ctypes.c_int32()
    res = __library__.MSK_XX_getobjsense(self.__nativep,ctypes.byref(sense_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _sense_return_value = objsense(sense_.value)
    return (_sense_return_value)
  @accepts(_accept_any,_make_intvector,_make_doublevector)
  def putclist(self,subj_,val_):
    """
    Modifies a part of the linear objective coefficients.
  
    putclist(self,subj_,val_)
      subj: array of int. Index of variables for which objective coefficients should be changed.
      val: array of double. New numerical values for the objective coefficients that should be modified.
    """
    num_ = None
    if num_ is None:
      num_ = len(subj_)
    else:
      num_ = min(num_,len(subj_))
    if num_ is None:
      num_ = len(val_)
    else:
      num_ = min(num_,len(val_))
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if val_ is None:
      raise ValueError("Argument val cannot be None")
    if val_ is None:
      raise ValueError("Argument val may not be None")
    if isinstance(val_, numpy.ndarray) and val_.dtype is numpy.float64 and val_.flags.contiguous:
      _val_copyarray = False
      _val_tmp = ctypes.cast(val_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(val_,array.ndarray) and val_.dtype is array.float64 and  val_.getsteplength() == 1:
      _val_copyarray = False
      _val_tmp = val_.getdatacptr()
    else:
      _val_copyarray = True
      _val_tmp = (ctypes.c_double * len(val_))(*val_)
    res = __library__.MSK_XX_putclist(self.__nativep,num_,_subj_tmp,_val_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_accept_anyenum(conetype),_make_double,_make_intvector)
  def putcone(self,k_,conetype_,conepar_,submem_):
    """
    Replaces a conic constraint.
  
    putcone(self,k_,conetype_,conepar_,submem_)
      k: int. Index of the cone.
      conetype: mosek.conetype. Specifies the type of the cone.
      conepar: double. This argument is currently not used. Can be set to 0.0.
      submem: array of int. Variable subscripts of the members in the cone.
    """
    nummem_ = None
    if nummem_ is None:
      nummem_ = len(submem_)
    else:
      nummem_ = min(nummem_,len(submem_))
    if submem_ is None:
      raise ValueError("Argument submem cannot be None")
    if submem_ is None:
      raise ValueError("Argument submem may not be None")
    if isinstance(submem_, numpy.ndarray) and submem_.dtype is numpy.int32 and submem_.flags.contiguous:
      _submem_copyarray = False
      _submem_tmp = ctypes.cast(submem_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(submem_,array.ndarray) and submem_.dtype is array.int32 and  submem_.getsteplength() == 1:
      _submem_copyarray = False
      _submem_tmp = submem_.getdatacptr()
    else:
      _submem_copyarray = True
      _submem_tmp = (ctypes.c_int32 * len(submem_))(*submem_)
    res = __library__.MSK_XX_putcone(self.__nativep,k_,conetype_,conepar_,nummem_,_submem_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(dparam),_make_double)
  def putdouparam(self,param_,parvalue_):
    """
    Sets a double parameter.
  
    putdouparam(self,param_,parvalue_)
      param: mosek.dparam. Which parameter.
      parvalue: double. Parameter value.
    """
    res = __library__.MSK_XX_putdouparam(self.__nativep,param_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(iparam),_make_int)
  def putintparam(self,param_,parvalue_):
    """
    Sets an integer parameter.
  
    putintparam(self,param_,parvalue_)
      param: mosek.iparam. Which parameter.
      parvalue: int. Parameter value.
    """
    res = __library__.MSK_XX_putintparam(self.__nativep,param_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int)
  def putmaxnumcon(self,maxnumcon_):
    """
    Sets the number of preallocated constraints in the optimization task.
  
    putmaxnumcon(self,maxnumcon_)
      maxnumcon: int. Number of preallocated constraints in the optimization task.
    """
    res = __library__.MSK_XX_putmaxnumcon(self.__nativep,maxnumcon_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int)
  def putmaxnumcone(self,maxnumcone_):
    """
    Sets the number of preallocated conic constraints in the optimization task.
  
    putmaxnumcone(self,maxnumcone_)
      maxnumcone: int. Number of preallocated conic constraints in the optimization task.
    """
    res = __library__.MSK_XX_putmaxnumcone(self.__nativep,maxnumcone_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def getmaxnumcone(self):
    """
    Obtains the number of preallocated cones in the optimization task.
  
    getmaxnumcone(self)
    returns: maxnumcone
      maxnumcone: int. Number of preallocated conic constraints in the optimization task.
    """
    maxnumcone_ = ctypes.c_int32()
    maxnumcone_ = ctypes.c_int32()
    res = __library__.MSK_XX_getmaxnumcone(self.__nativep,ctypes.byref(maxnumcone_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _maxnumcone_return_value = maxnumcone_.value
    return (_maxnumcone_return_value)
  @accepts(_accept_any,_make_int)
  def putmaxnumvar(self,maxnumvar_):
    """
    Sets the number of preallocated variables in the optimization task.
  
    putmaxnumvar(self,maxnumvar_)
      maxnumvar: int. Number of preallocated variables in the optimization task.
    """
    res = __library__.MSK_XX_putmaxnumvar(self.__nativep,maxnumvar_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_long)
  def putmaxnumanz(self,maxnumanz_):
    """
    The function changes the size of the preallocated storage for linear coefficients.
  
    putmaxnumanz(self,maxnumanz_)
      maxnumanz: long. New size of the storage reserved for storing the linear coefficient matrix.
    """
    res = __library__.MSK_XX_putmaxnumanz64(self.__nativep,maxnumanz_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_long)
  def putmaxnumqnz(self,maxnumqnz_):
    """
    Changes the size of the preallocated storage for quadratic terms.
  
    putmaxnumqnz(self,maxnumqnz_)
      maxnumqnz: long. Number of non-zero elements preallocated in quadratic coefficient matrices.
    """
    res = __library__.MSK_XX_putmaxnumqnz64(self.__nativep,maxnumqnz_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def getmaxnumqnz(self):
    """
    Obtains the number of preallocated non-zeros for all quadratic terms in objective and constraints.
  
    getmaxnumqnz(self)
    returns: maxnumqnz
      maxnumqnz: long. Number of non-zero elements preallocated in quadratic coefficient matrices.
    """
    maxnumqnz_ = ctypes.c_int64()
    maxnumqnz_ = ctypes.c_int64()
    res = __library__.MSK_XX_getmaxnumqnz64(self.__nativep,ctypes.byref(maxnumqnz_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _maxnumqnz_return_value = maxnumqnz_.value
    return (_maxnumqnz_return_value)
  @accepts(_accept_any,_accept_str,_make_double)
  def putnadouparam(self,paramname_,parvalue_):
    """
    Sets a double parameter.
  
    putnadouparam(self,paramname_,parvalue_)
      paramname: str. Name of a parameter.
      parvalue: double. Parameter value.
    """
    paramname_ = paramname_.encode("utf-8")
    res = __library__.MSK_XX_putnadouparam(self.__nativep,paramname_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str,_make_int)
  def putnaintparam(self,paramname_,parvalue_):
    """
    Sets an integer parameter.
  
    putnaintparam(self,paramname_,parvalue_)
      paramname: str. Name of a parameter.
      parvalue: int. Parameter value.
    """
    paramname_ = paramname_.encode("utf-8")
    res = __library__.MSK_XX_putnaintparam(self.__nativep,paramname_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(problemitem),_make_int,_accept_str)
  def putname(self,whichitem_,i_,name_):
    """
    Assigns a name to a problem item.
  
    putname(self,whichitem_,i_,name_)
      whichitem: mosek.problemitem. Problem item, i.e. a cone, a variable or a constraint name..
      i: int. Index.
      name: str. New name to be assigned to the item.
    """
    name_ = name_.encode("utf-8")
    res = __library__.MSK_XX_putname(self.__nativep,whichitem_,i_,name_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str,_accept_str)
  def putnastrparam(self,paramname_,parvalue_):
    """
    Sets a string parameter.
  
    putnastrparam(self,paramname_,parvalue_)
      paramname: str. Name of a parameter.
      parvalue: str. Parameter value.
    """
    paramname_ = paramname_.encode("utf-8")
    parvalue_ = parvalue_.encode("utf-8")
    res = __library__.MSK_XX_putnastrparam(self.__nativep,paramname_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def putobjname(self,objname_):
    """
    Assigns a new name to the objective.
  
    putobjname(self,objname_)
      objname: str. Name of the objective.
    """
    objname_ = objname_.encode("utf-8")
    res = __library__.MSK_XX_putobjname(self.__nativep,objname_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str,_accept_str)
  def putparam(self,parname_,parvalue_):
    """
    Modifies the value of parameter.
  
    putparam(self,parname_,parvalue_)
      parname: str. Parameter name.
      parvalue: str. Parameter value.
    """
    parname_ = parname_.encode("utf-8")
    parvalue_ = parvalue_.encode("utf-8")
    res = __library__.MSK_XX_putparam(self.__nativep,parname_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_intvector,_make_intvector,_make_doublevector)
  def putqcon(self,qcsubk_,qcsubi_,qcsubj_,qcval_):
    """
    Replaces all quadratic terms in constraints.
  
    putqcon(self,qcsubk_,qcsubi_,qcsubj_,qcval_)
      qcsubk: array of int. Constraint subscripts for quadratic coefficients.
      qcsubi: array of int. Row subscripts for quadratic constraint matrix.
      qcsubj: array of int. Column subscripts for quadratic constraint matrix.
      qcval: array of double. Quadratic constraint coefficient values.
    """
    numqcnz_ = None
    if numqcnz_ is None:
      numqcnz_ = len(qcsubi_)
    else:
      numqcnz_ = min(numqcnz_,len(qcsubi_))
    if numqcnz_ is None:
      numqcnz_ = len(qcsubj_)
    else:
      numqcnz_ = min(numqcnz_,len(qcsubj_))
    if numqcnz_ is None:
      numqcnz_ = len(qcval_)
    else:
      numqcnz_ = min(numqcnz_,len(qcval_))
    if qcsubk_ is None:
      raise ValueError("Argument qcsubk cannot be None")
    if qcsubk_ is None:
      raise ValueError("Argument qcsubk may not be None")
    if isinstance(qcsubk_, numpy.ndarray) and qcsubk_.dtype is numpy.int32 and qcsubk_.flags.contiguous:
      _qcsubk_copyarray = False
      _qcsubk_tmp = ctypes.cast(qcsubk_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubk_,array.ndarray) and qcsubk_.dtype is array.int32 and  qcsubk_.getsteplength() == 1:
      _qcsubk_copyarray = False
      _qcsubk_tmp = qcsubk_.getdatacptr()
    else:
      _qcsubk_copyarray = True
      _qcsubk_tmp = (ctypes.c_int32 * len(qcsubk_))(*qcsubk_)
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi cannot be None")
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi may not be None")
    if isinstance(qcsubi_, numpy.ndarray) and qcsubi_.dtype is numpy.int32 and qcsubi_.flags.contiguous:
      _qcsubi_copyarray = False
      _qcsubi_tmp = ctypes.cast(qcsubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubi_,array.ndarray) and qcsubi_.dtype is array.int32 and  qcsubi_.getsteplength() == 1:
      _qcsubi_copyarray = False
      _qcsubi_tmp = qcsubi_.getdatacptr()
    else:
      _qcsubi_copyarray = True
      _qcsubi_tmp = (ctypes.c_int32 * len(qcsubi_))(*qcsubi_)
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj cannot be None")
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj may not be None")
    if isinstance(qcsubj_, numpy.ndarray) and qcsubj_.dtype is numpy.int32 and qcsubj_.flags.contiguous:
      _qcsubj_copyarray = False
      _qcsubj_tmp = ctypes.cast(qcsubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubj_,array.ndarray) and qcsubj_.dtype is array.int32 and  qcsubj_.getsteplength() == 1:
      _qcsubj_copyarray = False
      _qcsubj_tmp = qcsubj_.getdatacptr()
    else:
      _qcsubj_copyarray = True
      _qcsubj_tmp = (ctypes.c_int32 * len(qcsubj_))(*qcsubj_)
    if qcval_ is None:
      raise ValueError("Argument qcval cannot be None")
    if qcval_ is None:
      raise ValueError("Argument qcval may not be None")
    if isinstance(qcval_, numpy.ndarray) and qcval_.dtype is numpy.float64 and qcval_.flags.contiguous:
      _qcval_copyarray = False
      _qcval_tmp = ctypes.cast(qcval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qcval_,array.ndarray) and qcval_.dtype is array.float64 and  qcval_.getsteplength() == 1:
      _qcval_copyarray = False
      _qcval_tmp = qcval_.getdatacptr()
    else:
      _qcval_copyarray = True
      _qcval_tmp = (ctypes.c_double * len(qcval_))(*qcval_)
    res = __library__.MSK_XX_putqcon(self.__nativep,numqcnz_,_qcsubk_tmp,_qcsubi_tmp,_qcsubj_tmp,_qcval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_intvector,_make_intvector,_make_doublevector)
  def putqconk(self,k_,qcsubi_,qcsubj_,qcval_):
    """
    Replaces all quadratic terms in a single constraint.
  
    putqconk(self,k_,qcsubi_,qcsubj_,qcval_)
      k: int. The constraint in which the new quadratic elements are inserted.
      qcsubi: array of int. Row subscripts for quadratic constraint matrix.
      qcsubj: array of int. Column subscripts for quadratic constraint matrix.
      qcval: array of double. Quadratic constraint coefficient values.
    """
    numqcnz_ = None
    if numqcnz_ is None:
      numqcnz_ = len(qcsubi_)
    else:
      numqcnz_ = min(numqcnz_,len(qcsubi_))
    if numqcnz_ is None:
      numqcnz_ = len(qcsubj_)
    else:
      numqcnz_ = min(numqcnz_,len(qcsubj_))
    if numqcnz_ is None:
      numqcnz_ = len(qcval_)
    else:
      numqcnz_ = min(numqcnz_,len(qcval_))
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi cannot be None")
    if qcsubi_ is None:
      raise ValueError("Argument qcsubi may not be None")
    if isinstance(qcsubi_, numpy.ndarray) and qcsubi_.dtype is numpy.int32 and qcsubi_.flags.contiguous:
      _qcsubi_copyarray = False
      _qcsubi_tmp = ctypes.cast(qcsubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubi_,array.ndarray) and qcsubi_.dtype is array.int32 and  qcsubi_.getsteplength() == 1:
      _qcsubi_copyarray = False
      _qcsubi_tmp = qcsubi_.getdatacptr()
    else:
      _qcsubi_copyarray = True
      _qcsubi_tmp = (ctypes.c_int32 * len(qcsubi_))(*qcsubi_)
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj cannot be None")
    if qcsubj_ is None:
      raise ValueError("Argument qcsubj may not be None")
    if isinstance(qcsubj_, numpy.ndarray) and qcsubj_.dtype is numpy.int32 and qcsubj_.flags.contiguous:
      _qcsubj_copyarray = False
      _qcsubj_tmp = ctypes.cast(qcsubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qcsubj_,array.ndarray) and qcsubj_.dtype is array.int32 and  qcsubj_.getsteplength() == 1:
      _qcsubj_copyarray = False
      _qcsubj_tmp = qcsubj_.getdatacptr()
    else:
      _qcsubj_copyarray = True
      _qcsubj_tmp = (ctypes.c_int32 * len(qcsubj_))(*qcsubj_)
    if qcval_ is None:
      raise ValueError("Argument qcval cannot be None")
    if qcval_ is None:
      raise ValueError("Argument qcval may not be None")
    if isinstance(qcval_, numpy.ndarray) and qcval_.dtype is numpy.float64 and qcval_.flags.contiguous:
      _qcval_copyarray = False
      _qcval_tmp = ctypes.cast(qcval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qcval_,array.ndarray) and qcval_.dtype is array.float64 and  qcval_.getsteplength() == 1:
      _qcval_copyarray = False
      _qcval_tmp = qcval_.getdatacptr()
    else:
      _qcval_copyarray = True
      _qcval_tmp = (ctypes.c_double * len(qcval_))(*qcval_)
    res = __library__.MSK_XX_putqconk(self.__nativep,k_,numqcnz_,_qcsubi_tmp,_qcsubj_tmp,_qcval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_intvector,_make_doublevector)
  def putqobj(self,qosubi_,qosubj_,qoval_):
    """
    Replaces all quadratic terms in the objective.
  
    putqobj(self,qosubi_,qosubj_,qoval_)
      qosubi: array of int. Row subscripts for quadratic objective coefficients.
      qosubj: array of int. Column subscripts for quadratic objective coefficients.
      qoval: array of double. Quadratic objective coefficient values.
    """
    numqonz_ = None
    if numqonz_ is None:
      numqonz_ = len(qosubi_)
    else:
      numqonz_ = min(numqonz_,len(qosubi_))
    if numqonz_ is None:
      numqonz_ = len(qosubj_)
    else:
      numqonz_ = min(numqonz_,len(qosubj_))
    if numqonz_ is None:
      numqonz_ = len(qoval_)
    else:
      numqonz_ = min(numqonz_,len(qoval_))
    if qosubi_ is None:
      raise ValueError("Argument qosubi cannot be None")
    if qosubi_ is None:
      raise ValueError("Argument qosubi may not be None")
    if isinstance(qosubi_, numpy.ndarray) and qosubi_.dtype is numpy.int32 and qosubi_.flags.contiguous:
      _qosubi_copyarray = False
      _qosubi_tmp = ctypes.cast(qosubi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubi_,array.ndarray) and qosubi_.dtype is array.int32 and  qosubi_.getsteplength() == 1:
      _qosubi_copyarray = False
      _qosubi_tmp = qosubi_.getdatacptr()
    else:
      _qosubi_copyarray = True
      _qosubi_tmp = (ctypes.c_int32 * len(qosubi_))(*qosubi_)
    if qosubj_ is None:
      raise ValueError("Argument qosubj cannot be None")
    if qosubj_ is None:
      raise ValueError("Argument qosubj may not be None")
    if isinstance(qosubj_, numpy.ndarray) and qosubj_.dtype is numpy.int32 and qosubj_.flags.contiguous:
      _qosubj_copyarray = False
      _qosubj_tmp = ctypes.cast(qosubj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(qosubj_,array.ndarray) and qosubj_.dtype is array.int32 and  qosubj_.getsteplength() == 1:
      _qosubj_copyarray = False
      _qosubj_tmp = qosubj_.getdatacptr()
    else:
      _qosubj_copyarray = True
      _qosubj_tmp = (ctypes.c_int32 * len(qosubj_))(*qosubj_)
    if qoval_ is None:
      raise ValueError("Argument qoval cannot be None")
    if qoval_ is None:
      raise ValueError("Argument qoval may not be None")
    if isinstance(qoval_, numpy.ndarray) and qoval_.dtype is numpy.float64 and qoval_.flags.contiguous:
      _qoval_copyarray = False
      _qoval_tmp = ctypes.cast(qoval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(qoval_,array.ndarray) and qoval_.dtype is array.float64 and  qoval_.getsteplength() == 1:
      _qoval_copyarray = False
      _qoval_tmp = qoval_.getdatacptr()
    else:
      _qoval_copyarray = True
      _qoval_tmp = (ctypes.c_double * len(qoval_))(*qoval_)
    res = __library__.MSK_XX_putqobj(self.__nativep,numqonz_,_qosubi_tmp,_qosubj_tmp,_qoval_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_int,_make_double)
  def putqobjij(self,i_,j_,qoij_):
    """
    Replaces one coefficient in the quadratic term in                     the objective.
  
    putqobjij(self,i_,j_,qoij_)
      i: int. Row index for the coefficient to be replaced.
      j: int. Column index for the coefficient to be replaced.
      qoij: double. The new coefficient value.
    """
    res = __library__.MSK_XX_putqobjij(self.__nativep,i_,j_,qoij_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def makesolutionstatusunknown(self,whichsol_):
    """
    Sets the solution status to unknown.
  
    makesolutionstatusunknown(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    """
    res = __library__.MSK_XX_makesolutionstatusunknown(self.__nativep,whichsol_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype),_make_anyenumvector(stakey),_make_anyenumvector(stakey),_make_anyenumvector(stakey),_make_doublevector,_make_doublevector,_make_doublevector,_make_doublevector,_make_doublevector,_make_doublevector,_make_doublevector,_make_doublevector)
  def putsolution(self,whichsol_,skc_,skx_,skn_,xc_,xx_,y_,slc_,suc_,slx_,sux_,snx_):
    """
    Inserts a solution.
  
    putsolution(self,whichsol_,skc_,skx_,skn_,xc_,xx_,y_,slc_,suc_,slx_,sux_,snx_)
      whichsol: mosek.soltype. Selects a solution.
      skc: array of mosek.stakey. Status keys for the constraints.
      skx: array of mosek.stakey. Status keys for the variables.
      skn: array of mosek.stakey. Status keys for the conic constraints.
      xc: array of double. Primal constraint solution.
      xx: array of double. Primal variable solution.
      y: array of double. Vector of dual variables corresponding to the constraints.
      slc: array of double. Dual variables corresponding to the lower bounds on the constraints.
      suc: array of double. Dual variables corresponding to the upper bounds on the constraints.
      slx: array of double. Dual variables corresponding to the lower bounds on the variables.
      sux: array of double. Dual variables corresponding to the upper bounds on the variables.
      snx: array of double. Dual variables corresponding to the conic constraints on the variables.
    """
    _skc_tmp_arr = array.array(skc_,array.int32)
    _skc_tmp = _skc_tmp_arr.getdatacptr()
    _skx_tmp_arr = array.array(skx_,array.int32)
    _skx_tmp = _skx_tmp_arr.getdatacptr()
    _skn_tmp_arr = array.array(skn_,array.int32)
    _skn_tmp = _skn_tmp_arr.getdatacptr()
    if isinstance(xc_, numpy.ndarray) and xc_.dtype is numpy.float64 and xc_.flags.contiguous:
      _xc_copyarray = False
      _xc_tmp = ctypes.cast(xc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xc_,array.ndarray) and xc_.dtype is array.float64 and  xc_.getsteplength() == 1:
      _xc_copyarray = False
      _xc_tmp = xc_.getdatacptr()
    else:
      _xc_copyarray = True
      _xc_tmp = (ctypes.c_double * len(xc_))(*xc_)
    if isinstance(xx_, numpy.ndarray) and xx_.dtype is numpy.float64 and xx_.flags.contiguous:
      _xx_copyarray = False
      _xx_tmp = ctypes.cast(xx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(xx_,array.ndarray) and xx_.dtype is array.float64 and  xx_.getsteplength() == 1:
      _xx_copyarray = False
      _xx_tmp = xx_.getdatacptr()
    else:
      _xx_copyarray = True
      _xx_tmp = (ctypes.c_double * len(xx_))(*xx_)
    if isinstance(y_, numpy.ndarray) and y_.dtype is numpy.float64 and y_.flags.contiguous:
      _y_copyarray = False
      _y_tmp = ctypes.cast(y_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(y_,array.ndarray) and y_.dtype is array.float64 and  y_.getsteplength() == 1:
      _y_copyarray = False
      _y_tmp = y_.getdatacptr()
    else:
      _y_copyarray = True
      _y_tmp = (ctypes.c_double * len(y_))(*y_)
    if isinstance(slc_, numpy.ndarray) and slc_.dtype is numpy.float64 and slc_.flags.contiguous:
      _slc_copyarray = False
      _slc_tmp = ctypes.cast(slc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slc_,array.ndarray) and slc_.dtype is array.float64 and  slc_.getsteplength() == 1:
      _slc_copyarray = False
      _slc_tmp = slc_.getdatacptr()
    else:
      _slc_copyarray = True
      _slc_tmp = (ctypes.c_double * len(slc_))(*slc_)
    if isinstance(suc_, numpy.ndarray) and suc_.dtype is numpy.float64 and suc_.flags.contiguous:
      _suc_copyarray = False
      _suc_tmp = ctypes.cast(suc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(suc_,array.ndarray) and suc_.dtype is array.float64 and  suc_.getsteplength() == 1:
      _suc_copyarray = False
      _suc_tmp = suc_.getdatacptr()
    else:
      _suc_copyarray = True
      _suc_tmp = (ctypes.c_double * len(suc_))(*suc_)
    if isinstance(slx_, numpy.ndarray) and slx_.dtype is numpy.float64 and slx_.flags.contiguous:
      _slx_copyarray = False
      _slx_tmp = ctypes.cast(slx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(slx_,array.ndarray) and slx_.dtype is array.float64 and  slx_.getsteplength() == 1:
      _slx_copyarray = False
      _slx_tmp = slx_.getdatacptr()
    else:
      _slx_copyarray = True
      _slx_tmp = (ctypes.c_double * len(slx_))(*slx_)
    if isinstance(sux_, numpy.ndarray) and sux_.dtype is numpy.float64 and sux_.flags.contiguous:
      _sux_copyarray = False
      _sux_tmp = ctypes.cast(sux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(sux_,array.ndarray) and sux_.dtype is array.float64 and  sux_.getsteplength() == 1:
      _sux_copyarray = False
      _sux_tmp = sux_.getdatacptr()
    else:
      _sux_copyarray = True
      _sux_tmp = (ctypes.c_double * len(sux_))(*sux_)
    if isinstance(snx_, numpy.ndarray) and snx_.dtype is numpy.float64 and snx_.flags.contiguous:
      _snx_copyarray = False
      _snx_tmp = ctypes.cast(snx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(snx_,array.ndarray) and snx_.dtype is array.float64 and  snx_.getsteplength() == 1:
      _snx_copyarray = False
      _snx_tmp = snx_.getdatacptr()
    else:
      _snx_copyarray = True
      _snx_tmp = (ctypes.c_double * len(snx_))(*snx_)
    res = __library__.MSK_XX_putsolution(self.__nativep,whichsol_,_skc_tmp,_skx_tmp,_skn_tmp,_xc_tmp,_xx_tmp,_y_tmp,_slc_tmp,_suc_tmp,_slx_tmp,_sux_tmp,_snx_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int,_accept_anyenum(soltype),_accept_anyenum(stakey),_make_double,_make_double,_make_double,_make_double)
  def putsolutioni(self,accmode_,i_,whichsol_,sk_,x_,sl_,su_,sn_):
    """
    Sets the primal and dual solution information for a single constraint or variable.
  
    putsolutioni(self,accmode_,i_,whichsol_,sk_,x_,sl_,su_,sn_)
      accmode: mosek.accmode. Defines whether solution information for a constraint or for a variable is modified.
      i: int. Index of the constraint or variable.
      whichsol: mosek.soltype. Selects a solution.
      sk: mosek.stakey. Status key of the constraint or variable.
      x: double. Solution value of the primal constraint or variable.
      sl: double. Solution value of the dual variable associated with the lower bound.
      su: double. Solution value of the dual variable associated with the upper bound.
      sn: double. Solution value of the dual variable associated with the cone constraint.
    """
    res = __library__.MSK_XX_putsolutioni(self.__nativep,accmode_,i_,whichsol_,sk_,x_,sl_,su_,sn_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_accept_anyenum(soltype),_make_double)
  def putsolutionyi(self,i_,whichsol_,y_):
    """
    Inputs the dual variable of a solution.
  
    putsolutionyi(self,i_,whichsol_,y_)
      i: int. Index of the dual variable.
      whichsol: mosek.soltype. Selects a solution.
      y: double. Solution value of the dual variable.
    """
    res = __library__.MSK_XX_putsolutionyi(self.__nativep,i_,whichsol_,y_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(sparam),_accept_str)
  def putstrparam(self,param_,parvalue_):
    """
    Sets a string parameter.
  
    putstrparam(self,param_,parvalue_)
      param: mosek.sparam. Which parameter.
      parvalue: str. Parameter value.
    """
    parvalue_ = parvalue_.encode("utf-8")
    res = __library__.MSK_XX_putstrparam(self.__nativep,param_,parvalue_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def puttaskname(self,taskname_):
    """
    Assigns a new name to the task.
  
    puttaskname(self,taskname_)
      taskname: str. Name assigned to the task.
    """
    taskname_ = taskname_.encode("utf-8")
    res = __library__.MSK_XX_puttaskname(self.__nativep,taskname_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_accept_anyenum(variabletype))
  def putvartype(self,j_,vartype_):
    """
    Sets the variable type of one variable.
  
    putvartype(self,j_,vartype_)
      j: int. Index of the variable.
      vartype: mosek.variabletype. The new variable type.
    """
    res = __library__.MSK_XX_putvartype(self.__nativep,j_,vartype_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_anyenumvector(variabletype))
  def putvartypelist(self,subj_,vartype_):
    """
    Sets the variable type for one or more variables.
  
    putvartypelist(self,subj_,vartype_)
      subj: array of int. A list of variable indexes for which the variable                            type should be changed.
      vartype: array of mosek.variabletype. A list of variable types.
    """
    num_ = None
    if num_ is None:
      num_ = len(subj_)
    else:
      num_ = min(num_,len(subj_))
    if num_ is None:
      num_ = len(vartype_)
    else:
      num_ = min(num_,len(vartype_))
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if vartype_ is None:
      raise ValueError("Argument vartype cannot be None")
    if vartype_ is None:
      raise ValueError("Argument vartype may not be None")
    _vartype_tmp_arr = array.array(vartype_,array.int32)
    _vartype_tmp = _vartype_tmp_arr.getdatacptr()
    res = __library__.MSK_XX_putvartypelist(self.__nativep,num_,_subj_tmp,_vartype_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_int,_accept_anyenum(branchdir))
  def putvarbranchorder(self,j_,priority_,direction_):
    """
    Assigns a branching priority and direction to a variable.
  
    putvarbranchorder(self,j_,priority_,direction_)
      j: int. Index of the variable.
      priority: int. The branching priority that should be assigned to the j'th variable.
      direction: mosek.branchdir. Specifies the preferred branching direction for the j'th variable.
    """
    res = __library__.MSK_XX_putvarbranchorder(self.__nativep,j_,priority_,direction_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int)
  def getvarbranchpri(self,j_):
    """
    Obtains the branching priority for a variable.
  
    getvarbranchpri(self,j_)
      j: int. Index of the variable.
    returns: priority
      priority: int. The branching priority assigned to the j'th variable.
    """
    priority_ = ctypes.c_int32()
    priority_ = ctypes.c_int32()
    res = __library__.MSK_XX_getvarbranchpri(self.__nativep,j_,ctypes.byref(priority_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _priority_return_value = priority_.value
    return (_priority_return_value)
  @accepts(_accept_any,_make_int)
  def getvarbranchdir(self,j_):
    """
    Obtains the branching direction for a variable.
  
    getvarbranchdir(self,j_)
      j: int. Index of the variable.
    returns: direction
      direction: mosek.branchdir. The branching direction assigned to the j'th variable.
    """
    direction_ = ctypes.c_int32()
    res = __library__.MSK_XX_getvarbranchdir(self.__nativep,j_,ctypes.byref(direction_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _direction_return_value = branchdir(direction_.value)
    return (_direction_return_value)
  @accepts(_accept_any,_accept_str)
  def readdata(self,filename_):
    """
    Reads problem data from a file.
  
    readdata(self,filename_)
      filename: str. Input data file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_readdata(self.__nativep,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def readparamfile(self):
    """
    Reads a parameter file.
  
    readparamfile(self)
    """
    res = __library__.MSK_XX_readparamfile(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_str)
  def readsolution(self,whichsol_,filename_):
    """
    Reads a solution from a file.
  
    readsolution(self,whichsol_,filename_)
      whichsol: mosek.soltype. Selects a solution.
      filename: str. A valid file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_readsolution(self.__nativep,whichsol_,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(streamtype))
  def readsummary(self,whichstream_):
    """
    Prints information about last file read.
  
    readsummary(self,whichstream_)
      whichstream: mosek.streamtype. Index of the stream.
    """
    res = __library__.MSK_XX_readsummary(self.__nativep,whichstream_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_int,_make_int,_make_int,_make_int,_make_int)
  def resizetask(self,maxnumcon_,maxnumvar_,maxnumcone_,maxnumanz_,maxnumqnz_):
    """
    Resizes an optimization task.
  
    resizetask(self,maxnumcon_,maxnumvar_,maxnumcone_,maxnumanz_,maxnumqnz_)
      maxnumcon: int. New maximum number of constraints.
      maxnumvar: int. New maximum number of variables.
      maxnumcone: int. New maximum number of cones.
      maxnumanz: int. New maximum number of linear non-zero elements.
      maxnumqnz: int. New maximum number of quadratic non-zeros elements.
    """
    res = __library__.MSK_XX_resizetask(self.__nativep,maxnumcon_,maxnumvar_,maxnumcone_,maxnumanz_,maxnumqnz_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str,_make_int)
  def checkmem(self,file_,line_):
    """
    Checks the memory allocated by the task.
  
    checkmem(self,file_,line_)
      file: str. File from which the function is called.
      line: int. Line in the file from which the function is called.
    """
    file_ = file_.encode("utf-8")
    res = __library__.MSK_XX_checkmemtask(self.__nativep,file_,line_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def getmemusage(self):
    """
    Obtains information about the amount of memory used by a task.
  
    getmemusage(self)
    returns: meminuse,maxmemuse
      meminuse: long. Amount of memory currently used by the task.
      maxmemuse: long. Maximum amount of memory used by the task until now.
    """
    meminuse_ = ctypes.c_int64()
    meminuse_ = ctypes.c_int64()
    maxmemuse_ = ctypes.c_int64()
    maxmemuse_ = ctypes.c_int64()
    res = __library__.MSK_XX_getmemusagetask64(self.__nativep,ctypes.byref(meminuse_),ctypes.byref(maxmemuse_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _meminuse_return_value = meminuse_.value
    _maxmemuse_return_value = maxmemuse_.value
    return (_meminuse_return_value,_maxmemuse_return_value)
  @accepts(_accept_any)
  def setdefaults(self):
    """
    Resets all parameters values.
  
    setdefaults(self)
    """
    res = __library__.MSK_XX_setdefaults(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def solutiondef(self,whichsol_):
    """
    Checks whether a solution is defined.
  
    solutiondef(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    returns: isdef
      isdef: int. Is non-zero if the requested solution is defined.
    """
    isdef_ = ctypes.c_int32()
    isdef_ = ctypes.c_int32()
    res = __library__.MSK_XX_solutiondef(self.__nativep,whichsol_,ctypes.byref(isdef_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _isdef_return_value = isdef_.value
    return (_isdef_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def deletesolution(self,whichsol_):
    """
    Undefines a solution and frees the memory it uses.
  
    deletesolution(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    """
    res = __library__.MSK_XX_deletesolution(self.__nativep,whichsol_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def undefsolution(self,whichsol_):
    """
    Undefines a solution.
  
    undefsolution(self,whichsol_)
      whichsol: mosek.soltype. Selects a solution.
    """
    res = __library__.MSK_XX_undefsolution(self.__nativep,whichsol_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(streamtype))
  def solutionsummary(self,whichstream_):
    """
    Prints a short summary of the current solutions.
  
    solutionsummary(self,whichstream_)
      whichstream: mosek.streamtype. Index of the stream.
    """
    res = __library__.MSK_XX_solutionsummary(self.__nativep,whichstream_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(streamtype))
  def optimizersummary(self,whichstream_):
    """
    Prints a short summary with optimizer statistics for last optimization.
  
    optimizersummary(self,whichstream_)
      whichstream: mosek.streamtype. Index of the stream.
    """
    res = __library__.MSK_XX_optimizersummary(self.__nativep,whichstream_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def strtoconetype(self,str_):
    """
    Obtains a cone type code.
  
    strtoconetype(self,str_)
      str: str. String corresponding to the cone type code.
    returns: conetype
      conetype: mosek.conetype. The cone type corresponding to str.
    """
    str_ = str_.encode("utf-8")
    conetype_ = ctypes.c_int32()
    res = __library__.MSK_XX_strtoconetype(self.__nativep,str_,ctypes.byref(conetype_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _conetype_return_value = conetype(conetype_.value)
    return (_conetype_return_value)
  @accepts(_accept_any,_accept_str)
  def strtosk(self,str_):
    """
    Obtains a status key.
  
    strtosk(self,str_)
      str: str. Status key string.
    returns: sk
      sk: int. Status key corresponding to the string.
    """
    str_ = str_.encode("utf-8")
    sk_ = ctypes.c_int32()
    sk_ = ctypes.c_int32()
    res = __library__.MSK_XX_strtosk(self.__nativep,str_,ctypes.byref(sk_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _sk_return_value = sk_.value
    return (_sk_return_value)
  @accepts(_accept_any,_accept_str)
  def writedata(self,filename_):
    """
    Writes problem data to a file.
  
    writedata(self,filename_)
      filename: str. Output file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_writedata(self.__nativep,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def readbranchpriorities(self,filename_):
    """
    Reads branching priority data from a file.
  
    readbranchpriorities(self,filename_)
      filename: str. Input file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_readbranchpriorities(self.__nativep,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def writebranchpriorities(self,filename_):
    """
    Writes branching priority data to a file.
  
    writebranchpriorities(self,filename_)
      filename: str. Output file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_writebranchpriorities(self.__nativep,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_str)
  def writeparamfile(self,filename_):
    """
    Writes all the parameters to a parameter file.
  
    writeparamfile(self,filename_)
      filename: str. The name of parameter file.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_writeparamfile(self.__nativep,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(soltype))
  def getinfeasiblesubproblem(self,whichsol_):
    """
    Obtains an infeasible sub problem.
  
    getinfeasiblesubproblem(self,whichsol_)
      whichsol: mosek.soltype. Which solution to use when determining the infeasible subproblem.
    returns: 
    """
    inftask_ = ctypes.c_void_p()
    inftask_ = ctypes.c_void_p()
    res = __library__.MSK_XX_getinfeasiblesubproblem(self.__nativep,whichsol_,ctypes.byref(inftask_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _inftask_return_value = Task(nativep = inftask_.value)
    return (_inftask_return_value)
  @accepts(_accept_any,_accept_anyenum(soltype),_accept_str)
  def writesolution(self,whichsol_,filename_):
    """
    Write a solution to a file.
  
    writesolution(self,whichsol_,filename_)
      whichsol: mosek.soltype. Selects a solution.
      filename: str. A valid file name.
    """
    filename_ = filename_.encode("utf-8")
    res = __library__.MSK_XX_writesolution(self.__nativep,whichsol_,filename_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_anyenumvector(mark),_make_intvector,_make_anyenumvector(mark),_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector)
  def primalsensitivity(self,subi_,marki_,subj_,markj_,leftpricei_,rightpricei_,leftrangei_,rightrangei_,leftpricej_,rightpricej_,leftrangej_,rightrangej_):
    """
    Perform sensitivity analysis on bounds.
  
    primalsensitivity(self,subi_,marki_,subj_,markj_,leftpricei_,rightpricei_,leftrangei_,rightrangei_,leftpricej_,rightpricej_,leftrangej_,rightrangej_)
      subi: array of int. Indexes of bounds on constraints to analyze.
      marki: array of mosek.mark. Mark which constraint bounds to analyze.
      subj: array of int. Indexes of bounds on variables to analyze.
      markj: array of mosek.mark. Mark which variable bounds to analyze.
      leftpricei: array of double. Left shadow price for constraints.
      rightpricei: array of double. Right shadow price for constraints.
      leftrangei: array of double. Left range for constraints.
      rightrangei: array of double. Right range for constraints.
      leftpricej: array of double. Left price for variables.
      rightpricej: array of double. Right price for variables.
      leftrangej: array of double. Left range for variables.
      rightrangej: array of double. Right range for variables.
    """
    numi_ = None
    if numi_ is None:
      numi_ = len(subi_)
    else:
      numi_ = min(numi_,len(subi_))
    if numi_ is None:
      numi_ = len(marki_)
    else:
      numi_ = min(numi_,len(marki_))
    if subi_ is None:
      raise ValueError("Argument subi cannot be None")
    if subi_ is None:
      raise ValueError("Argument subi may not be None")
    if isinstance(subi_, numpy.ndarray) and subi_.dtype is numpy.int32 and subi_.flags.contiguous:
      _subi_copyarray = False
      _subi_tmp = ctypes.cast(subi_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subi_,array.ndarray) and subi_.dtype is array.int32 and  subi_.getsteplength() == 1:
      _subi_copyarray = False
      _subi_tmp = subi_.getdatacptr()
    else:
      _subi_copyarray = True
      _subi_tmp = (ctypes.c_int32 * len(subi_))(*subi_)
    if marki_ is None:
      raise ValueError("Argument marki cannot be None")
    if marki_ is None:
      raise ValueError("Argument marki may not be None")
    _marki_tmp_arr = array.array(marki_,array.int32)
    _marki_tmp = _marki_tmp_arr.getdatacptr()
    numj_ = None
    if numj_ is None:
      numj_ = len(subj_)
    else:
      numj_ = min(numj_,len(subj_))
    if numj_ is None:
      numj_ = len(markj_)
    else:
      numj_ = min(numj_,len(markj_))
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if markj_ is None:
      raise ValueError("Argument markj cannot be None")
    if markj_ is None:
      raise ValueError("Argument markj may not be None")
    _markj_tmp_arr = array.array(markj_,array.int32)
    _markj_tmp = _markj_tmp_arr.getdatacptr()
    if leftpricei_ is not None and len(leftpricei_) < numi_:
      raise ValueError("Array argument leftpricei is not long enough")
    if isinstance(leftpricei_,numpy.ndarray) and not leftpricei_.flags.writeable:
      raise ValueError("Argument leftpricei must be writable")
    if isinstance(leftpricei_, numpy.ndarray) and leftpricei_.dtype is numpy.float64 and leftpricei_.flags.contiguous:
      _leftpricei_copyarray = False
      _leftpricei_tmp = ctypes.cast(leftpricei_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftpricei_,array.ndarray) and leftpricei_.dtype is array.float64 and  leftpricei_.getsteplength() == 1:
      _leftpricei_copyarray = False
      _leftpricei_tmp = leftpricei_.getdatacptr()
    else:
      _leftpricei_copyarray = True
      _leftpricei_tmp = (ctypes.c_double * len(leftpricei_))(*leftpricei_)
    if rightpricei_ is not None and len(rightpricei_) < numi_:
      raise ValueError("Array argument rightpricei is not long enough")
    if isinstance(rightpricei_,numpy.ndarray) and not rightpricei_.flags.writeable:
      raise ValueError("Argument rightpricei must be writable")
    if isinstance(rightpricei_, numpy.ndarray) and rightpricei_.dtype is numpy.float64 and rightpricei_.flags.contiguous:
      _rightpricei_copyarray = False
      _rightpricei_tmp = ctypes.cast(rightpricei_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightpricei_,array.ndarray) and rightpricei_.dtype is array.float64 and  rightpricei_.getsteplength() == 1:
      _rightpricei_copyarray = False
      _rightpricei_tmp = rightpricei_.getdatacptr()
    else:
      _rightpricei_copyarray = True
      _rightpricei_tmp = (ctypes.c_double * len(rightpricei_))(*rightpricei_)
    if leftrangei_ is not None and len(leftrangei_) < numi_:
      raise ValueError("Array argument leftrangei is not long enough")
    if isinstance(leftrangei_,numpy.ndarray) and not leftrangei_.flags.writeable:
      raise ValueError("Argument leftrangei must be writable")
    if isinstance(leftrangei_, numpy.ndarray) and leftrangei_.dtype is numpy.float64 and leftrangei_.flags.contiguous:
      _leftrangei_copyarray = False
      _leftrangei_tmp = ctypes.cast(leftrangei_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftrangei_,array.ndarray) and leftrangei_.dtype is array.float64 and  leftrangei_.getsteplength() == 1:
      _leftrangei_copyarray = False
      _leftrangei_tmp = leftrangei_.getdatacptr()
    else:
      _leftrangei_copyarray = True
      _leftrangei_tmp = (ctypes.c_double * len(leftrangei_))(*leftrangei_)
    if rightrangei_ is not None and len(rightrangei_) < numi_:
      raise ValueError("Array argument rightrangei is not long enough")
    if isinstance(rightrangei_,numpy.ndarray) and not rightrangei_.flags.writeable:
      raise ValueError("Argument rightrangei must be writable")
    if isinstance(rightrangei_, numpy.ndarray) and rightrangei_.dtype is numpy.float64 and rightrangei_.flags.contiguous:
      _rightrangei_copyarray = False
      _rightrangei_tmp = ctypes.cast(rightrangei_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightrangei_,array.ndarray) and rightrangei_.dtype is array.float64 and  rightrangei_.getsteplength() == 1:
      _rightrangei_copyarray = False
      _rightrangei_tmp = rightrangei_.getdatacptr()
    else:
      _rightrangei_copyarray = True
      _rightrangei_tmp = (ctypes.c_double * len(rightrangei_))(*rightrangei_)
    if leftpricej_ is not None and len(leftpricej_) < numj_:
      raise ValueError("Array argument leftpricej is not long enough")
    if isinstance(leftpricej_,numpy.ndarray) and not leftpricej_.flags.writeable:
      raise ValueError("Argument leftpricej must be writable")
    if isinstance(leftpricej_, numpy.ndarray) and leftpricej_.dtype is numpy.float64 and leftpricej_.flags.contiguous:
      _leftpricej_copyarray = False
      _leftpricej_tmp = ctypes.cast(leftpricej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftpricej_,array.ndarray) and leftpricej_.dtype is array.float64 and  leftpricej_.getsteplength() == 1:
      _leftpricej_copyarray = False
      _leftpricej_tmp = leftpricej_.getdatacptr()
    else:
      _leftpricej_copyarray = True
      _leftpricej_tmp = (ctypes.c_double * len(leftpricej_))(*leftpricej_)
    if rightpricej_ is not None and len(rightpricej_) < numj_:
      raise ValueError("Array argument rightpricej is not long enough")
    if isinstance(rightpricej_,numpy.ndarray) and not rightpricej_.flags.writeable:
      raise ValueError("Argument rightpricej must be writable")
    if isinstance(rightpricej_, numpy.ndarray) and rightpricej_.dtype is numpy.float64 and rightpricej_.flags.contiguous:
      _rightpricej_copyarray = False
      _rightpricej_tmp = ctypes.cast(rightpricej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightpricej_,array.ndarray) and rightpricej_.dtype is array.float64 and  rightpricej_.getsteplength() == 1:
      _rightpricej_copyarray = False
      _rightpricej_tmp = rightpricej_.getdatacptr()
    else:
      _rightpricej_copyarray = True
      _rightpricej_tmp = (ctypes.c_double * len(rightpricej_))(*rightpricej_)
    if leftrangej_ is not None and len(leftrangej_) < numj_:
      raise ValueError("Array argument leftrangej is not long enough")
    if isinstance(leftrangej_,numpy.ndarray) and not leftrangej_.flags.writeable:
      raise ValueError("Argument leftrangej must be writable")
    if isinstance(leftrangej_, numpy.ndarray) and leftrangej_.dtype is numpy.float64 and leftrangej_.flags.contiguous:
      _leftrangej_copyarray = False
      _leftrangej_tmp = ctypes.cast(leftrangej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftrangej_,array.ndarray) and leftrangej_.dtype is array.float64 and  leftrangej_.getsteplength() == 1:
      _leftrangej_copyarray = False
      _leftrangej_tmp = leftrangej_.getdatacptr()
    else:
      _leftrangej_copyarray = True
      _leftrangej_tmp = (ctypes.c_double * len(leftrangej_))(*leftrangej_)
    if rightrangej_ is not None and len(rightrangej_) < numj_:
      raise ValueError("Array argument rightrangej is not long enough")
    if isinstance(rightrangej_,numpy.ndarray) and not rightrangej_.flags.writeable:
      raise ValueError("Argument rightrangej must be writable")
    if isinstance(rightrangej_, numpy.ndarray) and rightrangej_.dtype is numpy.float64 and rightrangej_.flags.contiguous:
      _rightrangej_copyarray = False
      _rightrangej_tmp = ctypes.cast(rightrangej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightrangej_,array.ndarray) and rightrangej_.dtype is array.float64 and  rightrangej_.getsteplength() == 1:
      _rightrangej_copyarray = False
      _rightrangej_tmp = rightrangej_.getdatacptr()
    else:
      _rightrangej_copyarray = True
      _rightrangej_tmp = (ctypes.c_double * len(rightrangej_))(*rightrangej_)
    res = __library__.MSK_XX_primalsensitivity(self.__nativep,numi_,_subi_tmp,_marki_tmp,numj_,_subj_tmp,_markj_tmp,_leftpricei_tmp,_rightpricei_tmp,_leftrangei_tmp,_rightrangei_tmp,_leftpricej_tmp,_rightpricej_tmp,_leftrangej_tmp,_rightrangej_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _leftpricei_copyarray:
      leftpricei_[:] = _leftpricei_tmp
    if _rightpricei_copyarray:
      rightpricei_[:] = _rightpricei_tmp
    if _leftrangei_copyarray:
      leftrangei_[:] = _leftrangei_tmp
    if _rightrangei_copyarray:
      rightrangei_[:] = _rightrangei_tmp
    if _leftpricej_copyarray:
      leftpricej_[:] = _leftpricej_tmp
    if _rightpricej_copyarray:
      rightpricej_[:] = _rightpricej_tmp
    if _leftrangej_copyarray:
      leftrangej_[:] = _leftrangej_tmp
    if _rightrangej_copyarray:
      rightrangej_[:] = _rightrangej_tmp
  @accepts(_accept_any,_accept_anyenum(streamtype))
  def sensitivityreport(self,whichstream_):
    """
    Creates a sensitivity report.
  
    sensitivityreport(self,whichstream_)
      whichstream: mosek.streamtype. Index of the stream.
    """
    res = __library__.MSK_XX_sensitivityreport(self.__nativep,whichstream_)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_accept_doublevector,_accept_doublevector,_accept_doublevector,_accept_doublevector)
  def dualsensitivity(self,subj_,leftpricej_,rightpricej_,leftrangej_,rightrangej_):
    """
    Performs sensitivity analysis on objective coefficients.
  
    dualsensitivity(self,subj_,leftpricej_,rightpricej_,leftrangej_,rightrangej_)
      subj: array of int. Index of objective coefficients to analyze.
      leftpricej: array of double. Left shadow prices for requested coefficients.
      rightpricej: array of double. Right shadow prices for requested coefficients.
      leftrangej: array of double. Left range for requested coefficients.
      rightrangej: array of double. Right range for requested coefficients.
    """
    numj_ = None
    if numj_ is None:
      numj_ = len(subj_)
    else:
      numj_ = min(numj_,len(subj_))
    if subj_ is None:
      raise ValueError("Argument subj cannot be None")
    if subj_ is None:
      raise ValueError("Argument subj may not be None")
    if isinstance(subj_, numpy.ndarray) and subj_.dtype is numpy.int32 and subj_.flags.contiguous:
      _subj_copyarray = False
      _subj_tmp = ctypes.cast(subj_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subj_,array.ndarray) and subj_.dtype is array.int32 and  subj_.getsteplength() == 1:
      _subj_copyarray = False
      _subj_tmp = subj_.getdatacptr()
    else:
      _subj_copyarray = True
      _subj_tmp = (ctypes.c_int32 * len(subj_))(*subj_)
    if leftpricej_ is not None and len(leftpricej_) < numj_:
      raise ValueError("Array argument leftpricej is not long enough")
    if isinstance(leftpricej_,numpy.ndarray) and not leftpricej_.flags.writeable:
      raise ValueError("Argument leftpricej must be writable")
    if isinstance(leftpricej_, numpy.ndarray) and leftpricej_.dtype is numpy.float64 and leftpricej_.flags.contiguous:
      _leftpricej_copyarray = False
      _leftpricej_tmp = ctypes.cast(leftpricej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftpricej_,array.ndarray) and leftpricej_.dtype is array.float64 and  leftpricej_.getsteplength() == 1:
      _leftpricej_copyarray = False
      _leftpricej_tmp = leftpricej_.getdatacptr()
    else:
      _leftpricej_copyarray = True
      _leftpricej_tmp = (ctypes.c_double * len(leftpricej_))(*leftpricej_)
    if rightpricej_ is not None and len(rightpricej_) < numj_:
      raise ValueError("Array argument rightpricej is not long enough")
    if isinstance(rightpricej_,numpy.ndarray) and not rightpricej_.flags.writeable:
      raise ValueError("Argument rightpricej must be writable")
    if isinstance(rightpricej_, numpy.ndarray) and rightpricej_.dtype is numpy.float64 and rightpricej_.flags.contiguous:
      _rightpricej_copyarray = False
      _rightpricej_tmp = ctypes.cast(rightpricej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightpricej_,array.ndarray) and rightpricej_.dtype is array.float64 and  rightpricej_.getsteplength() == 1:
      _rightpricej_copyarray = False
      _rightpricej_tmp = rightpricej_.getdatacptr()
    else:
      _rightpricej_copyarray = True
      _rightpricej_tmp = (ctypes.c_double * len(rightpricej_))(*rightpricej_)
    if leftrangej_ is not None and len(leftrangej_) < numj_:
      raise ValueError("Array argument leftrangej is not long enough")
    if isinstance(leftrangej_,numpy.ndarray) and not leftrangej_.flags.writeable:
      raise ValueError("Argument leftrangej must be writable")
    if isinstance(leftrangej_, numpy.ndarray) and leftrangej_.dtype is numpy.float64 and leftrangej_.flags.contiguous:
      _leftrangej_copyarray = False
      _leftrangej_tmp = ctypes.cast(leftrangej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(leftrangej_,array.ndarray) and leftrangej_.dtype is array.float64 and  leftrangej_.getsteplength() == 1:
      _leftrangej_copyarray = False
      _leftrangej_tmp = leftrangej_.getdatacptr()
    else:
      _leftrangej_copyarray = True
      _leftrangej_tmp = (ctypes.c_double * len(leftrangej_))(*leftrangej_)
    if rightrangej_ is not None and len(rightrangej_) < numj_:
      raise ValueError("Array argument rightrangej is not long enough")
    if isinstance(rightrangej_,numpy.ndarray) and not rightrangej_.flags.writeable:
      raise ValueError("Argument rightrangej must be writable")
    if isinstance(rightrangej_, numpy.ndarray) and rightrangej_.dtype is numpy.float64 and rightrangej_.flags.contiguous:
      _rightrangej_copyarray = False
      _rightrangej_tmp = ctypes.cast(rightrangej_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(rightrangej_,array.ndarray) and rightrangej_.dtype is array.float64 and  rightrangej_.getsteplength() == 1:
      _rightrangej_copyarray = False
      _rightrangej_tmp = rightrangej_.getdatacptr()
    else:
      _rightrangej_copyarray = True
      _rightrangej_tmp = (ctypes.c_double * len(rightrangej_))(*rightrangej_)
    res = __library__.MSK_XX_dualsensitivity(self.__nativep,numj_,_subj_tmp,_leftpricej_tmp,_rightpricej_tmp,_leftrangej_tmp,_rightrangej_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    if _leftpricej_copyarray:
      leftpricej_[:] = _leftpricej_tmp
    if _rightpricej_copyarray:
      rightpricej_[:] = _rightpricej_tmp
    if _leftrangej_copyarray:
      leftrangej_[:] = _leftrangej_tmp
    if _rightrangej_copyarray:
      rightrangej_[:] = _rightrangej_tmp
  @accepts(_accept_any)
  def checkconvexity(self):
    """
    Checks if a quadratic optimization problem is convex.
  
    checkconvexity(self)
    """
    res = __library__.MSK_XX_checkconvexity(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_doublevector,_make_intvector,_make_intvector,_make_intvector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector)
  def appendvars(self,cval_,aptrb_,aptre_,asub_,aval_,bkx_,blx_,bux_):
    """
    Appends one or more variables and specifies bounds on variables, objective coefficients and matrix coefficients.
  
    appendvars(self,cval_,aptrb_,aptre_,asub_,aval_,bkx_,blx_,bux_)
      cval: array of double. Objective coefficients  for the variables to be appended.
      aptrb: array of int. Column start pointers.
      aptre: array of int. Column end pointers.
      asub: array of int. Constraint subscripts of the coefficient matrix entries to be added.
      aval: array of double. The matrix coefficients corresponding to the appended variables.
      bkx: array of mosek.boundkey. Bound keys on variables to be appended.
      blx: array of double. Lower bounds on variables to be appended.
      bux: array of double. Upper bounds on variables to be appended.
    """
    num_ = None
    if num_ is None:
      num_ = len(aptrb_)
    else:
      num_ = min(num_,len(aptrb_))
    if num_ is None:
      num_ = len(aptre_)
    else:
      num_ = min(num_,len(aptre_))
    if num_ is None:
      num_ = len(cval_)
    else:
      num_ = min(num_,len(cval_))
    if num_ is None:
      num_ = len(bkx_)
    else:
      num_ = min(num_,len(bkx_))
    if num_ is None:
      num_ = len(blx_)
    else:
      num_ = min(num_,len(blx_))
    if num_ is None:
      num_ = len(bux_)
    else:
      num_ = min(num_,len(bux_))
    if cval_ is None:
      raise ValueError("Argument cval cannot be None")
    if cval_ is None:
      raise ValueError("Argument cval may not be None")
    if isinstance(cval_, numpy.ndarray) and cval_.dtype is numpy.float64 and cval_.flags.contiguous:
      _cval_copyarray = False
      _cval_tmp = ctypes.cast(cval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(cval_,array.ndarray) and cval_.dtype is array.float64 and  cval_.getsteplength() == 1:
      _cval_copyarray = False
      _cval_tmp = cval_.getdatacptr()
    else:
      _cval_copyarray = True
      _cval_tmp = (ctypes.c_double * len(cval_))(*cval_)
    aptrb_idxof_len = min([ len(_item_) for _item_ in [asub_,aval_] if _item_ is not None ] or 0)
    for i in aptrb_:
      if i < 0 or i > aptrb_idxof_len:
        raise ValueError("Value outside valid range in argument aptrb")
    if aptrb_ is None:
      raise ValueError("Argument aptrb cannot be None")
    if aptrb_ is None:
      raise ValueError("Argument aptrb may not be None")
    if isinstance(aptrb_, numpy.ndarray) and aptrb_.dtype is numpy.int32 and aptrb_.flags.contiguous:
      _aptrb_copyarray = False
      _aptrb_tmp = ctypes.cast(aptrb_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(aptrb_,array.ndarray) and aptrb_.dtype is array.int32 and  aptrb_.getsteplength() == 1:
      _aptrb_copyarray = False
      _aptrb_tmp = aptrb_.getdatacptr()
    else:
      _aptrb_copyarray = True
      _aptrb_tmp = (ctypes.c_int32 * len(aptrb_))(*aptrb_)
    aptre_idxof_len = min([ len(_item_) for _item_ in [asub_,aval_] if _item_ is not None ] or 0)
    for i in aptre_:
      if i < 0 or i > aptre_idxof_len:
        raise ValueError("Value outside valid range in argument aptre")
    if aptre_ is None:
      raise ValueError("Argument aptre cannot be None")
    if aptre_ is None:
      raise ValueError("Argument aptre may not be None")
    if isinstance(aptre_, numpy.ndarray) and aptre_.dtype is numpy.int32 and aptre_.flags.contiguous:
      _aptre_copyarray = False
      _aptre_tmp = ctypes.cast(aptre_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(aptre_,array.ndarray) and aptre_.dtype is array.int32 and  aptre_.getsteplength() == 1:
      _aptre_copyarray = False
      _aptre_tmp = aptre_.getdatacptr()
    else:
      _aptre_copyarray = True
      _aptre_tmp = (ctypes.c_int32 * len(aptre_))(*aptre_)
    if asub_ is None:
      raise ValueError("Argument asub cannot be None")
    if asub_ is None:
      raise ValueError("Argument asub may not be None")
    if isinstance(asub_, numpy.ndarray) and asub_.dtype is numpy.int32 and asub_.flags.contiguous:
      _asub_copyarray = False
      _asub_tmp = ctypes.cast(asub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(asub_,array.ndarray) and asub_.dtype is array.int32 and  asub_.getsteplength() == 1:
      _asub_copyarray = False
      _asub_tmp = asub_.getdatacptr()
    else:
      _asub_copyarray = True
      _asub_tmp = (ctypes.c_int32 * len(asub_))(*asub_)
    if aval_ is None:
      raise ValueError("Argument aval cannot be None")
    if aval_ is None:
      raise ValueError("Argument aval may not be None")
    if isinstance(aval_, numpy.ndarray) and aval_.dtype is numpy.float64 and aval_.flags.contiguous:
      _aval_copyarray = False
      _aval_tmp = ctypes.cast(aval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(aval_,array.ndarray) and aval_.dtype is array.float64 and  aval_.getsteplength() == 1:
      _aval_copyarray = False
      _aval_tmp = aval_.getdatacptr()
    else:
      _aval_copyarray = True
      _aval_tmp = (ctypes.c_double * len(aval_))(*aval_)
    if bkx_ is None:
      raise ValueError("Argument bkx cannot be None")
    if bkx_ is None:
      raise ValueError("Argument bkx may not be None")
    _bkx_tmp_arr = array.array(bkx_,array.int32)
    _bkx_tmp = _bkx_tmp_arr.getdatacptr()
    if blx_ is None:
      raise ValueError("Argument blx cannot be None")
    if blx_ is None:
      raise ValueError("Argument blx may not be None")
    if isinstance(blx_, numpy.ndarray) and blx_.dtype is numpy.float64 and blx_.flags.contiguous:
      _blx_copyarray = False
      _blx_tmp = ctypes.cast(blx_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blx_,array.ndarray) and blx_.dtype is array.float64 and  blx_.getsteplength() == 1:
      _blx_copyarray = False
      _blx_tmp = blx_.getdatacptr()
    else:
      _blx_copyarray = True
      _blx_tmp = (ctypes.c_double * len(blx_))(*blx_)
    if bux_ is None:
      raise ValueError("Argument bux cannot be None")
    if bux_ is None:
      raise ValueError("Argument bux may not be None")
    if isinstance(bux_, numpy.ndarray) and bux_.dtype is numpy.float64 and bux_.flags.contiguous:
      _bux_copyarray = False
      _bux_tmp = ctypes.cast(bux_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(bux_,array.ndarray) and bux_.dtype is array.float64 and  bux_.getsteplength() == 1:
      _bux_copyarray = False
      _bux_tmp = bux_.getdatacptr()
    else:
      _bux_copyarray = True
      _bux_tmp = (ctypes.c_double * len(bux_))(*bux_)
    res = __library__.MSK_XX_appendvars(self.__nativep,num_,_cval_tmp,_aptrb_tmp,_aptre_tmp,_asub_tmp,_aval_tmp,_bkx_tmp,_blx_tmp,_bux_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_make_intvector,_make_intvector,_make_intvector,_make_doublevector,_make_anyenumvector(boundkey),_make_doublevector,_make_doublevector)
  def appendcons(self,aptrb_,aptre_,asub_,aval_,bkc_,blc_,buc_):
    """
    Appends one or more constraints and specifies bounds and constraint coefficients.
  
    appendcons(self,aptrb_,aptre_,asub_,aval_,bkc_,blc_,buc_)
      aptrb: array of int. Row start pointers.
      aptre: array of int. Row end pointers.
      asub: array of int. Variable subscripts of the new constraint matrix coefficients.
      aval: array of double. Matrix coefficients of the new constraints.
      bkc: array of mosek.boundkey. Bound keys for constraints to be appended.
      blc: array of double. Lower bounds on constraints to be appended.
      buc: array of double. Upper bounds on constraints to be appended.
    """
    num_ = None
    if num_ is None:
      num_ = len(bkc_)
    else:
      num_ = min(num_,len(bkc_))
    if num_ is None:
      num_ = len(blc_)
    else:
      num_ = min(num_,len(blc_))
    if num_ is None:
      num_ = len(buc_)
    else:
      num_ = min(num_,len(buc_))
    aptrb_idxof_len = min([ len(_item_) for _item_ in [asub_,aval_] if _item_ is not None ] or 0)
    for i in aptrb_:
      if i < 0 or i > aptrb_idxof_len:
        raise ValueError("Value outside valid range in argument aptrb")
    if aptrb_ is None:
      raise ValueError("Argument aptrb cannot be None")
    if aptrb_ is None:
      raise ValueError("Argument aptrb may not be None")
    if isinstance(aptrb_, numpy.ndarray) and aptrb_.dtype is numpy.int32 and aptrb_.flags.contiguous:
      _aptrb_copyarray = False
      _aptrb_tmp = ctypes.cast(aptrb_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(aptrb_,array.ndarray) and aptrb_.dtype is array.int32 and  aptrb_.getsteplength() == 1:
      _aptrb_copyarray = False
      _aptrb_tmp = aptrb_.getdatacptr()
    else:
      _aptrb_copyarray = True
      _aptrb_tmp = (ctypes.c_int32 * len(aptrb_))(*aptrb_)
    aptre_idxof_len = min([ len(_item_) for _item_ in [asub_,aval_] if _item_ is not None ] or 0)
    for i in aptre_:
      if i < 0 or i > aptre_idxof_len:
        raise ValueError("Value outside valid range in argument aptre")
    if aptre_ is None:
      raise ValueError("Argument aptre cannot be None")
    if aptre_ is None:
      raise ValueError("Argument aptre may not be None")
    if isinstance(aptre_, numpy.ndarray) and aptre_.dtype is numpy.int32 and aptre_.flags.contiguous:
      _aptre_copyarray = False
      _aptre_tmp = ctypes.cast(aptre_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(aptre_,array.ndarray) and aptre_.dtype is array.int32 and  aptre_.getsteplength() == 1:
      _aptre_copyarray = False
      _aptre_tmp = aptre_.getdatacptr()
    else:
      _aptre_copyarray = True
      _aptre_tmp = (ctypes.c_int32 * len(aptre_))(*aptre_)
    if asub_ is None:
      raise ValueError("Argument asub cannot be None")
    if asub_ is None:
      raise ValueError("Argument asub may not be None")
    if isinstance(asub_, numpy.ndarray) and asub_.dtype is numpy.int32 and asub_.flags.contiguous:
      _asub_copyarray = False
      _asub_tmp = ctypes.cast(asub_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(asub_,array.ndarray) and asub_.dtype is array.int32 and  asub_.getsteplength() == 1:
      _asub_copyarray = False
      _asub_tmp = asub_.getdatacptr()
    else:
      _asub_copyarray = True
      _asub_tmp = (ctypes.c_int32 * len(asub_))(*asub_)
    if aval_ is None:
      raise ValueError("Argument aval cannot be None")
    if aval_ is None:
      raise ValueError("Argument aval may not be None")
    if isinstance(aval_, numpy.ndarray) and aval_.dtype is numpy.float64 and aval_.flags.contiguous:
      _aval_copyarray = False
      _aval_tmp = ctypes.cast(aval_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(aval_,array.ndarray) and aval_.dtype is array.float64 and  aval_.getsteplength() == 1:
      _aval_copyarray = False
      _aval_tmp = aval_.getdatacptr()
    else:
      _aval_copyarray = True
      _aval_tmp = (ctypes.c_double * len(aval_))(*aval_)
    if bkc_ is None:
      raise ValueError("Argument bkc cannot be None")
    if bkc_ is None:
      raise ValueError("Argument bkc may not be None")
    _bkc_tmp_arr = array.array(bkc_,array.int32)
    _bkc_tmp = _bkc_tmp_arr.getdatacptr()
    if blc_ is None:
      raise ValueError("Argument blc cannot be None")
    if blc_ is None:
      raise ValueError("Argument blc may not be None")
    if isinstance(blc_, numpy.ndarray) and blc_.dtype is numpy.float64 and blc_.flags.contiguous:
      _blc_copyarray = False
      _blc_tmp = ctypes.cast(blc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(blc_,array.ndarray) and blc_.dtype is array.float64 and  blc_.getsteplength() == 1:
      _blc_copyarray = False
      _blc_tmp = blc_.getdatacptr()
    else:
      _blc_copyarray = True
      _blc_tmp = (ctypes.c_double * len(blc_))(*blc_)
    if buc_ is None:
      raise ValueError("Argument buc cannot be None")
    if buc_ is None:
      raise ValueError("Argument buc may not be None")
    if isinstance(buc_, numpy.ndarray) and buc_.dtype is numpy.float64 and buc_.flags.contiguous:
      _buc_copyarray = False
      _buc_tmp = ctypes.cast(buc_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_double))
    elif isinstance(buc_,array.ndarray) and buc_.dtype is array.float64 and  buc_.getsteplength() == 1:
      _buc_copyarray = False
      _buc_tmp = buc_.getdatacptr()
    else:
      _buc_copyarray = True
      _buc_tmp = (ctypes.c_double * len(buc_))(*buc_)
    res = __library__.MSK_XX_appendcons(self.__nativep,num_,_aptrb_tmp,_aptre_tmp,_asub_tmp,_aval_tmp,_bkc_tmp,_blc_tmp,_buc_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def startstat(self):
    """
    Starts the statistics file.
  
    startstat(self)
    """
    res = __library__.MSK_XX_startstat(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def stopstat(self):
    """
    Stops the statistics file.
  
    stopstat(self)
    """
    res = __library__.MSK_XX_stopstat(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any)
  def appendstat(self):
    """
    Appends a record the statistics file.
  
    appendstat(self)
    """
    res = __library__.MSK_XX_appendstat(self.__nativep)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(conetype),_make_double,_make_int,_make_intvector)
  def core_appendcones(self,conetype_,conepar_,nummem_,submem_):
    """
    Append a list of identical cones.
  
    core_appendcones(self,conetype_,conepar_,nummem_,submem_)
      conetype: mosek.conetype. Specifies the type of the cone.
      conepar: double. This argument is currently not used. Can be set to 0.0.
      nummem: int. Number of member variables in the cone.
      submem: array of int. Variable subscripts of the members in the cone.
    returns: coneidx
      coneidx: int. Index of the first new cone.
    """
    numsub_ = None
    if numsub_ is None:
      numsub_ = len(submem_)
    else:
      numsub_ = min(numsub_,len(submem_))
    if submem_ is None:
      raise ValueError("Argument submem cannot be None")
    if submem_ is None:
      raise ValueError("Argument submem may not be None")
    if isinstance(submem_, numpy.ndarray) and submem_.dtype is numpy.int32 and submem_.flags.contiguous:
      _submem_copyarray = False
      _submem_tmp = ctypes.cast(submem_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(submem_,array.ndarray) and submem_.dtype is array.int32 and  submem_.getsteplength() == 1:
      _submem_copyarray = False
      _submem_tmp = submem_.getdatacptr()
    else:
      _submem_copyarray = True
      _submem_tmp = (ctypes.c_int32 * len(submem_))(*submem_)
    coneidx_ = ctypes.c_int32()
    coneidx_ = ctypes.c_int32()
    res = __library__.MSK_XX_core_appendcones(self.__nativep,conetype_,conepar_,nummem_,numsub_,_submem_tmp,ctypes.byref(coneidx_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _coneidx_return_value = coneidx_.value
    return (_coneidx_return_value)
  @accepts(_accept_any,_make_intvector)
  def core_removecones(self,subk_):
    """
    Remove a list of cones.
  
    core_removecones(self,subk_)
      subk: array of int. Indices of cones to remove.
    """
    num_ = None
    if num_ is None:
      num_ = len(subk_)
    else:
      num_ = min(num_,len(subk_))
    if subk_ is None:
      raise ValueError("Argument subk cannot be None")
    if subk_ is None:
      raise ValueError("Argument subk may not be None")
    if isinstance(subk_, numpy.ndarray) and subk_.dtype is numpy.int32 and subk_.flags.contiguous:
      _subk_copyarray = False
      _subk_tmp = ctypes.cast(subk_.ctypes._as_parameter_,ctypes.POINTER(ctypes.c_int32))
    elif isinstance(subk_,array.ndarray) and subk_.dtype is array.int32 and  subk_.getsteplength() == 1:
      _subk_copyarray = False
      _subk_tmp = subk_.getdatacptr()
    else:
      _subk_copyarray = True
      _subk_tmp = (ctypes.c_int32 * len(subk_))(*subk_)
    res = __library__.MSK_XX_core_removecones(self.__nativep,num_,_subk_tmp)
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
  @accepts(_accept_any,_accept_anyenum(accmode),_make_int)
  def core_append(self,accmode_,num_):
    """
    Appends a number of variables or constraints to the optimization task.
  
    core_append(self,accmode_,num_)
      accmode: mosek.accmode. Defines if operations are performed row-wise (constraint-oriented) or column-wise (variable-oriented).
      num: int. Number of constraints or variables which should be appended.
    returns: first
      first: int. Returns the index of the first appended variable.
    """
    first_ = ctypes.c_int32()
    first_ = ctypes.c_int32()
    res = __library__.MSK_XX_core_append(self.__nativep,accmode_,num_,ctypes.byref(first_))
    if res != 0:
      result,msg = self.__getlasterror(res)
      raise Error(rescode(result),msg)
    _first_return_value = first_.value
    return (_first_return_value)





if __name__ == '__main__':
    env = Env()
