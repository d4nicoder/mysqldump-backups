## Supported tags and respective Dockerfile links
- [10.17, latest](https://gitlab.com/danitetus/mysqldump)

## Quick reference

- **Repository:** [Gitlab](https://gitlab.com/danitetus/mysqldump)
- **Maintained by:** [Daniel Cañada García](https://gitlab.com/danitetus)

## How to use this image

### **Dump database to volume**
In this example we are going to backup a database to a volume. When you map the /dump volume this image deletes all dumps of this database older than 30 days.
```
docker run --rm --name mysqdump \
	-e DB_HOST=<IP or host> \
	-e DB_USER=<username> \
	-e DB_PASS=<password> \
	-e DB_NAME=<database name to dump> \
	-v </path/on/your/host>:/dump \
	danitetus/mysqldump:latest
```

### **Dump database to ftp**

```
docker run --rm --name mysqdump \
	-e DB_HOST=<IP or host> \
	-e DB_USER=<username> \
	-e DB_PASS=<password> \
	-e DB_NAME=<database name to dump> \
	-e FTP_HOST=<FTP IP or hostname> \
	-e FTP_USER=<ftp username> \
	-e FTP_PASS=<ftp password> \
	-e FTP_DESTINATION=<ftp folder destination> \
	danitetus/mysqldump:latest
```

*Tip: You can map the /dump volume to export the backup to FTP and volume*

## ... via kubernetes cronjob
Example of dayly cronjob:
```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mysqldump
            image: danitetus/mysqldump:latest
            env:
              - name: DB_NAME
                value: <database name>
              - name: DB_HOST
                value: <hostname or IP>
              - name: DB_USER
                value: <db user>
              - name: DB_PASS
                value: <db pass>
              - name: FTP_HOST
                value: <ftp host>
              - name: FTP_USER
                value: <ftp user>
              - name: FTP_PASS
                value: <ftp pass>
              - name: FTP_DESTINATION
                value: <ftp/des/folder>
			      volumeMounts:
              - name: "dump"
                mountPath: "/dump"
          restartPolicy: OnFailure
          volumes:
            - name: "dump"
              hostPath:
                - path: "<host destination>

```

## Environment variables

You can customize the behavior of this image with the environment variables:

### **`DB_HOST`**
This variable is mandatory and specifies the host of the MySQL server

### **`DB_NAME`**
This variable is mandatory and specifies the name of the database to backup

### **`DB_USER`**
This variable is mandatory and specifies the user with read access to the database

### **`DB_PASS`**
This variable is mandatory and specifies the password for that user

### **`FTP_HOST`**
This variable is optional and specifies the host of the FTP server. If this variable is not present, tha backup will be backed up only to the volume.

### **`FTP_USER`**
This variable is optional and specifies the user with write access to the ftp server

### **`FTP_PASS`**
This variable is optional and specifies the password of the ftp user

### **`FTP_DESTINATION`**
This variable is optional and specifies the destination folder in the ftp server to save the backup