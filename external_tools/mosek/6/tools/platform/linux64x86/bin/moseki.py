import code,sys,re,os

intro = '''
Welcome to MOSEK (tm) interactive shell.

To exit this shell, enter "exit". To print an introduction to the 
interactive prompt enter "intro".
'''

longintro = '''
Introduction to the MOSEK (tm) interactive shell.
The complete Python/Mosek interface is available, and any python code 
can be evaluated from this command line. See
  http://docs.python.org/tutorial/
for an introduction to the Python language, and "The MOSEK Python API manual" 
manual for an introduction to the MOSEK interface. 

To start the interactive help system, enter "help()". To get help on any 
specific item, use "help(item)", e.g. "help(mosek.Task)". Furthermore, 
following non-python commands are available:
  exit           - exit the command line.
  intro          - print a long introduction.
  read FILENAME  - read a problem file into the default task.
  write FILENAME - write the default task to a file.
  solve          - optimize the default task.
  clear          - reset the default task.
  load FILENAME  - load python code from a file.
'''

if __name__ == '__main__':
    sys.path.append(os.path.join(os.path.dirname(sys.argv[0]),'..','python','2'))

    import mosek
    import mosek.array
    import traceback
    
    localsd = {}

    cmdre = re.compile(r'\S*(?P<kw>exit|bye|intro|clear|solve|read|write|load)(?:\s+(?:"(?P<dqstr>[^"]*)"|\'(?P<sqstr>[^\']*)\'|(?P<str>\S+)))?')

    def readline(prompt):
        sys.stdout.write('mosek$ ')
        sys.stdout.flush()
        l = sys.stdin.readline()
        
        if not l:
            raise EOFError('Env of input')

        o = cmdre.match(l)
        if  o is not None and o.group('kw') is not None:
            kw = o.group('kw')
            arg = o.group('dqstr') or o.group('sqstr') or o.group('str')

            if   kw in ['exit','bye']:
                raise EOFError('End of input')
            elif kw == 'intro':
                sys.stdout.write(longintro)
                sys.stdout.flush()
            elif kw == 'load':
                # load code from external file
                try:
                    if arg:
                        execfile(arg,localsd)
                        print 'ok'
                    else:
                        print 'missing filename'
                except:
                    print "ASDFASDF"
                    traceback.print_exc()
            elif kw == 'read':
                if arg:
                    try:
                        localsd['__task__'].readdata(arg)
                        print 'ok'
                    except:
                        traceback.print_exc()
                else:
                    print 'missing filename'
            elif kw == 'write':
                if arg:
                    try:
                        localsd['__task__'].writedata(arg)
                        print 'ok'
                    except:
                        traceback.print_exc()
                else:
                    print 'missing filename'
            elif kw == 'solve':
                try:
                    res = localsd['__task__'].optimize()
                    print res
                except:
                    traceback.print_exc()

            elif kw == 'clear':
                try:
                    localsd['__task__'] = e.Task()
                except:
                    traceback.print_exc()
            l = '\n'



        return l
    

    import mosek
    import mosek.array

    e = mosek.Env()
    t = e.Task()
    
    localsd['mosek'] = mosek
    localsd['array'] = mosek.array
    localsd['__env__'] = mosek.Env()
    localsd['Task'] = localsd['__env__'].Task
    t = localsd['Task']()
    localsd['__task__'] = t
    
    noimport = ['mosek','Task','array','Enum','EnumBase']

    for s in dir(mosek):
        if s and s[0] != '_' and s not in noimport: 
            localsd[s] = getattr(mosek,s)
    for s in dir(t):
        if s and s[0] != '_': 
            localsd[s] = getattr(t,s)  

    #con = code.InteractiveInterpreter()
    print sys.argv
    if len(sys.argv) > 1:
        del sys.argv[0] # shift arguments as if the new script
        execfile(sys.argv[0],localsd)
    else:
        try:
            code.interact(intro,readline,localsd)
        except Exception,e:
            import traceback
            traceback.print_exc()
            print e

        print "Bye."


