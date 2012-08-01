#!/bin/bash
# Download Croatian Tax data. Copright(C) 2012 Kost. Distributed under GNU GPL. 

mkdir fo
cd fo
for i in {1..131}
do
	echo "Downloading fizicke $i"
	wget http://duznici.porezna-uprava.hr/fo/svi/$i.html
done
cd ..

mkdir po
cd po
for i in {1..72}
do
	echo "Downloading pravne $i"
	wget http://duznici.porezna-uprava.hr/po/svi/$i.html
done
cd ..

mkdir gr
cd gr
for i in {1..822}
do
	echo "Downloading ostalo $i"
	wget http://duznici.porezna-uprava.hr/gr/svi/$i.html
done
cd ..

