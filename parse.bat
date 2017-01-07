@ECHO OFF

SET GRAMMARNAME=oethel.antlr.Oethel
SET JAVA_TARGET_DIR=java
SET JAVA_TARGET_OUT_DIR=out

IF [%1]==[] GOTO USAGE

IF NOT DEFINED JAVA_HOME (
ECHO JAVA_HOME environment variable is not defined ! Create it and indicate JDK location as value.
EXIT /B 203
)

IF NOT DEFINED CLASSPATH (
ECHO CLASSPATH environment variable is not defined ! Create it with ".;antlr_jar_path" as value.
EXIT /B 203
)

CD "%JAVA_TARGET_DIR%/%JAVA_TARGET_OUT_DIR%/"

"%JAVA_HOME%\bin\java.exe" -cp "%CLASSPATH%" org.antlr.v4.gui.TestRig %GRAMMARNAME% parse <../../%*
IF errorlevel 1 (
ECHO Failed to open tree!
CD ../..
EXIT /B 1
)

CD ../..
EXIT /B 0

:USAGE
@echo Usage: %0 ^<File^>