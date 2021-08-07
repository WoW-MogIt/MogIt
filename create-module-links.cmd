@ECHO OFF

CD ..
MKLINK /J MogIt_Artifact MogIt\Modules\MogIt_Artifact
MKLINK /J MogIt_Cloth MogIt\Modules\MogIt_Cloth
MKLINK /J MogIt_Leather MogIt\Modules\MogIt_Leather
MKLINK /J MogIt_Mail MogIt\Modules\MogIt_Mail
MKLINK /J MogIt_Plate MogIt\Modules\MogIt_Plate
MKLINK /J MogIt_Other MogIt\Modules\MogIt_Other
MKLINK /J MogIt_OneHanded MogIt\Modules\MogIt_OneHanded
MKLINK /J MogIt_TwoHanded MogIt\Modules\MogIt_TwoHanded
MKLINK /J MogIt_Ranged MogIt\Modules\MogIt_Ranged

ECHO.
PAUSE
