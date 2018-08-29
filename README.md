# msales/mysql - Official mysql image with ramdisk support

## Description

We have used following image as our base:
https://hub.docker.com/r/library/mysql/

Since our image extends features provided by official image we encourage you to read official docs before reading this readme.

## Base Features

### Classic usage

You can use this image in exactly the same way (with identical configuration and parameters) as official image:

'''
docker run --rm --name whatever -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v /home/brekke/persist/:/var/lib/mysql msales/mysql
'''

Note that this image is emphemeral by default and you have to provide persistent volume under /var/lib/mysql if you want persistence.

## Msales features - ramdisk

As mentioned above, our implementation adds following enviroment variables for enabling ramdrive operations:

```
RAMDISK_SIZE=0        (ramdisk size in MB , default: 0 - no ramdisk)
RAMDISK_LOAD=false    (load /var/lib/mysql into ramdisk before database startup , default: a new empty database will be initialized)
RAMDISK_SAVE=false    (save ramdisk into /var/lib/mysql after database shutdown , default: ramdisk database gets dropped , no save)
```

Note: Default values does not enable ramdisk nor ramdisk persistence at all.

Note: Please remember to adjust or disable your k8s resource limits accordingly.

### Ramdisk only database

```
RAMDISK_SIZE=1024
```

Every time container/pod gets started we start with a fresh database that resides in ram. On shutdown everything gets erased. Ideal for testing.

### Ramdisk database with "template" injection

```
RAMDISK_SIZE=1024
RAMDISK_LOAD=true
```

Every time container/pod gets started we start 'cp /var/lib/mysql/* $RAMDISK'. On shutdown everything gets dropped.

Note: Data copy may take some time on database startup. This mode is useful when moving existing persistent database into ramdisk!

### Ramdisk database with save

```
RAMDISK_SIZE=1024
RAMDISK_SAVE=true
```

Every time container/pod gets started it gets fresh empty database. On shutdown we put ramdisk content into /var/lib/mysql

Note: Data copy will take some time on database shutdown. This mode is useful when you need to examine database content outside of container. Keep in mind to use exactly the same db version !

### Ramdisk database with full persistence

```
RAMDISK_SIZE=1024
RAMDISK_LOAD=true
RAMDISK_SAVE=true
```

Fully persistent mysql in ramdisk.

Note: Data copy will take some time both on startup and shutdown.

Enjoy !
