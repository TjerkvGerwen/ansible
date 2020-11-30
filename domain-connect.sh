############### BEGINNING OF SCRIPT #######################
# Save this as domain-connect.sh

#!/bin/bash

######################################################################
# Author: Vepr                                                       #
# Script that adds Linux Computer to Active Directory using Winbind. #
#                                                                    #
# Filename: domain-connect.sh                                        #
#                                                                    #
# Usage:                                                             #
# $ chmod 755 domain-connect.sh                                      #
# $ sudo ./domain-connect.sh                                         #
#                                                                    #
# Make sure date/time on your servers are synced up.                 #
#                                                                    #
######################################################################

# This script is for newly installed systems.  It overwrites files
# /etc/samba/smb.conf, /etc/hosts, /etc/resolv.conf, /etc/nsswitch.conf,
# /etc/krb5.conf, /etc/pam.d/common-auth, and /etc/ntp.conf
# Make sure you backup these files if you have already edited them.

##########################
##### USER VARIABLES #####

# Type in your domain name: (example.local)
DOMAIN='doekoe.local'

# Type the fully qualified domain name for the domain controller:
DC='win-seraphine.doekoe.local'

# Type the domain controller IP address:
DCIP='39.0.0.5'

# If not done already, you will need to update /etc/hosts and possibly /etc/resolv.conf before running the rest of this script.
# Do you want this script to automatically update /etc/hosts and /etc/resolv.conf?
UPDATE_FILES='y'

##### END USER VARIABLES #####
#############################

# Remove extension from domain name
REMOVE_EXTENSION=${DOMAIN%.*}
# Change domain name to all caps with extension removed
REMOVE_EXTENSION_CAPS=${REMOVE_EXTENSION^^}
# Change complete domain to all caps
COMPLETE_DOMAIN_CAPS=${DOMAIN^^}

# Remove extension from domain controller 1 name
REMOVE_EXTENSION_DC1=${DC%.*}
SHORT_DC1=${REMOVE_EXTENSION_DC1%.*}

# Remove extension from domain controller 1 name
REMOVE_EXTENSION_DC2=${DC2%.*}
SHORT_DC2=${REMOVE_EXTENSION_DC2%.*}

# if user types 'y'
if [ $UPDATE_FILES = 'y' ];
then

##########################################
    ######### Update /etc/resolv.conf ####

    # comment out /etc/resolv.conf and add new lines
    cp /etc/resolv.conf /etc/resolv.conf.tmp
    sed 's/^/#/' /etc/resolv.conf.tmp > /etc/resolv.conf
    rm /etc/resolv.conf.tmp

    resolv=""
    resolv+="nameserver $DCIP \n"
    resolv+="search $DOMAIN \n"

    echo -e "\n$resolv" >> /etc/resolv.conf # -e allows the new line

    # Check if domain controller 2 variable is empty
    if [ -z "$DC2" ]
    then
        #echo "\$DC2 is empty."
        echo ' '
    else
    # If available, add domain controller 2 below primary domain controller in /etc/resolv.conf
        sed -i 'nameserver '$DCIP'/a \
         nameserver '$DC2IP /etc/resolv.conf
    fi

##########################################
    ### Update /etc/hosts ################

    hosts="\n$DCIP    $SHORT_DC1   $DC"
    echo -e "$hosts" >> /etc/hosts  # -e allows the new line

    # Check if domain controller 2 variable is empty
    if [ -z "$DC2" ]
    then
        #echo "\$DC2 is empty."
        echo ' '
    else
    # If available, add domain controller 2 below primary domain controller in /etc/hosts
        hosts2="$DC2IP    $SHORT_DC2    $DC2"
        echo -e "$hosts2" >> /etc/hosts
    fi
fi

echo ' '
echo 'Files updated.'

##########################################
    ######### Update /etc/krb5.conf ######

cp /etc/krb5.conf /etc/krb5.original
truncate -s0 /etc/krb5.conf

krb=""
krb+="[libdefaults] \n"
krb+="ticket_lifetime = 24000 \n"
krb+="default_realm = $COMPLETE_DOMAIN_CAPS \n"
krb+="default_tgs_enctypes = rc4-hmac des-cbc-md5 \n"
krb+="default_tkt_enctypes = rc4-hmac des-cbc-md5 \n"
krb+="permitted_enctypes = rc4-hmac des-cbc-md5 \n"
krb+="dns_lookup_realm = true \n"
krb+="dns_lookup_kdc = true \n"
krb+="dns_fallback = yes \n"
krb+=" \n"
krb+="[realms] \n"
krb+="$COMPLETE_DOMAIN_CAPS = { \n"
krb+="  kdc = $DC \n"
krb+="  default_domain = $DOMAIN \n"
krb+="} \n"
krb+=" \n"
krb+="[domain_realm] \n"
krb+=".$DOMAIN = $COMPLETE_DOMAIN_CAPS \n"
krb+="$DOMAIN = $COMPLETE_DOMAIN_CAPS \n"
krb+=" \n"
krb+="[appdefaults] \n"
krb+="pam = { \n"
krb+="   debug = false \n"
krb+="   ticket_lifetime = 36000 \n"
krb+="   renew_lifetime = 36000 \n"
krb+="   forwardable = true \n"
krb+="   krb4_convert = false \n"
krb+="} \n"
krb+=" \n"
krb+="[logging] \n"
krb+="default = FILE:/var/log/krb5libs.log \n"
krb+="kdc = FILE:/var/log/krb5kdc.log \n"
krb+="admin_server = FILE:/var/log/kadmind.log \n"

