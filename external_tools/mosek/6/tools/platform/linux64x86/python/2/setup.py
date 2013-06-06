
from distutils.core import setup
import platform,sys


major,minor,_,_,_ = sys.version_info
if major != 2 or minor < 5:
    print "Python 2.5+ required, got %d.%d" % (major,minor)

pf = platform.system()
ext_suffix = {
    'Linux'   : '.so',
    'Darwin'  : '.so',
    'Win32'   : '.pyd',
    'Windows' : '.pyd',
    'SunOS'   : '.so',
    }


try:
    sfx = ext_suffix[pf]
except KeyError:
    print "Unknown platform '%s'. Failed to install." % pf
    sys.exit(1)

setup(name='Mosek',
      version      = '6.0.136',
      description  = 'Mosek/Python APIs',
      author       = 'Ulf Worsoe, Mosek ApS',
      author_email = "ulf.worsoe@mosek.com",
      url          = 'http://www.mosek.com',
      packages     = [ 'mosek'],
      package_data = { 'mosek' : [ '_array%s' % sfx ] },
      )
