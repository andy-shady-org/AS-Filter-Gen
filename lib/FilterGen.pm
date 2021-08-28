#!/usr/bin/env perl
# FilterGen Perl Library
# Do Not Edit
# 
# writen by andy@shady.org

sub error
{
  my $errmsg = $_[0];
  print "Internal Error: $errmsg\n";
  exit;
}

sub getconfigs()
{
  $base=".";
  $configfile="filtergen.conf";
  open(FH, "$base/$configfile") || die "Cant open config $base/$configfile:$!";
  while(<FH>)
  {
    chomp;
    if ($_=~/sqluser/)
    {
      ($tmp, $sqluser) = split(/=/,$_);
    }
    if ($_=~/sqlpass/)
    {
      ($tmp, $sqlpass) = split(/=/,$_);
    }
    if ($_=~/sqlhost/)
    {
      ($tmp, $sqlhost) = split(/=/,$_);
    }
    if ($_=~/sqldbase/)
    {
      ($tmp, $sqldbase) = split(/=/,$_);
    }
    if ($_=~/xmlstore/)
    {
      ($tmp, $xmlstore) = split(/=/,$_);
    }
    if ($_=~/prefixdbdir/)
    {
      ($tmp, $prefixdbdir) = split(/=/,$_);
    }
    if ($_=~/alertemail/)
    {
      ($tmp, $alertemail) = split(/=/,$_);
    }
  }
  
  if($debug)
  {
    print("SQL-User: $sqluser\nSQL-Pass: $sqlpass\nSQL-Host: $sqlhost\nSQL-DBase: $sqldbase\n");
  }
}


sub queryASset()
{
  my $asn = $_[0];
  if($whois->Query($asn))
  {
    printf("Query error: %s\n", $whois->GetError());
    exit;
  }
  my @result=();
  my $result = $whois->GetResult();
  if($result)
  {
    @result=split("\n", $result);
  }
  else
  {
    if($debug)
    {
      printf("No results: %s\n", $whois->GetError());
    }
  }
  # $whois->Close();

  foreach(@result)
  {
    my @array=();
    next if /^[ \t]*#%/;  # skip comment lines
    next if /^$/;         # skip empty lines

    if(@array = ($_ =~ /(AS\d{1,5})(?![\d:])/g ))
    {
      for $a (0..$#array)
      {
        $asnhash{$array[$a]}++; 
        next;
      }
    }
    elsif(@array = ($_ =~ /members:\s+(AS[\w\d-\:]+)/gi))
    {
      if(!exists $assetlist{$1} && !exists $processed_assetlist{$1})
      {
        $assetlist{$1}=$1;
        if($debug)
        {
          print "Debug: $assetlist{$1} [First Seen]\n";
        }
      }
      else
      {
        if($debug)
        {
          print "Debug $assetlist{$1}$processed_assetlist{$1} [cached]\n";
        }
      }
    }
  }
  return(%asnhash, %assetlist);
}

sub processASNlist()
{
  my $key=();
  foreach $key (sort(keys(%asnhash)))
  {
    if($debug)
    {
      print "Debug: Fetching prefixes for $key\n";
    }

    # do query on ASN for prefixes
    if($whois->Query("-i origin $key"))
    {
      printf("Query error: %s\n", $whois->GetError());
      exit;
     }
     my $result = $whois->GetResult();
     my @result=();
     @result=split("\n", $result);
     # grab each prefix
     foreach(@result)
     {
       next unless ($_=~ /route:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2})/);
       $p=$1;
       $prefixes{"$p"}="$p";
     }
     delete $asnhash{$key};
  }
  return(%prefixes);
}

sub processSingleASN()
{
  my $key=$asn;
  if($debug)
  {
    print "Debug: Fetching prefixes for $key\n";
  }

  # do query on ASN for prefixes
  if($whois->Query("-i origin $key"))
  {
    printf("Query error: %s\n", $whois->GetError());
    exit;
  }
  my $result = $whois->GetResult();
  my @result=();
  @result=split("\n", $result);
  # grab each prefix
  foreach(@result)
  {
    next unless ($_=~ /route:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2})/);
    $p=$1;
    $prefixes{$p}=$p;
  }
  return(%prefixes);
}



