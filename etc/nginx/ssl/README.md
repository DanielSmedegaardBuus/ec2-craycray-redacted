SSL Certificates
================
The officially signed ones are 2048 bit. Anything less will be rejected by the
signing authorities. Please note that (at least with Comodo PositiveSSL, the
namecheap SSL affiliate) prefixing the domain name you're signing for with
"www." will let the certificate cover both of the domains www.$DOMAIN and
$DOMAIN.

The password used for the keys is the one talking about a certain type of
softened tree at a specific location. CSR files are without passwords, or
restarting nginx would fail if not manually providing the password.

NOTE: When issuing a sign request with namecheap, select "Apache + OpenSSL" for
the server type when using nginx.



ws.myproject.com
-------------
    openssl req -nodes -newkey rsa:2048 -keyout ws.myproject.com.key -out ws.myproject.com.csr
        Country name:       DK
        State/province:     Denmark
        Locality:           Copenhagen
        Organization:       Myproject
        OU:                 IT
        Common name/FQDN:   ws.myproject.com
        Email:              webmaster@myproject.com
        
        Challenge password: 
        Optional company:   
    
    # Issue CSR with the .csr file, unzip certificate files
    cat ws_myproject_com.crt COMODORSADomainValidationSecureServerCA.crt COMODORSAAddTrustCA.crt AddTrustExternalCARoot.crt >> ssl-bundle.crt



self-signed certificate
-----------------------
    sudo openssl genrsa -des3 -out server.key 1024
        Passphrase:         See above.

    openssl req -new -key server.key -out server.csr
        Country name:       DK
        State/province:     Denmark
        Locality:           Copenhagen
        Organization:       Myproject ApS
        OU:                 IT
        Common name/FQDN:   myproject.com
        Email:              webmaster@myproject.com
        
        Challenge password: 
        Optional company:   

    cp server.key server.key.org
    openssl rsa -in server.key.org -out server.key
    openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt


 