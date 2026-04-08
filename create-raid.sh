#!/bin/bash
# Скрипт для создания RAID-10 (использовался в ДЗ)
set -e

echo "=== Создание RAID-10 ==="

sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e} 2>/dev/null || true

sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sdb /dev/sdc /dev/sdd /dev/sde

echo "RAID создан. Ожидаем завершения синхронизации..."

cat /proc/mdstat