echo -en $krb >> /etc/krb5.conf

# Check if domain controller 2 variable is empty
if [ -z "$DC2" ]
then 
    #echo "\$DC2 is empty."
    echo ' '
else

# If available, add domain controller 2 below primary domain controller in /etc/krb5.conf
sed -i '/kdc = '$DC'/a \
 kdc = '$DC2 /etc/krb5.conf
fi

##################################################
    ######### Update /etc/pam.d/common-auth ######

cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bkp.$(date --iso-8601=seconds)
truncate -s0 /etc/pam.d/common-auth

pam=""
pam+="auth    [success=3 default=ignore]      pam_krb5.so minimum_uid=1000 \n"
pam+="auth    [success=2 default=ignore]      pam_unix.so nullok_secure try_first_pass \n"
pam+="auth    [success=1 default=ignore]      pam_winbind.so krb5_auth krb5_ccache_type=FILE cached_login try_first_pass \n"
pam+="auth    requisite                       pam_deny.so \n"
pam+="auth    required                        pam_permit.so \n"

echo -en $pam >> /etc/pam.d/common-auth

#####################################################
    ######### Update /etc/pam.d/common-account ######

cp /etc/pam.d/common-account /etc/pam.d/common-account.bkp.$(date --iso-8601=seconds)
truncate -s0 /etc/pam.d/common-account

cmn=""
cmn+="account required                        pam_unix.so \n"
cmn+="account sufficient                      pam_winbind.so \n"

echo -en $cmn >> /etc/pam.d/common-account

##########################################
    ### Update /etc/chrony/chrony.conf ###

# Add line 'pool DC' above other pool lines in /etc/chrony/chrony.conf
sed -i '/pool ntp/i \
pool '$DC /etc/chrony/chrony.conf

# Check if domain controller 2 variable is empty
if [ -z "$DC2" ]
then
    #echo "\$DC2 is empty."
    echo ' '
else
# If available, add domain controller 2 below primary domain controller in /etc/chrony/chrony.conf
sed -i 'pool '$DC2'/a \
 pool '$DC2 /etc/chrony/chrony.conf
fi

#echo 'We will now try to create a token for a user in Active Directory.'
#echo 'Type in your domain user name: '
#read USERNAME

##########################################
    ######### Join User to Domain ########

#kinit $USERNAME

##########################################
    ######### Update /etc/samba/smb.conf #

smb=""
smb+="workgroup = $REMOVE_EXTENSION_CAPS \n"
smb+="  client signing = yes \n"
smb+="  client use spnego = yes \n"
smb+="  kerberos method = secrets and keytab \n"
smb+="  realm = $COMPLETE_DOMAIN_CAPS \n"
smb+="  security = ads \n"
smb+="  # Added for Windows A.D. access using Windbind \n"
smb+="  \n"
smb+="  idmap config *:range = 5000-100000 \n"
smb+="  \n"
smb+="  winbind allow trusted domains = no \n"
smb+="  winbind trusted domains only = no \n"
smb+="  winbind use default domain = yes \n"
smb+="  winbind enum users  = yes \n"
smb+="  winbind enum groups = yes \n"
smb+="  winbind refresh tickets = yes \n"
smb+="  \n"
smb+="  template shell = \\/bin\\/bash"

# search for workgroup line in smb.conf and replace with below:
sed -i "s/workgroup = WORKGROUP/$smb/g" /etc/samba/smb.conf

#########################################
    ######### Update /etc/nsswitch.conf #

# comment out /etc/nsswitch.conf and add new lines
cp /etc/nsswitch.conf /etc/nsswitch.conf.tmp
sed 's/^/#/' /etc/nsswitch.conf.tmp > /etc/nsswitch.conf
rm /etc/nsswitch.conf.tmp

ns=""
ns+="passwd:         files winbind \n"
ns+="group:          files winbind \n"
ns+="shadow:         files \n"
ns+="gshadow:        files \n"
ns+=" \n"
ns+="hosts:          files dns \n"
ns+="networks:       files \n"
ns+=" \n"
ns+="protocols:      db files \n"
ns+="services:       db files \n"
ns+="ethers:         db files \n"
ns+="rpc:            db files \n"
ns+=" \n"
ns+="netgroup:       nis \n"
ns+="sudoers:        files"

echo -e "\n$ns" >> /etc/nsswitch.conf # -e allows the new line

#sudo systemctl restart chrony.service
#sudo systemctl restart smbd.service nmbd.service
#sudo systemctl restart winbind.service

#echo ' '
#echo 'You can now join computer to domain.  First exit out of current terminal.'
#echo 'Log in to new terminal and type this command: '
#echo ' '
#echo 'sudo net ads join –k'
#echo ' '
#echo '(Type it.  Do not copy and past it.)'

# Or you could do something like:
# sudo net ads join -U user@DOMAIN.LOCAL

# - Troubleshooting - If you get this error, you may already be addeded to the domain:

# Failed to join domain: Failed to set machine spn: Constraint violation
# Do you have sufficient permissions to create machine accounts?

# - Other Commands -

# getent group
# wbinfo -u
