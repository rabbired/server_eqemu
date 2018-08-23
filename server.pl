#!/usr/bin/perl
use Switch;
system ("rm -rf logs/*.log sql/*");

check_dir("/mnt/data/maps");
check_dir("/mnt/data/quests");
check_dir("/mnt/data/plugins");
check_dir("/mnt/data/lua_modules");
$line = read_eqemu_config_json();

if($line == 1)
{
	check_database();

	system ("./shared_memory");
	system ("./world &");
	system ("./queryserv &");
	system ("./ucs &");
	exec ("./eqlaunch zone");
}

sub read_eqemu_config_json
{
        use JSON;
        my $json = new JSON();
        my $content;
        open(my $fh, '<', "eqemu_config.json") or die "cannot open file $filename";
        {
                local $/;
                $content = <$fh>;
        }
        close($fh);
        $config = $json->decode($content);
        $db = $config->{"server"}{"database"}{"db"};
        $host = $config->{"server"}{"database"}{"host"};
        $user = $config->{"server"}{"database"}{"username"};
        $pass = $config->{"server"}{"database"}{"password"};
	$port = $config->{"server"}{"database"}{"port"};
	return 1;
}

sub check_dir
{
  my $temp_dir = $_[0];
  if ( -d $temp_dir )
  {
    print "$temp_dir exists!\n";
    return;
  }
  switch ($temp_dir)
  {
    case "/mnt/data/maps"
    {
      system ("wget -N --cache=no --no-check-certificate -O ./sql/maps.zip http://github.com/Akkadius/EQEmuMaps/archive/master.zip");
      system ("unzip ./sql/maps.zip && mv -f EQEmuMaps-master /mnt/data/maps && ln -s /mnt/data/maps maps && ln -s /mnt/data/maps Maps");
    }
    case "/mnt/data/quests"
    {
      system ("wget -N --cache=no --no-check-certificate -O ./sql/quests.zip https://github.com/ProjectEQ/projecteqquests/archive/master.zip");
      system ("unzip ./sql/quests.zip && mv -f projecteqquests-master /mnt/data/quests && ln -s /mnt/data/quests quests");
    }
    case "/mnt/data/plugins"
    {
      system ("ln -s /mnt/data/quests/plugins plugins");
    }
    case "/mnt/data/lua_modules"
    {
      system ("ln -s /mnt/data//quests/lua_modules lua_modules");
    }
  }
}

sub check_database
{
	my $tsdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"create database $db\" > /dev/null 2>&1";
	my $run = system ("$tsdb");
	if($run == 0)
	{
		print "Emu Server Database created.\n";
		system ("wget -N --cache=no --no-check-certificate -O ./sql/peq_beta.zip https://raw.githubusercontent.com/rabbired/EQEmuFullDB/master/peq_beta.zip");
		system ("unzip -o ./sql/peq_beta.zip -d ./sql");
		
		my $eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/peqbeta.sql;\" > /dev/null 2>&1";
		system ("$eqdb");
		$eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/player_tables.sql;\" > /dev/null 2>&1";
		system ("$eqdb");
		my $eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/load_bots.sql;\" > /dev/null 2>&1";
		system ("$eqdb");
	}
	else
	{
		print "Emu Server Database already exists and does not need to create.\n";
	}
}
