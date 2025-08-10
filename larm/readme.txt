Larmstatushårdvara

2012-02-27: Första installation av Daniel Vindevåg (daniel@vindevag.com).
2012-04-10: Förkopplingsmotstånd till optokopplaren utbytta.
2012-07-08: Fixat möjlighet att uppdatera firmware.
2013-04-26: Uppdatering av firmware, smärre buggfixar.
2013-10-13: Uppdatering av firmware och daemon, smärre buggfixar. Lagt till kretsschema nedan.
2024-11-15: Uppdaterat för nytt subnät, smärre fixar i larmd


Hårdvara
--------

Larmhårdvaran är en Atmel AVR ATMEGA32U2, en 8-bitars microcontroller med USB interface. Den enumereras som en USB Communicaton Device Class, CDC, dvs en virtuell com-port; under linux nås den som /dev/ttyACM[n], med bifogad udev regel sym-länkas den till /dev/larm. Det går att ansluta till den med ett terminalprogram (e.g. cutecom), med 8 bitar, en stoppbit, ingen paritetsbit, hastighet spelat ingen roll (dvs standardinställningar). Hårdvaran accepterar både LF och (CR LF) som radbrytningar, men skickar själv (CR LF).

Som USB enhet identiferar den sig som VID 0403 (Future Technology Devices International, Ltd) och PID 9135. PID är unikt och är tilldelat mig personligen för användande med FTDI's kretsar (mao bryter jag mot deras licensavtal då jag använder den med en Atmel).

Hårdvaran mäter närvaron av en spänning och rapporterar förändring genom att skicka ON resp OFF, filtrering sker mot transienter så ett nytt värde skall upprätthållas under några hundra ms för att rapporteras. Aktuell status kan kollas med kommandot "atstatus" som ger ON eller OFF. När larmet är aktivt lyser lysdioden på kretsen.

Hårdvaran accepterar följande kommandon, allt annat ignoreras.

	atstatus	Ger larmstatus, dvs ON eller OFF
	atv			Ger versionsnummer, Unix timestamp kompileringstid
	atflash		Går in i firmware update mode, dvs. hoppar till DFU bootloader


Ingången går till en optokopplare (PC817) förkopplat med (2,7+2,7) KOhm, optokopplaren har ett spänningsfall på 1V, detta ger en ström på 2,04mA då larmet ger 12V. Optokopplaren gör att larmet är helt galvaniskt issolerad från datorn.

Optokopplarens optimala arbetsström är 2mA, då ger den 1:1 överföring; maximala in-spänningen är 35V.

Optokopplaren är känslig för elektrostatisk urladdning och spänningstransienter, om kretsen slutar registrera förändringar i larmstatus kan det betyda att den behöver bytas ut.

Kretsen är kopplad till larmet med en cat5 tp kabel där de helfärgade kablarna är sammanslagna och kopplade till positiv och de tvåfärgade sammanslagna och kopplad till negativ. I larmet är positiv kopplad till AUX+ (som alltid är +12v) och negativ är kopplad till PGM1 (som jordar ner då larmet är aktiverat).
PGM1 kan enligt manualen sänka 50mA, och på den är lysdioden i dörren inkopplad (som gissningsvis drar runt 20mA).

På ingångsidan till microcontrollen (mot optokopplaren) sitter en 10KOhm pullup, dvs ingången (PORTD1) är normalt hög, men blir låg då spänning detekteras (dvs larmet slås på). Detta betyder att om larmkabeln är utdragen kommer detta registreras som att larmet är av (logiskt för en gång skull).

Microcontrollern sitter på ett utvecklingskort från MattairTech.
http://www.mattairtech.com/index.php/development-boards/mt-db-u2.html
På detta kort är det pålött ett motstånd på 10KOhm mellan PORTD7 och VCC, detta är inte relaterat till larmfunktionen utan för att bootloader/firmware upgrade skall fungera korrekt.


                                PC817    
                            ______________        10k
             2k7     2k7    |            |   +---/\/\/---> VCC    (Röd)
   AUX+ <---/\/\/---/\/\/---|--+         |4  |
   (Helfärgade)            1|  |  \   | /|---+-----------> PORTD1 (Grön)
                            |  V  \V  |/ |
                            | ---  V  |\ |
                           2|  |      | V|---------------> GND    (Svart)
   PGM1 <-------------------|--+         |3
   (Tvåfärgade)             |____________|



Mjukvara
--------

Mjukvaran är ett enkelt perlscript som slänger in förändringar av larmstatus i en mySQL-databas på IN-Maskinen, web-scripten jobbar enbart mot databasen. Funktionen är givetvis beroende av att pubdatorn går. Programmet uppdaterar även pubens MSN-status, för att detta skall fungera måste programmet köra som användare rockpullan, detta anges i programmet och fungerar korrekt om det startas som root med init script. Programmet hanterar att hårdvaran försvinner under max 20 minuter, är den urkopplad kortare tid behöver demonen mao inte startas om. Loggning sker till syslog och kan ses med

	cat /var/log/larmd/larm_puben.log 

Det finns ett bash-alias, larmlog, som ger samma resultat.

Programmet startas vid uppstart via /etc/rc.local
Annars mauellt med nedanstående; programmet droppar priviligerier till rockpullan:rockpullan och går i deamon mode.

       sudo /home/rockpullan/bin/larm/larmd
       

IN-maskinen kollar om pubdatorn är igång var 5:e minut, ifall den är nere två gånger i rad läggs larmstatus -1 (okänd status) in i databasen, detsamma gäller om programmet inte får kontakt med hårdvaran.



Firmware
--------

Firmware är skriven i avr-gcc med LUFA, en öppen källkods USB stack under MIT licensen. Att uppdatera firmware kräver avrdude eller dfu-programmer. Källkod bifogas, larm.c. Kompilering sker med avr-gcc genom att köra kommandot

	make

Dependencies för att kompilera

	sudo apt-get install gcc-avr avr-libc dfu-programmer



Uppdatera Firmware
------------------

Uppdatera firmware görs genom att ställa kretsen i programmeringsläge, detta kan göras på två sätt:

a) Skicka kommandot atflash
	echo "atflash" > /dev/larm

eller

b) Bygla kortet med en jumper och trycka reset eller koppla in/ur kretsen.

När kretsen är i firmware update läge identifierar den sig som (lsusb)

	03eb:2ff0 Atmel Corp.

För att ladda upp ny firmware används dfu-programmer, genom att köra

	dfu-programmer atmega32u2 erase
	dfu-programmer atmega32u2 flash larm.hex
	dfu-programmer atmega32u2 start

Den bifogade makefile innehåller ett makro som kör samtliga kommandon

	make flash

Jag skrev ett kort bash-script, flash.sh som gör detsamma.

Det går även att programmera kretsen med en programmerare genom 6-pinnars-kontakten. Det görs med avrdude med kommandot

	make program


