!!!! WARNING - This code is 20 years old, and probably doesnt work, its showing a concept of generating filters based on RIPE DB objects !!!!!!!!


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

```bash
./filtergen -f AS-TECHNOLABS -t juniper -p blah
Results: % This is the RIPE Database query service.Fetching prefixes for AS43178
edit policy-options policy-statement blah from
        set route-filter 91.194.126.0/23 exact
        set route-filter 91.194.126.0/24 exact
        set route-filter 91.194.127.0/24 exact
exit
1 prefixes found
```

ISSUES

Please report any issues to the author.

Thanks
