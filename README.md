# AnjeaBackup

Warning: *I do not consider AnjeaBackup anything close to production-ready* .

It is however a fun toy, and some things do work.

# Mission

AnjeaBackup should

 - not depend on many gems (ideally a plain ruby installation should suffice).
 - use rsync and hard links (it helps a lot if you understand these).
 - be configurable through editing configuration files.
 - not depend on other services (e.g. not use an external database).
 - concentrate on doing the file synchronization, stuff like mailing or regular execution can be left to your other favorite tools (see #Example).

AnjeaBackup will create copies of local or remote (via ssh) files and directories, hard-linked to former versions of the same files and directories.

The approach has been beautifully implemented by numerous people using e.g. bash or perl scripts.
I aimed for quick and easy configurability and some oppinionated choices that were given my usage scenario.

With anjea_backup you define what folders and files to backup (these can be on a remote server to which you have passwordless key-based ssh access to, or use sshfs to 'tunnel' it to your local filesystem).  On each execution of anjea_backup, a copy of these files and folders will be created in a defined location.  Hard links are used which means:
  - only changed files need to be transferred
  - unchanged files are represented by inodes, taking away virtually no disk space.  Always the last backup serves as reference for the next ones (against which changes are computed).  The drawback here is that if a single byte in a big file changes, the whole file is transferred and created again - thus it is not a solution to sparsely backup e.g. VM images.

anjea_backup preserves the original full path and will put your files in a folder structure similar to this:

    /backup/2014-11-21-04/symbolic_name/path/to/asset
    /backup/2014-11-21-04/other_name/path/to_other/asset

where `/backup` can be configured, `symbolic_name` is a user-given name and `/path/to/asset` is the path on the machine that receives the backup.

Note that symbolic links in the source can be tricky.

## Requirements

You'll probably need a decent linux installation and have rsync installed.  I opted to keep compatibility to ruby 1.9.3 .  `bundler` and `rake` gems.  I list these, because I want anjea to be useful on a pretty bare system where the ruby dependencies are properly managed by the distributions base packages - no fiddling with rvm/rbenv and Co.

## Installation

    $ gem install anjea_backup

## Usage

AnjeaBackup is meant to be a script.  If you find 'library' usage for it, get in touch.  Also, I think if you want to *use* it, get in touch.

The main script lives in `bin/anjea` .

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

The group names (e.g. `[files]`) serve as human readable name and as directory name within the `dst` location specified in `anjea.conf`.

In this example, the second group (_remotebox_) saves files from a remote box (`anjea@otherhost.mynetwork:/home/remoteanjea/stuff`) using the public key defined in `key` .

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
* Nested groups in ".ini" files
* Proper ini file parser
* (missing: send mail) -> easy to do from outside
* (missing: do full, non incremental, non hardlinked backups into vault from time to time)

## Contributing

0. Contact me
1. Fork it ( https://github.com/[my-github-username]/anjea_backup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
