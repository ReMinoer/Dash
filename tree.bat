@ECHO OFF

IF [%1]==[] GOTO USAGE

IF NOT DEFINED JAVA_HOME (
ECHO JAVA_HOME environment variable is not defined ! Create it and indicate JDK location as value.
EXIT /B 203
)

IF NOT DEFINED CLASSPATH (
ECHO CLASSPATH environment variable is not defined ! Create it with ".;antlr_jar_path" as value.
EXIT /B 203
)

CD "java/bin/"

ECHO Show parsing tree...

"%JAVA_HOME%\bin\java.exe" -cp "%CLASSPATH%" org.antlr.v4.gui.TestRig Oethel parse -gui <../../%*
IF errorlevel 1 (
ECHO Failed to open tree!
EXIT /B 1
)

ECHO Parsing tree closed.

CD ../..
EXIT /B 0

:USAGE
@echo Usage: %0 ^<File^>