#!/usr/bin/perl

$line = read_eqemu_config_json();

if($line == 1){
        $tsdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"create database $db\" > /dev/null 2>&1";
        $run = system ("$tsdb");
                if($run == 0)
                {
                    print "Emu Server Database created.\n";
		    system ("unzip -o ./sql/peq_beta.zip -d ./sql");
		    $eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/peqbeta.sql;\" > /dev/null 2>&1";
                    system ("$eqdb");
		    $eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/player_tables.sql;\" > /dev/null 2>&1";
                    system ("$eqdb");
		    $eqdb = "mysql -h$host -P$port -u$user -p$pass -N -B -e \"use $db;source ./sql/load_bots.sql;\" > /dev/null 2>&1";
                    system ("$eqdb");
                }
                else
                {
                         print "Emu Server Database already exists and does not need to create.\n";

                }
system ("rm -rf logs/*.log");
system ("./shared_memory");
system ("./world &");
system ("./queryserv &");
system ("./ucs &");
exec ("./eqlaunch zone");
}

sub read_eqemu_config_json {
        use JSON;
        my $json = new JSON();
        my $content;
        open(my $fh, '<', "eqemu_config.json") or die "cannot open file $filename"; {
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
