Install
```sh
/usr/sbin/curl -fsSL "https://raw.githubusercontent.com/StealUrKill/Asus-Merlin-Load-Balancing/refs/heads/main/services-start.sh" -o "/jffs/scripts/services-start" && chmod 755 /jffs/scripts/services-start
```


Menu

```sh
sh /jffs/scripts/services-start menu
```


NVRAM Get

```sh
nvram get wanlb_restart_delay
```


Removal

```sh
rm -f /jffs/scripts/services-start
```