# peering

# peer_details

# Company
# ASN
# IP
# Email - NOC
# Email - peering
# Phone 
# Fax
# NDA Signed
# AS-SET
# Location
# Type
# Router

CREATE TABLE peer_details ( Company varchar(255) NOT NULL, 
			    ASN varchar(16) NOT NULL, 
			    IP varchar(45) NOT NULL, 
			    MD5 varchar(256) NOT NULL, 
			    NOC varchar(64) NOT NULL, 
			    Peering varchar(64) NOT NULL, 
			    Phone varchar(32) NOT NULL, 
			    FAX varchar(32), 
			    NDA enum('Y','N') not NULL default 'Y',
			    AS_SET varchar(64) NOT NULL, 
			    Location enum('InterXion','DEG') NOT NULL,  
			    Type enum('IXP','Private','Transit','Customer','Private Interconnect') NOT NULL, 
			    Router varchar(255),
			    primary key(IP));

