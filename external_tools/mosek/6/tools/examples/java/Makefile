# GMake or MS NMake / Sun Java
#
# This file can be used on all Java supporting 
# platforms by modifying the paths to mosek.jar

MOSEKJAR=../../platform/linux64x86/bin/mosek.jar
JAVAC=javac
JAVAJAR=jar

EXAMPLES=lo1.jar \
         lo2.jar \
         cqo1.jar \
         concurrent1.jar \
         milo1.jar \
         production.jar \
         mioinitsol.jar \
         qcqo1.jar \
         qo1.jar \
         simple.jar \
         sensitivity.jar \
         feasrepairex1.jar 

lo1.jar: lo1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . lo1.java
	$(JAVAJAR) cvf lo1.jar lo1

lo2.jar: lo2.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . lo2.java
	$(JAVAJAR) cvf lo2.jar lo2

cqo1.jar: cqo1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . cqo1.java
	$(JAVAJAR) cvf cqo1.jar cqo1

concurrent1.jar: concurrent1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . concurrent1.java
	$(JAVAJAR) cvf concurrent1.jar concurrent1

milo1.jar: milo1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . milo1.java
	$(JAVAJAR) cvf milo1.jar milo1

production.jar: production.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . production.java
	$(JAVAJAR) cvf production.jar production

mioinitsol.jar: mioinitsol.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . mioinitsol.java
	$(JAVAJAR) cvf mioinitsol.jar mioinitsol

qcqo1.jar: qcqo1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . qcqo1.java
	$(JAVAJAR) cvf qcqo1.jar qcqo1

qo1.jar: qo1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . qo1.java
	$(JAVAJAR) cvf qo1.jar qo1

simple.jar: simple.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . simple.java
	$(JAVAJAR) cvf simple.jar simple

sensitivity.jar: sensitivity.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . sensitivity.java
	$(JAVAJAR) cvf sensitivity.jar sensitivity

feasrepairex1.jar: feasrepairex1.java
	$(JAVAC) -classpath $(MOSEKJAR) -d . feasrepairex1.java
	$(JAVAJAR) cvf feasrepairex1.jar feasrepairex1


all: $(EXAMPLES)
