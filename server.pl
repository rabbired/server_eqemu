#!/usr/bin/perl

use Switch;

check_dir("Maps");
check_dir("quests");
check_dir("plugins");
check_dir("lua_modules");
$line = read_eqemu_config_json();

if($line == 1)
{
  check_database();

  system ("rm -rf logs/*.log sql/*");
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
    case "Maps"
    {
      system ("wget -N --cache=no --no-check-certificate -O sql/maps.zip http://github.com/Akkadius/EQEmuMaps/archive/master.zip");
      system ("unzip ./sql/maps.zip && mv -f EQEmuMaps-master Maps && ln -s Maps maps");
    }
    case "quests"
    {
      system ("wget -N --cache=no --no-check-certificate -O sql/quests.zip https://github.com/ProjectEQ/projecteqquests/archive/master.zip");
      system ("unzip ./sql/quests.zip && mv -f projecteqquests-master quests");
    }
    case "plugins"
    {
      system ("cp -rf ./quests/plugins ./");
    }
    case "lua_modules"
    {
      system ("cp -rf ./quests/lua_modules ./");
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
                    system ("wget -N --cache=no --no-check-certificate -O sql/peq_beta.zip https://raw.githubusercontent.com/rabbired/EQEmuFullDB/master/peq_beta.zip");
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
