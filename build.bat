@ECHO OFF

SET GRAMMARNAME=Oethel
SET PARSERNAME=OethelParser
SET LEXERNAME=OethelLexer
SET PACKAGE=oethel.antlr
SET JAVA_TARGET_DIR=java
SET JAVA_TARGET_SRC_DIR=src/oethel/antlr
SET JAVA_TARGET_OUT_DIR=out

IF NOT DEFINED JAVA_HOME (
ECHO JAVA_HOME environment variable is not defined ! Create it and indicate JDK location as value.
EXIT /B 203
)

IF NOT DEFINED CLASSPATH (
ECHO CLASSPATH environment variable is not defined ! Create it with ".;antlr_jar_path" as value.
EXIT /B 203
)

IF EXIST "%JAVA_TARGET_DIR%/%JAVA_TARGET_SRC_DIR%" RMDIR /S /Q "%JAVA_TARGET_DIR%/%JAVA_TARGET_SRC_DIR%"

ECHO Compile grammar to Java...

"%JAVA_HOME%\bin\java.exe" -cp "%CLASSPATH%" org.antlr.v4.Tool "%LEXERNAME%.g4" -o "%JAVA_TARGET_DIR%/%JAVA_TARGET_SRC_DIR%/" -package "%PACKAGE%" -no-listener -visitor
IF errorlevel 1 (
ECHO Compilation failed!
EXIT /B %errorlevel%
)

"%JAVA_HOME%\bin\java.exe" -cp "%CLASSPATH%" org.antlr.v4.Tool "%PARSERNAME%.g4" -o "%JAVA_TARGET_DIR%/%JAVA_TARGET_SRC_DIR%/" -package "%PACKAGE%" -no-listener -visitor
IF errorlevel 1 (
ECHO Compilation failed!
EXIT /B %errorlevel%
)

ECHO Compilation completed.

ECHO Build Java...

IF EXIST "%JAVA_TARGET_DIR%/%JAVA_TARGET_OUT_DIR%" RMDIR /S /Q "%JAVA_TARGET_DIR%/%JAVA_TARGET_OUT_DIR%"
MKDIR "%JAVA_TARGET_DIR%/%JAVA_TARGET_OUT_DIR%"

"%JAVA_HOME%\bin\javac.exe" -cp "%CLASSPATH%" -d "%JAVA_TARGET_DIR%/%JAVA_TARGET_OUT_DIR%/" "%JAVA_TARGET_DIR%/%JAVA_TARGET_SRC_DIR%/%GRAMMARNAME%"*.java
IF errorlevel 1 (
ECHO Build failed!
EXIT /B %errorlevel%
)

ECHO Build completed.

EXIT /B 0