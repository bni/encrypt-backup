#!/bin/sh
pass=`cat ~/.encrypted-backup-secret`
dest=~/Downloads
final=s3://bnilsson-encrypted-backup
stamp=`date "+%Y-%m-%d"`

echo begin > $dest/backup.log

for entry in \
"/Users/bni/Music/iTunes/iTunes Media/Music,MusicAtoJ,./[A-J]*" \
"/Users/bni/Music/iTunes/iTunes Media/Music,MusicKtoS,./[K-S]*" \
"/Users/bni/Music/iTunes/iTunes Media/Music,MusicTtoZ,./[T-Z]*" \
"/Users/bni/Pictures,Pictures,*" \
"/Volumes/TRANSCEND,TRANSCEND,*" \
; do

IFS=, read dir prefix pattern <<< "$entry"

name=$prefix-$stamp.tar.enc

echo $name >> $dest/backup.log

cd "$dir"

find . -type f -ipath "$pattern" -print0 | tar c --null --no-recursion --files-from - | openssl aes-256-cbc -salt -pass pass:$pass > $dest/$name

ls -alh $dest/$name >> $dest/backup.log

aws s3 cp $dest/$name $final/

rm $dest/$name

done

echo end >> $dest/backup.log

# Decrypt and extract
# mkdir -p Music && openssl aes-256-cbc -d -in MusicAtoJ-2015-06-21.tar.enc | tar x -C Music
