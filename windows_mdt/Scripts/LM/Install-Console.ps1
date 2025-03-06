$erroractionpreference=0 ; 
$progresspreference=0 ; 
cd / ; 
md temp ; 
cd temp ; 
wget "http://lm-webserver.lm.local/software/chocolatey/nuggets/archived/consolez.1.19.0.19105.nupkg" -out "consolez.1.19.0.19105.nupkg"
choco upgrade -yf .\consolez.1.19.0.19105.nupkg ; 
rm -f .\consolez.1.19.0.19105.nupkg ; 
