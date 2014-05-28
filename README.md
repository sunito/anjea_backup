# AnjeaBackup

Warning: *I do not consider AnjeaBackup anything close to production-ready* .

It is however a fun toy, and some things do work.

AnjeaBackup will create copies of local or remote (via ssh) files and directories, hard-linked to former versions of the same files and directories.

The approach has been beautifully implemented by numerous people using e.g. bash or perl scripts.
I aimed for quick and easy configurability and some oppinionated choices that were given my usage scenario.

## Installation

You'll probably need a decent linux installation and have rsync installed.

    $ gem install anjea_backup

## Usage

AnjeaBackup is meant to be a script.  If you find 'library' usage for it, get in touch.  Also, I think if you want to use it, get in touch.

The script is in `/bin/anjea` .

The working basic use case is to just call it.  It will pick up two configuration files (see next sections) and immediately start a backup-attempt.

## Configuration

There are two important configuration files, `anjea.conf` and `backups.conf` .

Example configuration files are included.
The files somewhat follow the ini/Desktop-File conventions, but a *very* limited parser is used.

### anjea.conf

Defines *where* to save backups, logs, etc.  Example:

    [system]
    dst=/backup/anjea-backups/
    vault=/vault/anjea-vault/
    log=/var/log/anjea/
    lock=/var/lock/anjea.lock

`dst` is the root folder for backups, `vault` currently unused, `log` folder for log files, `lock` file to ensure anjea is just running once.

### backups.conf

Defines *what* to backup and how to access it.  Example:

    [files]
    src=/home/anjea/files/
    description=other directory with files
    
    [remotebox]
    src=/home/remoteanjea/stuff/
    description=stuff on other host
    host=otherhost.mynetwork
    key=/home/anjea/.anjea/keys/otherhostkey_rsa
    user=anjea

Second group saves files from a remote box (`anjea@otherhost.mynetwork:/home/remoteanjea/stuff`) using public key as defined in `key` .

## Example

* Dedicated Backup-Server running anjea.
* Backup-Server wakes up on lan, triggered by cron job from outside.
* Backup-Server has a crontab-entry to do the backup
    0 3 * * * anjea | tee /backups/current/log | ssmtp myemailadress@geemail.com 
* last log goes to /backup/current/log, is sent to email address (requires configured ssmtp, alternatively define MAILTO in crontab).

## TODOs

This will need work.

* optparse bin/anjea, add help
* trap and handle signals
* Rescue from malconditions, move incomplete backups to a designated location
* Continue with other backups in case one faults
* Allow manual targeted backups of single sources
* Revive tests
* (missing: send mail) -> easy to do from outside
* (missing: do full, non incremental, non hardlinked backups into vault from time to time)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/anjea_backup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
