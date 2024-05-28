.ONESHELL:

build:
	@ECHO OFF
	bash release.sh -d

update:
	@ECHO OFF
	FOR %%I IN (.) DO SET PROJECTNAME=%%~nxI
	SET OUTPUTDIR=.release\%PROJECTNAME%
	bash release.sh -cdlz
	ROBOCOPY /E /NFL /NDL /NJH /NJS %OUTPUTDIR%\Libs Libs
