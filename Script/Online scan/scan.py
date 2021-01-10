 
counternameserver = 0
nameserverlist = []

import socket
import dns.resolver
import sys
from datetime import datetime

domain = input ("Wat is het domein naam?: ")

#IP
ip = socket.gethostbyname(domain)
print("Dit is het IP adress: ",ip)

#nameserver
nameservers = dns.resolver.query(domain,'NS')
for server in nameservers:
    counternameserver = counternameserver + 1
    nameserverlist.insert(counternameserver,server.target)
print("Dit zijn de DNS nameservers: ", nameserverlist)

# TXT record
answers = dns.resolver.query(domain, 'TXT')
for rdata in answers:
    for txt_string in rdata.strings:
      print ('Dit is het TXT record(s): ', txt_string)

portscankeuze = input("Wilt u ook de meest standaard open poorten checken? (ja/nee)")
if (portscankeuze == "ja" or portscankeuze == "Ja" or portscankeuze == "JA" or portscankeuze == "J" or portscankeuze == "j"):
# Exception handling
    try:
     # Ask for a host to scan
        print('\n')
        remote_host_domain_name = domain
        remote_host_ip_address = ip

    # Display information about the host to be scanned
        print('_' * 110)
        print('Scanning The Remote Host For Open Ports... ')
        print('Domain Name: {}'.format(remote_host_domain_name))
        print('IP Address: {}'.format(remote_host_ip_address))
        print('_' * 110)
        print('\n')

    # Record the scan initial time
        initial_time = datetime.now()

    # List to keep open ports
        open_ports = []


    # Scan all ports specified in the Port Range
        for port in (20,21,22,23,25,53,67,68,69,80,110,119,123,137,138,139,143,161,162,389,443,445,465,546,547,569,587,990,993,995,1080,1194,3306,3389,3689,5432,5800,5900,6346,8080):
            network_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            connection_result = network_socket.connect_ex((remote_host_ip_address, port))
            if connection_result == 0:
                open_ports.append(port)
                print('Port {}: Open'.format(port))
            else:
                print('Port {}: Closed'.format(port))
            network_socket.close()
    except KeyboardInterrupt:
    # Record the scan final time
        final_time = datetime.now()

        print('\n')
        print('You Have Stopped The Scan.\n')
        print('Started At: {}'.format(initial_time))
        print('Finished At: {}'.format(final_time))

        if len(open_ports) != 0:
            print('Open Ports: {}'.format(open_ports))
        else:
            print('\n')
            print('No Open Ports Found.')

        print('\n')
        sys.exit()
    except socket.gaierror:
        print('\n')
        print('Hostname Could Not Be Resolved. Exiting...')
        print('\n')
        sys.exit()

# Record the scan final time
    final_time = datetime.now()

# Display the information on the terminal
    print('\n')
    print('Port Scan Completed')
    print('Started At: {}'.format(initial_time))
    print('Finished At: {}'.format(final_time))

    if len(open_ports) != 0:
        print('Open Ports: {}'.format(open_ports))
    else:
        print('\n')
        print('No Open Ports Found.')

