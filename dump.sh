#!/bin/bash
if [[ ${DB_USER} == "" ]]; then
	echo "Missing DB_USER env variable"
	exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
	echo "Missing DB_PASS env variable"
	exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
	echo "Missing DB_HOST env variable"
	exit 1
fi

if [[ ${DB_NAME} == "" ]]; then
	echo "Missing DB_NAME env variable"
	exit 1
fi


FILE_NAME=mysql-${DB_NAME}-$( date +%y%m%d-%H%M ).tar.gz
BACKUP_DEST="/dump/${FILE_NAME}"
TEMP_DEST="/tmp/dump.sql"
mysqldump -h ${DB_HOST} -u "${DB_USER}" --password="${DB_PASS}" --single-transaction --skip-lock-tables --opt "${DB_NAME}" > "${TEMP_DEST}"

status=$?
if [ $status -ne 0 ]; then
	echo "Error dumping the database"
	exit 1
fi;

tar -czvf $BACKUP_DEST $TEMP_DEST
status=$?
if [ $status -ne 0 ]; then
	echo "Error compressing the backup"
	exit 2
fi;

echo "Backup compressed"

if [ $status -eq 0 ]; then
	if [[ ${FTP_HOST} != "" ]]; then
		if [[ ${FTP_USER} == "" ]]; then
			echo "Missing FTP_USER env variable"
			exit 1
		fi

		if [[ ${FTP_PASS} == "" ]]; then
			echo "Missing FTP_PASS env variable"
			exit 1
		fi

		if [[ ${FTP_DESTINATION} == "" ]]; then
			echo "Missing FTP_DESTINATION env variable"
			exit 1
		fi
		echo "Uploading to FTP server"
		ncftpput -u $FTP_USER -p $FTP_PASS $FTP_HOST $FTP_DESTINATION $BACKUP_DEST
		echo "Upload done"
		exit 0
	else
		find /dump/mysql-$DB_NAME* -mtime +20 -exec rm {} \;
		exit 0
	fi
else
	echo "Error doing the backup (see logs)"
	exit 1
fi;