sub checklast()
{
  # use dbm hash db file format for all prefix storing
  $dbmfile="$prefixdbdir/$asn";
  dbmopen(%prefixlist,$dbmfile,0666) || error("Cannot open $dbmfile: $!");
  $count=0;
  if(!%prefixlist)
  {
    if($debug)
    {
      print("Debug: Empty File: Populating\n");
    }
    foreach $prefix (keys %prefixes)
    {
      $count++;
      if($debug)
      {
        print("Debug: Adding Prefix: $prefix\n");  
      }
      $prefixlist{"$prefix"}="$prefix";
      push(@addedprefixes, $prefix);
      push(@xmlprefixes, $prefix);
      delete $prefixes{$prefix};

    }
  }
  else
  {
    foreach $key (keys %prefixlist)
    {
      unless($prefixes{$key})
      {
        if($debug)
        {
          print("Debug: $asn has removed $key from the IRR\n");
        }
	push(@deletedprefixes, $prefix);
        delete $prefixlist{$key};
	$count--;
      }
    }

    foreach $key (keys %prefixlist)
    {
      while (values(%prefixes) > 0)
      {
        foreach $prefix (keys %prefixes)
        {
          if($prefixlist{$prefix})
          {
            if($debug)
            {
              print("Debug: Prefix $prefix does exist for $asn\n");
            }
	    $count++;
	    delete $prefixes{$prefix};
	    push(@xmlprefixes, $prefix);
            next;
          }
          else
          {
            if($debug)
            {
              print("Debug: Prefix $prefix does NOT exist for $asn\n");
            }
	    $count++;
	    push(@addedprefixes, $prefix);
	    push(@xmlprefixes, $prefix);
            delete $prefixes{$prefix};
          }
        }
      }
    }
  }
  foreach $prefix (@addedprefixes)
  {
    if($debug)
    {
      print("Debug: New prefix added by $asn: $prefix\n");
    }
    $prefixlist{"$prefix"}="$prefix";
    delete $prefixes{$prefix};
  }
  dbmclose(%prefixlist);
  if($debug)
  {
    print("Debug: $asn showed $count prefixes\n");
  }
  return(@addedprefixes, @deletedprefixes, @xmlprefixes);
}

sub emailresult()
{
  if(($#addedprefixes >= 0) || ($#deletedprefixes >= 0))
  {

    
    $sendmail="/usr/libexec/sendmail/sendmail -t $sender";
    $subject="Subject: $asn - Prefix Update\n";
    $reply_to="From: andy\@shady.org\n";
    
    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
    print SENDMAIL $reply_to; 
    print SENDMAIL $subject; 
    print SENDMAIL "To: andy\@shady.org"; 
    print SENDMAIL "Content-type: text/plain\n\n"; 
    foreach(@addedprefixes)
    {
      print SENDMAIL "$asn added $_\n";
    }
    foreach(@deletedprefixes)
    {
      print SENDMAIL "$asn removed $_\n";
    }
    close(SENDMAIL);

    if($debug)
    {
      foreach(@addedprefixes)
      {
        print("Debug: EMAIL --- $asn added $_\n");
      }
      foreach(@deletedprefixes)
      {
        print("Debug: EMAIL --- $asn removed $_\n");
      }
    }
  }
  undef(@addedprefixes);
  undef(@deletedprefixes);
}


sub outputxml()
{
  $file="$xmlstore/$asn.xml";
  open(FH,">$file") || error("Cant open $file: $!");
  print FH <<EOF;
<configuration>
        <policy-options>
                <prefix-list operation="replace">
                        <name>$asn</name>
EOF

  foreach $prefix (@xmlprefixes)
  {
    chomp;
    print FH "<prefix-list-item>\n<name>$prefix</name>\n</prefix-list-item>\n";
  }
print FH <<EOF;
                </prefix-list>
        </policy-options>
</configuration>
EOF
  close(FH);

  # this has been added to avoid automation using XML
  # netconf bails out on loading up XML config files
  # so we output in TXT so we can manually upload conf files
  # and put them on with load merge.
  $file="$xmlstore/$asn.txt";
  open(FH,">$file") || error("Cant open $file: $!");
  foreach $prefix (@xmlprefixes)
  {
    chomp;
    print FH "$prefix\n";
  }
  undef(@xmlprefixes);
}

return 1;
