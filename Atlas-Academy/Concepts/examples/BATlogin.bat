REM Turn off echo response
@ECHO OFF

REM -------------------------------------------------------------------------
REM Map drive letter "N" to "Common" share on Server1
REM after deleting any drive mapped to the letter "n"
net use n: /d
net use n: \\server1\common

REM -------------------------------------------------------------------------
REM Map drive letter "P" to "Accounting" share on Server2
REM after deleting any drive mapped to the letter "p"
net use p: /d
net use p: \\Server2\Accounting

REM -------------------------------------------------------------------------
REM Map drive letter "S" to "Scans" share on Server1
REM after deleting any drive mapped to the letter "s"
net use s: /d
net use s: \\server1\Scans

REM -------------------------------------------------------------------------
REM deleting any drive mapped to the letter "u"
net use u: /d

REM -------------------------------------------------------------------------
REM Map drive letter "U" to User's Home drive share on Server1
REM Use variable for username so each user has their own folder
net use U: \\server2\users\%username% /persistent:yes
