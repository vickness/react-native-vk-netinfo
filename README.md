
# react-native-vk-netinfo

检测手机是否连接VPN，查询手机运营商，域名转化为ip地址

## 安装

`yarn add react-native-vk-netinfo`

`react-native link react-native-vk-netinfo`


## 使用
```javascript
import NetInfo from 'react-native-vk-netinfo';

// 检测是否连接VPN
NetInfo.isVPNConnected().then(res => {
      console.log("VPN检测："+res);
    });

// 检测运营商名称
NetInfo.getCarrierName().then(res => {
      console.log("运营商："+res);
    });

// 域名转化为IP地址
NetInfo.getIpsFromHost('www.baidu.com').then(res => {
      console.log(res);
    });
```
