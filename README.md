# px4_drv_oci
## 簡単な説明と使い方
Mac上の podman machine に対して、px4_drv を導入するためのコンテナイメージ。

podman machine start 後に  
Containerfile が配置されたディレクトリで 
```
podman build -t create_px4_drv .
```
を実行し、
```
podman machine os apply localhost/create_px4_drv  
```
とやれば導入できる。  
  
## 注意点  
- podman machine に割り当てるメモリ量は 4GB 以上必要なこと (podman machine os apply で失敗する)  
- podman machine start の前に、/Users/[username]/.config/containers/podman/machine/qemu/podman-machine-default.json にある QEMU実行時コマンドに USBデバイスの追記がいること  
- 実際にコンテナで px4_drv を使うには、podman machine ssh で、sudo setsebool -P container_use_devices=true を実行すること
- kernel version 6.4.x 以降に対応する記載になっている = 6.4.x より前の kernel だと、この Containerfile は動作しない。

上記の USBデバイス の追記について、  
"CmdLine": [] の最後に、PX-W3U4 であれば、〜〜.qcow2 の後ろに、下記を追記する。
```
,
  "-device",
  "qemu-xhci",
  "-device",
  "usb-host,vendorid=0x0511,productid=0x083f"
```
kernel version 6.4.0 あたりで、class_create() の引数が変更になった、らしい。  
ここの Containerfile では、kernel version 6.4.x 以降で動作するように、記載している。  
そのため、6.4.0 より前の kernel の場合は、下記をコメントアウト または 削除する必要がある。  
https://github.com/sakuei-ld/px4_drv_oci/blob/7a5a1696efe8b32b45ea9726d03a49d1972cc593/Containerfile#L30

## その他
Containerfile 最終行の CMD は、setsebool を自動か出来ないかの試行錯誤。  
何かアイディアが出て、上手くいったら消す。  
また、ライセンスについては、何も無いのも、とは思いつつも、よく分からんので MITライセンス にしてる。  
特に、何かあるわけでは無いので、自由にどうぞ。(ただし、何かあっても責任は取りません)  
