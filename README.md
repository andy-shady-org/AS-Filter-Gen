README

writen by andy@shady.org

This is the README for AS-Filter-Gen.

This tool is designed to run in conjunction with a MySQL database
populated with a list of peers. All peers have a type setting.

Peers of type "IXP" are discovered from the database and each peer's AS-SET and subsequently
their ASN is polled from RIPE. A valid prefix list is then generated both in XML and in db4 format.

Checking is done against existing prefix lists to determine whether the peer has updated its IRR entries.

The output in XML can be used to auto-populate Juniper based prefix-lists and can be used in conjunction with 
standard JUNOS policies.

All changes are emailed to a defined address to notify the user of changes within the IRR database.


INSTALL

1. Create the table "peer_details" within your MySQL databases.
   (see filtergen.sql for table structure)
2. Populate yoour table ensuring to define IXP peer types.
3. Edit the file filtergen.conf to suit your system.
4. Run filtergenSQL from crontab. The frequancy is entirely up to you. (suggestion: once per day)
5. Update your run time prefix lists to reflect the output. This can be done by either using the JUNOS template 
   XML files, or manually.



OTHER

There is also a command line version included with this package.

INSTALL WEB FRONT END
There is an online version of the tool also. This is contained within a complete web site.
The website is currently setup for AS25441 although some simple editing of header.php will change this.
You should also look at editing the other PHP files as they contain hard coded references to AS25441 (the authors employer)

1. Copy the directory www to your DocumentRoot directory
2. Edit the .htaccess file within the subdirectory "admintools".
3. Browse to your index page



TODO

Ensure type "Customer" peers are polled. This may be tricky if you allow customers to 
deaggregate their routes whilst you reaggregate them along your edge.


ISSUES

Please report any issues to the author.

Thanks
