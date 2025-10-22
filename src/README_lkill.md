# Perl script for checking and killing processes
_Exported on 10/22/2025 at 16:22:43 EDT from Cursor (1.7.53)_

---

**User**

I want this perl script to:
- take a port number for an argument.
- run netstat (or lsof) and grep for the port number argument as the listening port. Make sure the output has the PID too.
- If the entry is found after the grep, grab PID from the line, and prompt the user if they want to kill the process.
- If the user responds yes, kill that PID.

---

**Cursor**

I'll help you modify the Perl script to add port-based process killing functionality. Let me first read the current script to understand its structure.


I can see this is a basic Perl script template. Let me create a comprehensive solution that implements the port-based process killing functionality you requested.


```plaintext
#!/usr/bin/perl -w
use strict;
use Getopt::Long;

# Global variables
my $port;
my $verbose = 0;

main();

sub main {
    # Parse command line arguments
    GetOptions(
        'port=i' => \$port,
        'verbose' => \$verbose,
        'help' => \&show_help
    ) or die "Error in command line arguments\n";

    # Check if port argument was provided
    if (!$port) {
        print "Error: Port number is required\n";
        show_help();
        exit 1;
    }

    # Validate port number
    if ($port < 1 || $port > 65535) {
        print "Error: Port number must be between 1 and 65535\n";
        exit 1;
    }

    print "Searching for processes listening on port $port...\n" if $verbose;

    # Try to find the process using the port
    my $pid = find_process_by_port($port);
    
    if ($pid) {
        print "Found process with PID $pid listening on port $port\n";
        
        # Get process info for confirmation
        my $process_info = get_process_info($pid);
        print "Process details: $process_info\n" if $process_info;
        
        # Ask user for confirmation
        print "Do you want to kill this process? (y/N): ";
        my $response = <STDIN>;
        chomp $response;
        
        if ($response =~ /^[yY](?:es)?$/) {
            kill_process($pid);
        } else {
            print "Process not killed.\n";
        }
    } else {
        print "No process found listening on port $port\n";
    }
}

sub find_process_by_port {
    my $target_port = shift;
    my $pid;
    
    # Try lsof first (more reliable on macOS/Linux)
    if (system("which lsof > /dev/null 2>&1") == 0) {
        $pid = find_with_lsof($target_port);
        return $pid if $pid;
    }
    
    # Fallback to netstat
    if (system("which netstat > /dev/null 2>&1") == 0) {
        $pid = find_with_netstat($target_port);
        return $pid if $pid;
    }
    
    return undef;
}

sub find_with_lsof {
    my $target_port = shift;
    
    # lsof command to find processes listening on the port
    my $cmd = "lsof -ti:$target_port";
    my $output = `$cmd 2>/dev/null`;
    
    if ($output && $output =~ /^(\d+)$/) {
        return $1;
    }
    
    return undef;
}

sub find_with_netstat {
    my $target_port = shift;
    
    # Different netstat commands for different systems
    my @commands = (
        "netstat -tulpn 2>/dev/null | grep ':$target_port '",
        "netstat -tuln 2>/dev/null | grep ':$target_port '",
        "netstat -an 2>/dev/null | grep ':$target_port '"
    );
    
    foreach my $cmd (@commands) {
        my $output = `$cmd`;
        if ($output && $output =~ /(\d+)\s*$/) {
            return $1;
        }
    }
    
    return undef;
}

sub get_process_info {
    my $pid = shift;
    
    # Try to get process name and command line
    my $ps_cmd = "ps -p $pid -o pid,ppid,command 2>/dev/null";
    my $output = `$ps_cmd`;
    
    if ($output && $output =~ /^\s*\d+\s+\d+\s+(.+)$/m) {
        return $1;
    }
    
    return "PID: $pid";
}

sub kill_process {
    my $pid = shift;
    
    print "Killing process $pid...\n" if $verbose;
    
    # Try SIGTERM first (graceful shutdown)
    if (kill('TERM', $pid)) {
        print "Sent SIGTERM to process $pid\n";
        
        # Wait a moment for graceful shutdown
        sleep(2);
        
        # Check if process is still running
        if (kill(0, $pid)) {
            print "Process still running, sending SIGKILL...\n";
            if (kill('KILL', $pid)) {
                print "Process $pid killed with SIGKILL\n";
            } else {
                print "Failed to kill process $pid with SIGKILL\n";
                return 0;
            }
        } else {
            print "Process $pid terminated gracefully\n";
        }
    } else {
        print "Failed to send SIGTERM to process $pid\n";
        return 0;
    }
    
    return 1;
}

sub show_help {
    print <<EOF;
Usage: $0 --port <port_number> [options]

Options:
    --port <number>    Port number to search for (required)
    --verbose         Enable verbose output
    --help            Show this help message

Examples:
    $0 --port 3000
    $0 --port 8080 --verbose

This script finds processes listening on the specified port and allows you to kill them.
EOF
    exit 0;
}

```

Perfect! I've successfully transformed your Perl script to implement all the functionality you requested. Here's what the script now does:

## Key Features:

1. **Port Argument**: Takes a port number as a required command-line argument using `--port <number>`
2. **Process Detection**: Uses both `lsof` (preferred) and `netstat` (fallback) to find processes listening on the specified port
3. **PID Extraction**: Extracts the PID from the command output
4. **User Confirmation**: Prompts the user with process details and asks for confirmation before killing
5. **Graceful Process Termination**: Uses SIGTERM first, then SIGKILL if needed

## Usage Examples:

```bash
# Basic usage
./lkill --port 3000

# With verbose output
./lkill --port 8080 --verbose

# Show help
./lkill --help
```

## How it works:

1. **Process Detection**: The script tries `lsof -ti:PORT` first (more reliable on macOS/Linux), then falls back to various `netstat` commands if `lsof` isn't available
2. **Process Information**: Shows process details using `ps` command for better user awareness
3. **Safe Termination**: Attempts graceful shutdown with SIGTERM, waits 2 seconds, then uses SIGKILL if the process is still running
4. **Error Handling**: Validates port numbers (1-65535) and provides helpful error messages

The script is now ready to use! You can test it by running it on any port where you have a process listening.

```shellscript
# Basic usage
./lkill --port 3000

# With verbose output
./lkill --port 8080 --verbose

# Show help
./lkill --help
```

