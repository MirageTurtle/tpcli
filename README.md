# TPCLI

This repo is trying to build a cli for certain models of TP-LINK router.

## WARNING

I'm new for bash script. And bash script is toooo tricky to learn and write. It has sooo many many tricky rules. And my cli must have some bugs with an unfriendly interaction.

So I just want to have a try for it, and so this poject was born.

You can find that it's very easy to writing these scripts using programming language, e.g., Python. I just want to learn something by writing these scripts. So I try to use only POSIX commands to implement it, instead of some programming language script such as `python3 -c "xxxx"`.

## Functions

- [x] Login
- [ ] Redirect
  - [x] Query
  - [x] Add
  - [x] Delete
  - [ ] Set/Edit
- [ ] MAC-IP Bind

## TODO

### Redirect - Set/Edit

The POST data format of set or edit funtion is like:

```JSON
{
  "firewall": {
    "redirect_8": {
      "proto": "all",
      "src_dport_start": 9022,
      "src_dport_end": 9022,
      "dest_ip": "192.168.1.100",
      "dest_port": 22
    }
  },
  "method": "set"
}
```
