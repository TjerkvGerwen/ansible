# Uitleg
**In part 1 worden 2 repositorys toegevoegd. Dit geeft problemen zolang de machine niet gerestart is. Daarom is er een part 2. Zodra de machine is geherstart kun je part 2 runnen en zal de machine toegevoegd worden aan de Active Directory.**
## Requirements
Je moet een DHCP hebben draaien die automatisch de dns goed instelt anders moet je deze handmatig zelf toevoegen.

## Aanpassen
**Part 1**
* geen aanpassingen nodig

**Part 2**
* regel 3, pas hier de hosts op aan
* regel 10, pas hier je hostname aan
* regel 38, plaats hier je domain
* regel 42, plaats hier je wachtwoord, user en domain
* regel 43, plaats hier de security group die toegang hebben tot ssh 

### Installed packages after run
* realmd 
* libnss-sss 
* libpam-sss 
* sssd 
* sssd-tools 
* adcli 
* samba-common-bin 
* oddjob 
* oddjob-mkhomedir 
* packagekit
