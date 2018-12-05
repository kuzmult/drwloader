#!/bin/bash


mirror=/mnt/hgfs/update/11.00 
baseDir=/home/kuzm/drweb

function hgfsConnect {
    vmhgfs-fuse .host:/$(vmware-hgfsclient) /mnt/hgfs
    if ! [ $? -eq 0 ]
    then
        echo "Проблема с подключением каталога"
        exit   
    fi
     
}

function downloadBase {
    path=/home/kuzm/drweb/ 
    lk=/home/kuzm/drweb/agent.key 
    uk=/home/kuzm/drweb
    mode=mirror
    proto=http 
    logfile=/home/kuzm/drweb/drwupdate.txt
    echo "Старт загрузки репозитория"
    cd $path
    ./drweb-reploader-linux-x64 --path=$path --license-key=$lk --update-key=$uk --mode=$mode --proto=http --log=$logfile
    if ! [ $? -eq 0 ]
    then
        echo "Проблема с загрузкой репозитория Exit code: $?"
        exit   
    else
    echo "`tail -n1 $logfile`"
    fi
}

function delMirror {
    echo "Удаляем зеркало c хоста"
    sleep 3
    rm -R $mirror
    if ! [ -e $mirror ]  
    then
        echo "Зеркало удалено"
    else
        echo "Зеркало не удалено"
        exit 1
    fi
}

function copyMirror {
    echo "Копируем зеркало на хост"
    sleep 3
    cd $baseDir
    cp -R 11.00/ /mnt/hgfs/update
    echo "Скопированно  на хост"
}


if  ! [ -e $mirror ] ;
then
       echo "Каталог не сущетвует. Подключаем...."
        sleep 2
        hgfsConnect
        echo "Shared folder connect"
        downloadBase
        delMirror
        copyMirror
        echo "Звершено за $SECONDS сек. "
             
else 
            
        echo "Подключено"
        downloadBase
        delMirror
        copyMirror
        echo "Завершено за $SECONDS сек."

fi

exit 0
