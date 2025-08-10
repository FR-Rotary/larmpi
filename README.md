# LarmPI Raspberry Pi image generator

I detta repo är hela systembilden av larmPIn lagrad så att det går att skapa nya systembilder i det fall att de befintliga förstörs och att larmPIns SD-kort gett upp.

För att generera en ny systembild behövs några saker göras för att infoga secrets i larmd deamonen och användarkontot på operativsystemet.

1. Skapa en ny secrets-fil med `cp example.secrets secrets`
2. Gör den exekverbar med `chmod +x secrets`
3. Fyll i `secrets` med relevant inloggningsinformation till mariadb/mysql databasen och välj ett username/password kombo för användaren.
4. Kör initskriptet med `./init.sh`
5. Starta bygget med `./docker-build.sh`

Bygget tar några timmar att bli klar, men efter det så ska den nya systembilden finnas i `./deploy`.
För att flasha ett SD-kort med denna nya systembild så använder du med fördel `dd`. Kolla upp online för hur man gör det.
(Kom ihåg att systembilden är komprimerad i ett zip-arkiv, så dekomprimera den innan användning)

