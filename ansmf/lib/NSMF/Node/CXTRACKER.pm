package NSMF::Node::CXTRACKER;

use strict;
use v5.10;
use base qw(NSMF::Node);
use NSMF;
use NSMF::Net;
use NSMF::Util;
use Data::Dumper;
our $VERSION = '0.1';

sub new {
    my $class = shift;
    my $node = $class->SUPER::new;
    $node->{__data} = {};
    return $node;
}

sub run {
    my ($self) = @_;
     
    return unless  $self->session;
    print_status("Running cxtracker processing..");
    $self->_dir_watch();
}

=head2 _dir_watch

 Looks for new session data files in $cxtdir regulary.
 If a new session files i found, it will try to send its data to the server.

=cut

sub _dir_watch {
    my ($self) = @_;
    my $SS     = $self->{__handlers}->{_net};
    my $cxtdir = $self->{__settings}->{cxtdir};
    my $DEBUG = NSMF::DEBUG;

    while (1) {
        if (defined $SS) {
            my @FILES;
            # Open the directory
            if( opendir( DIR, $cxtdir ) ) {
                print "[*] Dir opened: $cxtdir\n";
                # Find session files in dir (stats.eth0.1229062136)
                while( my $file = readdir( DIR ) ) {
                    next if( ( "." eq $file ) || ( ".." eq $file ) );
                    next unless ($file =~ /^stats\..*\.\d{10}$/);
                    if( -r -w -f "$cxtdir/$file" ) {
                        push( @FILES, $file );
                    }
                }
                closedir( DIR );
            } else {
                print "[*] Could not open dir: $cxtdir\n";
            }
            # If we find any files, proccess...
            foreach my $file ( @FILES ) {
                my $starttime=time();
                print "[*] Found file: $cxtdir/$file\n";# if ($DEBUG);
                #my $sessionsdata = _get_sessions("$cxtdir/$file");
                $self->{__data}->{sessions} = _get_sessions("$cxtdir/$file");
                my $endtime=time();
                my $processtime=$endtime-$starttime;
                print "[*] File $cxtdir/$file processed in $processtime seconds\n" if ($DEBUG);
                $starttime=$endtime;
                #my $result = send_data_to_server($DEBUG,$sessionsdata,$SS);
                my $result = $self->put($self->{__data}->{sessions});
                if ($result >= 1) {
                    #print "[E] Error while sending sessiondata to server: $cxtdir/$FILE -> $NSMFSERVER:$NSMFPORT\n";
                    #print "[*] Skipping deletion of file: $cxtdir/$FILE\n";
                }
                $endtime=time();
                $processtime=$endtime-$starttime;
                if ($result == 0) {
                    print "[*] Sessiondata sent in $processtime seconds\n" if ($DEBUG);
                    print "[W] Deleting file: $cxtdir/$file\n";
                    unlink("$cxtdir/$file") or print_error "Failed to delete $cxtdir/$file";
                    delete $self->{__data}->{sessions};
                }
            }
        
            sleep 10; # for now... to avoid loop ;)
        } else {
        #    print "[E] Could not connect/auth to server: $NSMFSERVER:$NSMFPORT, trying again in 15sec...\n";
            sleep 15;
            $SS->close() if defined $SS;
            return;
        }
    }
}

=head2 _get_sessions

 This sub extracts the session data from a session data file.
 Takes $file as input parameter.

=cut

sub _get_sessions {
    my $sfile = shift;
    my $sessionsdata = qq();
    my $DEBUG = NSMF::DEBUG;

    if (open (FILE, $sfile)) {
        if ($DEBUG) {
            my $filelen=`wc -l $sfile |awk '{print \$1'}`;
            my $filesize=`ls -lh $sfile |awk '{print \$5}'`;
            chomp $filelen;
            chomp $filesize;
            print "[*] File:$sfile, Lines:$filelen, Size:$filesize\n";
        }
        # Verify the data in the session files
        LINE:
        while (my $line = readline FILE) {
            chomp $line;
            $line =~ /^\d{19}/;
            unless($line) {
                warn "[*] Error: Not valid session start format in: '$sfile'";
                next LINE;
            }
            my @elements = split/\|/,$line;
            unless(@elements == 15) {
                warn "[*] Error: Not valid Nr. of session args format in: '$sfile'";
                next LINE;
            }
            # Things should be OK now to send to the SERVER
            if ( $sessionsdata eq "" ) {
                $sessionsdata = "$line";
            } else {
                $sessionsdata = "$sessionsdata\n$line";
            }
      }
      close FILE;
      print "Sessionsdata:\n$sessionsdata\n" if $DEBUG;
      return $sessionsdata;
      }
      
}


1;
