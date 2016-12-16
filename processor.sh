#!/bin/bash
echo "Begin parsing files for emails"
grep -F -m1 -l -s --exclude ".emails.txt" @ * | xargs grep -Eho "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b"  > .emails.txt
echo "Sorting and Unique data"
date;sort -u --parallel=2 .emails.txt>emails.txt;date
echo "Removing tmp .emails.txt"
rm .emails.txt
echo "Set headers of file"
echo 'name@domain' | cat - emails.txt > temp && mv temp emails.txt
#echo "Begin generating SQL"
#cat emails.txt | awk '{split($0,a,"@");printf "insert into emails_splited (name, domain)  values ('\''%s'\'', '\''%s'\'');", a[1], a[2];print "";}' > emails_sql_dump.sql
##cat emails.txt | awk '{split($0,a,"@");printf "%s;%s", a[1], a[2];print "";}' > emails_sql_dump.csv

STR=$'.separator @\n.import emails.txt emails_splited\n'
echo "$STR"
echo "$STR" | sqlite3 emails.db 
STR=$"create table domains as select distinct domain as name from emails_splited;"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
STR=$"create unique index if not exists domain_index on domains (name);"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
#STR=$"create table tmp_users as select d.rowid as domain_id, es.name as login from emails_splited es inner join domains d on d.name = es.domain;"
STR=$"create table users as select d.rowid as domain_id, es.name as login from emails_splited es inner join domains d on d.name = es.domain;"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
#STR=$"create table users as select distinct domain_id, login from tmp_users;"
#echo "$STR"
#echo "$STR" | sqlite3 emails.db 
STR=$"create index if not exists users_domain_index on users (domain_id);"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
#STR=$"drop table tmp_users;"
#echo "$STR"
#echo "$STR" | sqlite3 emails.db 
STR=$"drop table emails_splited;"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
STR=$"vacuum;"
echo "$STR"
echo "$STR" | sqlite3 emails.db 
