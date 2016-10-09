@ECHO OFF

IF NOT DEFINED JAVA_HOME (
ECHO JAVA_HOME environment variable is not defined ! Create it and indicate JDK location as value.
EXIT /B 203
)

IF NOT DEFINED CLASSPATH (
ECHO CLASSPATH environment variable is not defined ! Create it with ".;antlr_jar_path" as value.
EXIT /B 203
)

RMDIR /S /Q "java/"

ECHO Compile grammar to Java...

"%JAVA_HOME%\bin\java.exe" -cp "%CLASSPATH%" org.antlr.v4.Tool Oethel.g4 -o "java/"
IF errorlevel 1 (
ECHO Compilation failed!
EXIT /B %errorlevel%
)

ECHO Compilation completed.

CD "java/"

ECHO Build Java...

IF NOT EXIST "bin/" MKDIR "bin/"
"%JAVA_HOME%\bin\javac.exe" -cp "%CLASSPATH%" -d "bin/" Oethel*.java
IF errorlevel 1 (
ECHO Build failed!
CD ..
EXIT /B %errorlevel%
)

ECHO Build completed.

CD ..
EXIT /B 0