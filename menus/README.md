# How to create these yaml files


[ssh into siteground server](https://www.siteground.com/kb/how_to_log_in_to_my_shared_account_via_ssh_in_mac_os/):
```bash
ssh codingbe@codingbee.net -p 18765
```

Clone this repo into home directory:

```bash
cd ~
git clone https://github.com/Sher-Chowdhury/codingbee_docs.git
```


Create the following file:

```bash
mkdir ~/.wp-cli
echo '---' >> ~/.wp-cli/config.yml
echo 'path: /home/codingbe/www' >> ~/.wp-cli/config.yml
```
